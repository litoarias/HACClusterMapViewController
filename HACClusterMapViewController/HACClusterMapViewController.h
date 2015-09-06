//
//  HACClusterMapViewController.h
//  GeoBeacon
//
//  Created by Hipolito Arias on 11/8/15.
//  Copyright (c) 2015 MasterApp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "HACAnnotationMap.h"
#import "HACAnnotationMapView.h"
#import "HACMapLayoutGuide.h"

@interface HACClusterMapViewController : UIViewController


@property (weak, nonatomic) MKMapView *mapView;

@property (nonatomic, strong) MKMapView *allAnnotationsMapView;

@property (assign, nonatomic) CGFloat paddingLegal;

@property (strong, nonatomic) UIColor *clusterBackgroundColor;

@property (strong, nonatomic) UIColor *clusterBorderColor;

@property (strong, nonatomic) UIColor *clusterTextColor;

-(void)starterWithAnnotations:(NSArray *)annotations;

@end
