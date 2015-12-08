//
//  HACMKMapView.h
//  HAClusterMapView
//
//  Created by Hipolito Arias on 23/10/15.
//  Copyright © 2015 MasterApp. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "HACManagerQuadTree.h"
#import "HAClusterAnnotation.h"
#import "HAClusterAnnotationView.h"

IB_DESIGNABLE
@protocol HACMKMapViewDelegate <NSObject>

@optional
-(void)viewForAnnotationView:(HAClusterAnnotationView *)annotationView annotation:(HAClusterAnnotation *)annotation;
-(void)didSelectAnnotationView:(HAClusterAnnotation *)annotation;
@end

@interface HACMKMapView : MKMapView <MKMapViewDelegate>

@property (weak, nonatomic) id<HACMKMapViewDelegate>mapDelegate;

@property (nonatomic) IBInspectable UIColor* borderAnnotation;
@property (nonatomic) IBInspectable UIColor* backgroundAnnotation;
@property (nonatomic) IBInspectable UIColor* textAnnotation;
@property (nonatomic) IBInspectable CGRect compassFrame;
@property (nonatomic) IBInspectable CGRect legalFrame;

@property (strong, nonatomic) HACManagerQuadTree *coordinateQuadTree;

@end
