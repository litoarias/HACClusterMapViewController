//
//  MapLayoutGuide.m
//  GeoBeacon
//
//  Created by Hipolito Arias on 10/8/15.
//  Copyright (c) 2015 MasterApp. All rights reserved.
//

#import "HACMapLayoutGuide.h"

@implementation HACMapLayoutGuide
@synthesize length = _length;

-(id)initWithLength:(float)length
{
    self = [super init];
    if (self) {
        _length = length;
    }
    return self;
}

@end
