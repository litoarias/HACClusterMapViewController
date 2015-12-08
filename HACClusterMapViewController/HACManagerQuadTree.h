//
//  HACManagerQuadTree.h
//  HAClusterMapView
//
//  Created by Hipolito Arias on 14/10/15.
//  Copyright © 2015 MasterApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "HACQuadTree.h"

#define kLatitude @"lat"
#define kLongitude @"lng"
#define kTitle @"title"
#define kSubtitle @"subtitle"
#define kIndex @"index"

@interface HACManagerQuadTree : NSObject{
    BOOL example;
}

@property (assign, nonatomic) HACQuadTreeNode* root;
@property (strong, nonatomic) MKMapView *mapView;

- (void)buildTreeWithExample;
- (void)buildTreeWithArray:(NSArray *)data;
- (NSArray *)clusteredAnnotationsWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale;

@end
