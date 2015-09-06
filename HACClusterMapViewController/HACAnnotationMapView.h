//
//  TBClusterAnnotationView.h
//  TBAnnotationClustering
//
//  Created by Theodore Calmes on 10/4/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface HACAnnotationMapView : MKAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier textColor:(UIColor *)textColor;

@property (assign, nonatomic) NSUInteger count;
@property (assign, nonatomic) UIColor *clusterBackgroundColor;
@property (assign, nonatomic) UIColor *clusterBorderColor;
@property (assign, nonatomic) UIColor *clusterTextColor;

@end
