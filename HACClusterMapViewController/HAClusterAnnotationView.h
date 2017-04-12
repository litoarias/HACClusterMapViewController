//
//  HAClusterAnnotationView.h
//  HAClusterMapView
//
//  Created by Hipolito Arias on 14/10/15.
//  Copyright © 2015 MasterApp. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "HAClusterAnnotation.h"

@interface HAClusterAnnotationView : MKAnnotationView

@property (retain, nonatomic) UIColor *circleBackgroundColor;
@property (retain, nonatomic) UIColor *circleBorderColor;
@property (retain, nonatomic) UIColor *circleTextColor;
@property (assign, nonatomic) NSUInteger count;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier borderColor:(UIColor *)borderColor backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor;

@end
