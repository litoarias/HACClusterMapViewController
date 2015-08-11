//
//  MapLayoutGuide.h
//  GeoBeacon
//
//  Created by Hipolito Arias on 10/8/15.
//  Copyright (c) 2015 MasterApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HACMapLayoutGuide : NSObject<UILayoutSupport>
@property (nonatomic) float insetLength;
-(id)initWithLength:(float)length;
@end
