//
//  MKMapView+ZoomLevel.m
//  HACClusterMapViewController
//
//  Created by Hipolito Arias on 8/10/15.
//  Copyright © 2015 MasterApp. All rights reserved.
//

#import "MKMapView+ZoomLevel.h"

@implementation MKMapView (ZoomLevel)

- (NSUInteger) aZoomLevel {
    MKMapRect visibleRect = self.visibleMapRect;
    double centerPixelX = visibleRect.origin.x+visibleRect.size.width/2;
    double topLeftPixelX = visibleRect.origin.x;
    double scaledMapWidth = (centerPixelX - topLeftPixelX) * 2;
    CGSize mapSizeInPixels = self.bounds.size;
    double zoomScale = scaledMapWidth / mapSizeInPixels.width;
    double zoomExponent = log(zoomScale) / log(2);
    double zoomLevel = 21 - zoomExponent;
    return zoomLevel;
}

@end
