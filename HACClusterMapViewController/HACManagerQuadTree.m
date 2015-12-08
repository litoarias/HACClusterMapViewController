//
//  HACManagerQuadTree.m
//  HAClusterMapView
//
//  Created by Hipolito Arias on 14/10/15.
//  Copyright © 2015 MasterApp. All rights reserved.
//

#import "HACManagerQuadTree.h"
#import "HAClusterAnnotation.h"

typedef struct HACItemInfo {
    char* itemTitle;
    char* itemSubtitle;
    char* itemIndex;
} HACHItemInfo;

HACQuadTreeNodeData HACDataFromLine(NSString *line)
{
    NSArray *components = [line componentsSeparatedByString:@","];
    double latitude = [components[1] doubleValue];
    double longitude = [components[0] doubleValue];
    
    HACHItemInfo* info = malloc(sizeof(HACHItemInfo));
    
    NSString *title = [components[2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    info->itemTitle = malloc(sizeof(char) * title.length + 1);
    strncpy(info->itemTitle, [title UTF8String], title.length + 1);
    
    NSString *subtitle = [[components lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    info->itemSubtitle = malloc(sizeof(char) * subtitle.length + 1);
    strncpy(info->itemSubtitle, [subtitle UTF8String], subtitle.length + 1);
    
    if (components.count > 3) {
        NSString *index = [components[3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        info->itemIndex = malloc(sizeof(char) * index.length + 1);
        strncpy(info->itemIndex, [index UTF8String], index.length + 1);
    }
    
    return HACQuadTreeNodeDataMake(latitude, longitude, info);
}

HACBoundingBox HACBoundingBoxForMapRect(MKMapRect mapRect)
{
    CLLocationCoordinate2D topLeft = MKCoordinateForMapPoint(mapRect.origin);
    CLLocationCoordinate2D botRight = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)));
    
    CLLocationDegrees minLat = botRight.latitude;
    CLLocationDegrees maxLat = topLeft.latitude;
    
    CLLocationDegrees minLon = topLeft.longitude;
    CLLocationDegrees maxLon = botRight.longitude;
    
    return HACBoundingBoxMake(minLat, minLon, maxLat, maxLon);
}

MKMapRect HACMapRectForBoundingBox(HACBoundingBox boundingBox)
{
    MKMapPoint topLeft = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.x0, boundingBox.y0));
    MKMapPoint botRight = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.xf, boundingBox.yf));
    
    return MKMapRectMake(topLeft.x, botRight.y, fabs(botRight.x - topLeft.x), fabs(botRight.y - topLeft.y));
}

NSInteger HACZoomScaleToZoomLevel(MKZoomScale scale)
{
    double totalTilesAtMaxZoom = MKMapSizeWorld.width / 256.0;
    NSInteger zoomLevelAtMaxZoom = log2(totalTilesAtMaxZoom);
    NSInteger zoomLevel = MAX(0, zoomLevelAtMaxZoom + floor(log2f(scale) + 0.5));
    
    return zoomLevel;
}

float HACCellSizeForZoomScale(MKZoomScale zoomScale)
{
    NSInteger zoomLevel = HACZoomScaleToZoomLevel(zoomScale);
    
    switch (zoomLevel) {
        case 13:
        case 14:
        case 15:
            return 64;
        case 16:
        case 17:
        case 18:
            return 32;
        case 19:
            return 16;
            
        default:
            return 88;
    }
}

@implementation HACManagerQuadTree

- (void)buildTreeWithExample
{
    @autoreleasepool {
        example=YES;
        NSArray *data = [self read];
        NSInteger count = data.count - 1;
        HACQuadTreeNodeData *dataArray = calloc(count, sizeof(HACQuadTreeNodeData));
        for (NSInteger i = 0; i < count; i++) {
            dataArray[i] = HACDataFromLine(data[i]);
        }
        HACBoundingBox world = HACBoundingBoxMake(-185, -185, 185, 185);
        _root = HACQuadTreeBuildWithData(dataArray, (int)count, world, 4);
        
        free(dataArray);
        dataArray = NULL;
    }
}

- (void)buildTreeWithArray:(NSArray *)data
{
    @autoreleasepool {
        data = [self dropPinsWithData:data];
        NSInteger count = data.count;
        HACQuadTreeNodeData *dataArray = malloc(sizeof(HACQuadTreeNodeData) * count);
        for (NSInteger i = 0; i < count; i++) {
            dataArray[i] = HACDataFromLine(data[i]);
        }
        HACBoundingBox world = HACBoundingBoxMake(-185, -185, 185, 185);
        _root = HACQuadTreeBuildWithData(dataArray, (int)count, world, 4);
    }
}

