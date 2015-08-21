//
//  HACClusterMapViewController.m
//  GeoBeacon
//
//  Created by Hipolito Arias on 11/8/15.
//  Copyright (c) 2015 MasterApp. All rights reserved.
//

#import "HACClusterMapViewController.h"

@interface HACClusterMapViewController ()<MKMapViewDelegate>

@end

@implementation HACClusterMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _allAnnotationsMapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    _mapView.delegate = self;
    
}

-(void)starterWithAnnotations:(NSArray *)annotations{
    [self.allAnnotationsMapView addAnnotations:annotations];
    [self updateVisibleAnnotations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"MyLocation";
    
    if ([annotation isKindOfClass:[HACAnnotationMap class]])
    {
        HACAnnotationMapView *annotationView = nil;
        HACAnnotationMap *ann = (HACAnnotationMap*)annotation;
        
        if (annotationView == nil)
        {
            annotationView = [[HACAnnotationMapView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            
            annotationView.canShowCallout = YES;
            
            if (ann.containedAnnotations.count > 0) {
                
                [annotationView setCount:ann.containedAnnotations.count+1];
                
            }else{
                annotationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[(HACAnnotationMap *)annotationView.annotation imageName]]];
                
                annotationView.centerOffset = CGPointMake(0,-annotationView.frame.size.height*0.5);
            }
        }
        else
        {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if ([view.annotation isKindOfClass:[HACAnnotationMap class]])
    {
        HACAnnotationMap *annotation = (HACAnnotationMap *)view.annotation;
        if (annotation.containedAnnotations.count > 0) {
            NSMutableArray *annotationsTemp = [NSMutableArray arrayWithArray:annotation.containedAnnotations];
            [annotationsTemp addObject:annotation];
            [self.mapView showAnnotations:annotationsTemp animated:YES];
        }else{
            [annotation updateSubtitleIfNeeded];
        }
    }
}


- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated {
    [self updateVisibleAnnotations];
}

- (void)mapView:(MKMapView *)aMapView didAddAnnotationViews:(NSArray *)views {
    
    for (MKAnnotationView *annotationView in views) {
        if (![annotationView.annotation isKindOfClass:[HACAnnotationMap class]]) {
            continue;
        }
        
        HACAnnotationMap *annotation = (HACAnnotationMap *)annotationView.annotation;
        
        if (annotation.clusterAnnotation != nil) {
            // animate the annotation from it's old container's coordinate, to its actual coordinate
            CLLocationCoordinate2D actualCoordinate = annotation.coordinate;
            CLLocationCoordinate2D containerCoordinate = annotation.clusterAnnotation.coordinate;
            
            // since it's displayed on the map, it is no longer contained by another annotation,
            // (We couldn't reset this in -updateVisibleAnnotations because we needed the reference to it here
            // to get the containerCoordinate)
            annotation.clusterAnnotation = nil;
            
            annotation.coordinate = containerCoordinate;
            
            annotation.coordinate = actualCoordinate;
            
            [self addBounceAnnimationToView:annotationView];
        }
    }
}
- (id<MKAnnotation>)annotationInGrid:(MKMapRect)gridMapRect usingAnnotations:(NSSet *)annotations {
    
    // first, see if one of the annotations we were already showing is in this mapRect
    NSSet *visibleAnnotationsInBucket = [self.mapView annotationsInMapRect:gridMapRect];
    NSSet *annotationsForGridSet = [annotations objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        BOOL returnValue = ([visibleAnnotationsInBucket containsObject:obj]);
        if (returnValue)
        {
            *stop = YES;
        }
        return returnValue;
    }];
    
    if (annotationsForGridSet.count != 0) {
        return [annotationsForGridSet anyObject];
    }
    
    // otherwise, sort the annotations based on their distance from the center of the grid square,
    // then choose the one closest to the center to show
    MKMapPoint centerMapPoint = MKMapPointMake(MKMapRectGetMidX(gridMapRect), MKMapRectGetMidY(gridMapRect));
    NSArray *sortedAnnotations = [[annotations allObjects] sortedArrayUsingComparator:^(id obj1, id obj2) {
        MKMapPoint mapPoint1 = MKMapPointForCoordinate(((id<MKAnnotation>)obj1).coordinate);
        MKMapPoint mapPoint2 = MKMapPointForCoordinate(((id<MKAnnotation>)obj2).coordinate);
        
        CLLocationDistance distance1 = MKMetersBetweenMapPoints(mapPoint1, centerMapPoint);
        CLLocationDistance distance2 = MKMetersBetweenMapPoints(mapPoint2, centerMapPoint);
        
        if (distance1 < distance2) {
            return NSOrderedAscending;
        } else if (distance1 > distance2) {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
    }];
    
    return sortedAnnotations[0];
}

- (void)updateVisibleAnnotations {
    // This value to controls the number of off screen annotations are displayed.
    // A bigger number means more annotations, less chance of seeing annotation views pop in but decreased performance.
    // A smaller number means fewer annotations, more chance of seeing annotation views pop in but better performance.
    static float marginFactor = 6.0;
    // Adjust this roughly based on the dimensions of your annotations views.
    // Bigger numbers more aggressively coalesce annotations (fewer annotations displayed but better performance).
    // Numbers too small result in overlapping annotations views and too many annotations on screen.
    static float bucketSize = 60.0;
    
    // find all the annotations in the visible area + a wide margin to avoid popping annotation views in and out while panning the map.
    MKMapRect visibleMapRect = [self.mapView visibleMapRect];
    MKMapRect adjustedVisibleMapRect = MKMapRectInset(visibleMapRect, -marginFactor * visibleMapRect.size.width, -marginFactor * visibleMapRect.size.height);
    
    // determine how wide each bucket will be, as a MKMapRect square
    CLLocationCoordinate2D leftCoordinate = [self.mapView convertPoint:CGPointZero toCoordinateFromView:self.view];
    CLLocationCoordinate2D rightCoordinate = [self.mapView convertPoint:CGPointMake(bucketSize, 0) toCoordinateFromView:self.view];
    double gridSize = MKMapPointForCoordinate(rightCoordinate).x - MKMapPointForCoordinate(leftCoordinate).x;
    MKMapRect gridMapRect = MKMapRectMake(0, 0, gridSize, gridSize);
    
    // condense annotations, with a padding of two squares, around the visibleMapRect
    double startX = floor(MKMapRectGetMinX(adjustedVisibleMapRect) / gridSize) * gridSize;
    double startY = floor(MKMapRectGetMinY(adjustedVisibleMapRect) / gridSize) * gridSize;
    double endX = floor(MKMapRectGetMaxX(adjustedVisibleMapRect) / gridSize) * gridSize;
    double endY = floor(MKMapRectGetMaxY(adjustedVisibleMapRect) / gridSize) * gridSize;
    
    // for each square in our grid, pick one annotation to show
    gridMapRect.origin.y = startY;
    while (MKMapRectGetMinY(gridMapRect) <= endY) {
        gridMapRect.origin.x = startX;
        
        while (MKMapRectGetMinX(gridMapRect) <= endX) {
            NSSet *allAnnotationsInBucket = [self.allAnnotationsMapView annotationsInMapRect:gridMapRect];
            NSSet *visibleAnnotationsInBucket = [self.mapView annotationsInMapRect:gridMapRect];
            
            // we only care about PhotoAnnotations
            NSMutableSet *filteredAnnotationsInBucket = [[allAnnotationsInBucket objectsPassingTest:^BOOL(id obj, BOOL *stop) {
                return ([obj isKindOfClass:[HACAnnotationMap class]]);
            }] mutableCopy];
            
            if (filteredAnnotationsInBucket.count > 0) {
                HACAnnotationMap *annotationForGrid = (HACAnnotationMap *)[self annotationInGrid:gridMapRect usingAnnotations:filteredAnnotationsInBucket];
                
                [filteredAnnotationsInBucket removeObject:annotationForGrid];
                
                // give the annotationForGrid a reference to all the annotations it will represent
                annotationForGrid.containedAnnotations = [filteredAnnotationsInBucket allObjects];
                
                [self.mapView removeAnnotation:annotationForGrid];
                [self.mapView addAnnotation:annotationForGrid];
                
                for (HACAnnotationMap *annotation in filteredAnnotationsInBucket) {
                    // give all the other annotations a reference to the one which is representing them
                    annotation.clusterAnnotation = annotationForGrid;
                    annotation.containedAnnotations = nil;
                    
                    // remove annotations which we've decided to cluster
                    if ([visibleAnnotationsInBucket containsObject:annotation]) {
                        MKAnnotationView *view = [self.mapView viewForAnnotation:annotation];
                        if (view) {
                            [self addBounceDeleteAnnimationToView:view];
                        }
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.mapView removeAnnotation:annotation];
                        });
                        
                        //                            CLLocationCoordinate2D actualCoordinate = annotation.coordinate;
                        //                            [UIView animateWithDuration:0.3 animations:^{
                        //                                annotation.coordinate = annotation.clusterAnnotation.coordinate;
                        //                            } completion:^(BOOL finished) {
                        //                                annotation.coordinate = actualCoordinate;
                        //                                [self.mapView removeAnnotation:annotation];
                        //                            }];
                    }
                    
                }
            }
            gridMapRect.origin.x += gridSize;
        }
        gridMapRect.origin.y += gridSize;
    }
}


- (void)addBounceAnnimationToView:(UIView *)view
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.values = @[@(0.05), @(1.1), @(0.9), @(1)];
    
    bounceAnimation.duration = 0.6;
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:bounceAnimation.values.count];
    for (NSUInteger i = 0; i < bounceAnimation.values.count; i++) {
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    [bounceAnimation setTimingFunctions:timingFunctions.copy];
    bounceAnimation.removedOnCompletion = NO;
    
    [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

- (void)addBounceDeleteAnnimationToView:(UIView *)view
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.values = @[@(2.0),@(1.5),@(.2),@(0.0)];
    
    bounceAnimation.duration = 0.6;
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:bounceAnimation.values.count];
    for (NSUInteger i = 0; i < bounceAnimation.values.count; i++) {
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    [bounceAnimation setTimingFunctions:timingFunctions.copy];
    bounceAnimation.removedOnCompletion = NO;
    
    [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

-(id)topLayoutGuide
{
    // #define kCompassInset 128.0/2.0
    return [[HACMapLayoutGuide alloc] initWithLength:160.0/2.0];
}

- (id)bottomLayoutGuide
{
    // #define kLegalInset = 44.0
    return [[HACMapLayoutGuide alloc] initWithLength:0.0];
}
@end
