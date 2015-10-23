//
//  HACMKMapView.m
//  HAClusterMapView
//
//  Created by Hipolito Arias on 23/10/15.
//  Copyright © 2015 MasterApp. All rights reserved.
//

#import "HACMKMapView.h"

@implementation HACMKMapView

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self defaultInit];
    }
    return self;
}

-(id)init{
    if (self = [super init]) {
        [self defaultInit];
    }
    return self;
}

-(void)defaultInit{
    self.delegate = self;
    self.coordinateQuadTree = [[HACManagerQuadTree alloc] init];
    self.coordinateQuadTree.mapView = self;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [[NSOperationQueue new] addOperationWithBlock:^{
        double scale = self.bounds.size.width / self.visibleMapRect.size.width;
        NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:scale];
        [self updateMapViewAnnotationsWithAnnotations:annotations];
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    static NSString *const HACAnnotatioViewReuseID = @"HACAnnotatioViewReuseID";
    HAClusterAnnotationView *annotationView = (HAClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:HACAnnotatioViewReuseID];
    if (!annotationView) {
        annotationView = [[HAClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:HACAnnotatioViewReuseID];
    }
    annotationView.count = [(HAClusterAnnotation *)annotation count];
    if (annotationView.count == 1) {
        annotationView.image = [UIImage imageNamed:@"pin_default"];
        annotationView.centerOffset = CGPointMake(0,-annotationView.frame.size.height*0.5);
        if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(viewForAnnotationView:annotation:)]) {
            [self.mapDelegate viewForAnnotationView:annotationView annotation:annotation];
        }
    }
    annotationView.canShowCallout = YES;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    for (UIView *view in views) {
        [self addBounceAnnimationToView:view];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    if ([view.annotation isKindOfClass:[HAClusterAnnotation class]]){
        HAClusterAnnotation *annotation = (HAClusterAnnotation *)view.annotation;
        if (annotation.count == 1) {
            [annotation updateSubtitleIfNeeded];
        }
        if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(didSelectAnnotationView:)]) {
            [self.mapDelegate didSelectAnnotationView:annotation];
        }
    }
}

- (void)addBounceAnnimationToView:(UIView *)view{
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

- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations{
    NSMutableSet *before = [NSMutableSet setWithArray:self.annotations];
    [before removeObject:[self userLocation]];
    NSSet *after = [NSSet setWithArray:annotations];
    
    NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
    [toKeep intersectSet:after];
    
    NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
    [toAdd minusSet:toKeep];
    
    NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
    [toRemove minusSet:after];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self addAnnotations:[toAdd allObjects]];
        [self removeAnnotations:[toRemove allObjects]];
    }];
}

@end