-(NSArray *)dropPinsWithData:(NSArray *)data {
    NSMutableArray*annotationArray= [NSMutableArray new];
    for (int i = 0; i < data.count; i++) {
        NSDictionary *d = data[i];
        NSMutableString *line = [NSMutableString new];
        [line appendString:[NSString stringWithFormat:@"%@, ", [d valueForKey:kLongitude]]];
        [line appendString:[NSString stringWithFormat:@"%@, ", [d valueForKey:kLatitude]]];
        [line appendString:[NSString stringWithFormat:@"%@, ", [d valueForKey:kTitle]]];
        [line appendString:[NSString stringWithFormat:@"%@, ", [d valueForKey:kIndex]]];
        [line appendString:[NSString stringWithFormat:@"%@",   [d valueForKey:kSubtitle]]];
        [annotationArray addObject:line];
    }
    return [[NSArray alloc]initWithArray:annotationArray];
}

-(NSArray *)read {
    NSString *data = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"csv"] encoding:NSASCIIStringEncoding error:nil];
    NSArray *lines = [data componentsSeparatedByString:@"\n"];
    return lines;
}

- (NSArray *)clusteredAnnotationsWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale
{
    double HACCellSize = HACCellSizeForZoomScale(zoomScale);
    double scaleFactor = zoomScale / HACCellSize;
    
    NSInteger minX = floor(MKMapRectGetMinX(rect) * scaleFactor);
    NSInteger maxX = floor(MKMapRectGetMaxX(rect) * scaleFactor);
    NSInteger minY = floor(MKMapRectGetMinY(rect) * scaleFactor);
    NSInteger maxY = floor(MKMapRectGetMaxY(rect) * scaleFactor);
    
    NSMutableArray *clusteredAnnotations = [[NSMutableArray alloc] init];
    for (NSInteger x = minX; x <= maxX; x++) {
        int cont = 0;
        for (NSInteger y = minY; y <= maxY; y++) {
            MKMapRect mapRect = MKMapRectMake(x / scaleFactor, y / scaleFactor, 1.0 / scaleFactor, 1.0 / scaleFactor);
            
            __block double totalX = 0;
            __block double totalY = 0;
            __block int count = 0;
            
            NSMutableArray *titles = [[NSMutableArray alloc] init];
            NSMutableArray *subtitles = [[NSMutableArray alloc] init];
            NSMutableArray *indexes = [[NSMutableArray alloc] init];
            
            HACQuadTreeGatherDataInRange(self.root, HACBoundingBoxForMapRect(mapRect), ^(HACQuadTreeNodeData data) {
                totalX += data.x;
                totalY += data.y;
                count++;
                
                HACHItemInfo info = *(HACHItemInfo *)data.data;
                [titles addObject:[NSString stringWithFormat:@"%s", info.itemTitle]];
                [subtitles addObject:[NSString stringWithFormat:@"%s", info.itemSubtitle]];
                if (!example) {
                    [indexes addObject:[NSString stringWithFormat:@"%s", info.itemIndex]];
                }
            });
            
            cont++;
            if (count == 1) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX, totalY);
                HAClusterAnnotation *annotation = [[HAClusterAnnotation alloc] initWithCoordinate:coordinate count:count index:[[indexes lastObject] integerValue]];
                annotation.indexes = [[NSMutableArray alloc]initWithArray:indexes];
                annotation.title = [titles lastObject];
                ![[subtitles lastObject]isEqualToString:@""] ? (annotation.subtitle = [subtitles lastObject]) : (annotation.subtitle = nil);
                [clusteredAnnotations addObject:annotation];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(annotationAddedToCluster:)]) {
                    [self.delegate annotationAddedToCluster:annotation];
                }
            }
            
            if (count > 1) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX / count, totalY / count);
                HAClusterAnnotation *annotation = [[HAClusterAnnotation alloc] initWithCoordinate:coordinate count:count index:[[indexes lastObject] integerValue]];
                annotation.indexes = [[NSMutableArray alloc]initWithArray:indexes];
                //DLog (@" %@, %i", annotation.title, annotation.indexes.count);
                [clusteredAnnotations addObject:annotation];
                if (self.delegate && [self.delegate respondsToSelector:@selector(annotationAddedToCluster:)]) {
                    [self.delegate annotationAddedToCluster:annotation];
                }
            }
        }
    }
    
    return [NSArray arrayWithArray:clusteredAnnotations];
}

@end
