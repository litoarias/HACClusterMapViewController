//
//  HAClusterAnnotation.h
//  HAClusterMapView
//
//  Created by Hipolito Arias on 14/10/15.
//  Copyright © 2015 MasterApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
//#import "MultiRowAnnotationProtocol.h"

@interface HAClusterAnnotation : NSObject <MKAnnotation>

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (assign, nonatomic) NSInteger count;
@property (assign, nonatomic) UIColor* fillColor;
@property (assign, nonatomic) NSInteger index;
@property (copy, nonatomic) NSMutableArray *indexes;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate count:(NSInteger)count index:(NSInteger)index;

- (void)updateSubtitleIfNeeded;

@end
