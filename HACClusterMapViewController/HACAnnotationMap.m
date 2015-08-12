//
//  AnnotationMap.m
//  GeoBeacon
//
//  Created by Hipolito Arias on 10/8/15.
//  Copyright (c) 2015 MasterApp. All rights reserved.
//

#import "HACAnnotationMap.h"


@interface HACAnnotationMap ()
@property (strong, nonatomic) UILabel *countLabel;
@end

@implementation HACAnnotationMap

- (id)initWithImageName:(NSString *)imageName title:(NSString *)aTitle coordinate:(CLLocationCoordinate2D)aCoordinate {
    
    self = [super init];
    if (self != nil) {
        self.imageName = imageName;
        self.title = aTitle;
        self.coordinate = aCoordinate;
        self.count = self.containedAnnotations.count;
    }
    return self;
}
-(void)setCount:(NSUInteger)count{
    _count = self.containedAnnotations.count;
    
}
- (NSString *)title {
    self.count = self.containedAnnotations.count + 1;
    
    if (self.containedAnnotations.count > 0) {
        return [NSString stringWithFormat:@"%zd items", self.containedAnnotations.count + 1];
    }
    
    return _title;
}

- (NSString *)stringForPlacemark:(CLPlacemark *)placemark {
    
    NSMutableString *string = [[NSMutableString alloc] init];
    if (placemark.locality) {
        [string appendString:placemark.locality];
    }
    
    if (placemark.administrativeArea) {
        if (string.length > 0)
            [string appendString:@", "];
        [string appendString:placemark.administrativeArea];
    }
    
    if (string.length == 0 && placemark.name)
        [string appendString:placemark.name];
    
    return string;
}

- (void)updateSubtitleIfNeeded {
    
    if (self.subtitle == nil) {
        // for the subtitle, we reverse geocode the lat/long for a proper location string name
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks.count > 0) {
                CLPlacemark *placemark = placemarks[0];
                self.subtitle = [NSString stringWithFormat:@"Near %@", [self stringForPlacemark:placemark]];
            }
        }];
    }
}



@end
