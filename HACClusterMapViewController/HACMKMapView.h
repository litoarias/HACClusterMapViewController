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
-(void)viewForAnnotationView:(HAClusterAnnotationView *)annotationView clusteredAnnotation:(HAClusterAnnotation *)annotation;
-(UIColor*)fillColorForAnnotation:(HAClusterAnnotation *)annotation;
-(void)didSelectAnnotationView:(HAClusterAnnotationView *)annotationView;
-(void)didDeselectAnnotationView:(HAClusterAnnotationView *)annotationView;
-(void)didFinishAddingAnnotations;
@end

@interface HACMKMapView : MKMapView <MKMapViewDelegate>

@property (weak, nonatomic) id<HACMKMapViewDelegate>mapDelegate;

@property (nonatomic) IBInspectable UIColor* borderAnnotation;
@property (nonatomic) IBInspectable UIColor* backgroundAnnotation;
@property (nonatomic) IBInspectable UIColor* textAnnotation;
@property (nonatomic) IBInspectable UIImage* defaultImage;
@property (nonatomic) IBInspectable CGRect compassFrame;
@property (nonatomic) IBInspectable CGRect legalFrame;

@property (strong, nonatomic) HACManagerQuadTree *coordinateQuadTree;

@end
