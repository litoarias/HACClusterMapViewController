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
    
    self.backgroundAnnotation = [UIColor orangeColor];
    self.borderAnnotation = [UIColor whiteColor];
    self.textAnnotation = [UIColor whiteColor];
    self.defaultImage = [UIImage imageNamed:@"pin_default"];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [[NSOperationQueue new] addOperationWithBlock:^{
        double scale = self.bounds.size.width / self.visibleMapRect.size.width;
        NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:scale];
        //TODO: Avoid removing non clustered annotation
        [self updateMapViewAnnotationsWithAnnotations:annotations];
    }];
}



- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    if (![annotation isKindOfClass:[HAClusterAnnotation class]])
        return nil;
    static NSString *const HACAnnotatioViewReuseID = @"HACAnnotatioViewReuseID";
    HAClusterAnnotationView *annotationView = (HAClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:HACAnnotatioViewReuseID];
    
    UIColor * fillColor= Nil;
    if (!annotationView) {
        
        if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(fillColorForAnnotation:)]) {
            fillColor = [self.mapDelegate fillColorForAnnotation:annotation];
            
        }
        if (!fillColor) {
            fillColor= self.backgroundAnnotation;
        }
        annotationView = [[HAClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:HACAnnotatioViewReuseID borderColor:self.borderAnnotation backgroundColor:fillColor textColor:self.textAnnotation];
    }else{
        if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(fillColorForAnnotation:)]) {
            fillColor = [self.mapDelegate fillColorForAnnotation:annotation];
            
        }
        if (!fillColor) {
            fillColor= self.backgroundAnnotation;
        }
        annotationView.circleBackgroundColor = fillColor;

    }
    annotationView.circleBorderColor = self.borderAnnotation;
    annotationView.circleTextColor = self.textAnnotation;
    annotationView.count = [(HAClusterAnnotation *)annotation count];
    annotationView.canShowCallout = YES;
    if (annotationView.count == 1) {
        if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(viewForAnnotationView:annotation:)]) {
            [self.mapDelegate viewForAnnotationView:annotationView annotation:annotation];
        }else{
            annotationView.image = self.defaultImage;
        }
        annotationView.centerOffset = CGPointMake(0,-annotationView.frame.size.height*0.5);
    }else{
        if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(viewForAnnotationView:clusteredAnnotation:)]) {
            [self.mapDelegate viewForAnnotationView:annotationView clusteredAnnotation:annotation];
        }
    }
    [annotationView setNeedsLayout];
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

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    if ([view.annotation isKindOfClass:[HAClusterAnnotation class]]){
        HAClusterAnnotation *annotation = (HAClusterAnnotation *)view.annotation;
        if (annotation.count == 1) {
            [annotation updateSubtitleIfNeeded];
        }
        if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(didDeselectAnnotationView:)]) {
            [self.mapDelegate didDeselectAnnotationView:(HAClusterAnnotationView *)view];
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
        //Oggerschummer
        
        if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(didFinishAddingAnnotations)]) {
            [self.mapDelegate didFinishAddingAnnotations];
            
        }
        
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    for(id view in self.subviews){
        if([view isKindOfClass:NSClassFromString(@"MKCompassView")])
            [self moveCompass:view];
        
        if ([view isKindOfClass:[UILabel class]]) {
            [self moveLegal:(UILabel *)view];
        }
    }
}

- (void)moveCompass:(UIView *)view{
    view.frame = self.compassFrame;
}

-(void)moveLegal:(UILabel *)legal{
    legal.frame = self.legalFrame;
}

@end
