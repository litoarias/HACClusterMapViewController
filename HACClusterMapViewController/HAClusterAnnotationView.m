//
//  HAClusterAnnotationView.m
//  HAClusterMapView
//
//  Created by Hipolito Arias on 14/10/15.
//  Copyright © 2015 MasterApp. All rights reserved.
//

#import "HAClusterAnnotationView.h"

CGPoint HACRectCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CGRect HACenterRect(CGRect rect, CGPoint center)
{
    CGRect r = CGRectMake(center.x - rect.size.width/2.0,
                          center.y - rect.size.height/2.0,
                          rect.size.width,
                          rect.size.height);
    return r;
}

static CGFloat const HACScaleFactorAlpha = 0.3;
static CGFloat const HACScaleFactorBeta = 0.4;

CGFloat HACScaledValueForValue(CGFloat value)
{
    return 1.0 / (1.0 + expf(-1 * HACScaleFactorAlpha * powf(value, HACScaleFactorBeta)));
}

@interface HAClusterAnnotationView ()
@property (strong, nonatomic) UILabel *countLabel;
@end

@implementation HAClusterAnnotationView


//-(void) prepareForReuse{
//    [super prepareForReuse];
//    self.backgroundColor = [UIColor clearColor];
//    self.circleBackgroundColor = [UIColor clearColor];
//    self.circleBorderColor = [UIColor clearColor];
//    self.circleTextColor = [UIColor blackColor];
//    _countLabel.backgroundColor = [UIColor clearColor];
//    _countLabel.textColor = self.circleTextColor;
//    _countLabel.textAlignment = NSTextAlignmentCenter;
//    _countLabel.shadowColor = [UIColor clearColor];
//    _countLabel.shadowOffset = CGSizeMake(0, 0);
//    _countLabel.adjustsFontSizeToFitWidth = YES;
//    _countLabel.numberOfLines = 1;
//    _countLabel.font = [UIFont systemFontOfSize:12];
//    _countLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
//
//    [self setCount:1];
//
//    
//}


- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier borderColor:(UIColor *)borderColor backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0,0,44,44);
        self.backgroundColor = [UIColor clearColor];
        self.circleBackgroundColor = backgroundColor;
        self.circleBorderColor = borderColor;
        self.circleTextColor = textColor;
        [self setupLabel];
        [self setCount:1];
    }
    return self;
}

- (void)setupLabel
{
    _countLabel = [[UILabel alloc] initWithFrame:self.frame];
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.textColor = self.circleTextColor;
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.shadowColor = [UIColor clearColor];
    _countLabel.shadowOffset = CGSizeMake(0, 0);
    _countLabel.adjustsFontSizeToFitWidth = YES;
    _countLabel.numberOfLines = 1;
    _countLabel.font = [UIFont systemFontOfSize:12];
    _countLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [self addSubview:_countLabel];
}

- (void)setCount:(NSUInteger)count
{
    _count = count;
    if (_count != 1) {
        _countLabel.hidden = NO;
        CGRect newBounds = CGRectMake(0, 0, roundf(44 * HACScaledValueForValue(count)), roundf(44 * HACScaledValueForValue(count)));
        self.frame = HACenterRect(newBounds, self.center);
        
        CGRect newLabelBounds = CGRectMake(0, 0, newBounds.size.width / 1.3, newBounds.size.height / 1.3);
        self.countLabel.frame = HACenterRect(newLabelBounds, HACRectCenter(newBounds));
        self.countLabel.text = [@(_count) stringValue];
        
        
    }else{
        CGRect newBounds = CGRectMake(0, 0, roundf(44 * HACScaledValueForValue(count)), roundf(44 * HACScaledValueForValue(count)));
        self.frame = HACenterRect(newBounds, self.center);
        
        CGRect newLabelBounds = CGRectMake(0, 0, newBounds.size.width / 1.3, newBounds.size.height / 1.3);
        self.countLabel.frame = HACenterRect(newLabelBounds, HACRectCenter(newBounds));

        _countLabel.text=@"";
        _countLabel.hidden = YES;
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetAllowsAntialiasing(context, true);
    
    UIColor *outerCircleStrokeColor = [UIColor colorWithWhite:0 alpha:0.25];
    UIColor *innerCircleStrokeColor = self.circleBorderColor;

    UIColor *innerCircleFillColor;
    
    if ([self.annotation isKindOfClass:[HAClusterAnnotation class]]){
        if (((HAClusterAnnotation*)self.annotation).count==1){
        
        innerCircleFillColor= ((HAClusterAnnotation*)self.annotation).fillColor ;
        }else{
                innerCircleFillColor= self.circleBackgroundColor;
        }
    }else{
        innerCircleFillColor= self.circleBackgroundColor;
    }
    

 
    
    
    CGRect circleFrame = CGRectInset(rect, 4, 4);
    
    [outerCircleStrokeColor setStroke];
    CGContextSetLineWidth(context, 5.0);
    CGContextStrokeEllipseInRect(context, circleFrame);
    
    [innerCircleStrokeColor setStroke];
    CGContextSetLineWidth(context, 4);
    CGContextStrokeEllipseInRect(context, circleFrame);
    
    [innerCircleFillColor setFill];
    CGContextFillEllipseInRect(context, circleFrame);
}
@end

