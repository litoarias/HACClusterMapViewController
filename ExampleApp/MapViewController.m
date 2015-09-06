//
//  MapViewController.m
//  HACClusterMapViewController
//
//  Created by Hipolito Arias on 11/8/15.
//  Copyright (c) 2015 MasterApp. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation MapViewController

@synthesize mapView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.paddingLegal = 0.0;
    self.clusterBackgroundColor = [UIColor redColor];
    self.clusterBorderColor = [UIColor whiteColor];
    self.clusterTextColor = [UIColor whiteColor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self starterWithAnnotations:[self dropPins]];
        [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray *)dropPins {
    
    NSMutableArray *annotationArray = [[NSMutableArray alloc] init];
    float lat;
    float lng;
    
    for (int i = 0; i < 100; i++) {
        lat = arc4random()%20 +50;
        lng = -107.0  + arc4random()%10;
        
        CLLocationCoordinate2D location1 = CLLocationCoordinate2DMake(lat, lng);
        HACAnnotationMap *annotation1 = [[HACAnnotationMap alloc]initWithImageName:@"pin_coffee" title:[NSString stringWithFormat:@"item %i",i] coordinate:location1];
        [annotationArray addObject:annotation1];
    }
    
    for (int i = 100; i < 200; i++) {
        lat = arc4random()%20 +50;
        lng = -10.0  + arc4random()%10;
        
        CLLocationCoordinate2D location2 = CLLocationCoordinate2DMake(lat, lng);
        HACAnnotationMap *annotation2 = [[HACAnnotationMap alloc]initWithImageName:@"pin_museum" title:[NSString stringWithFormat:@"item %i",i] coordinate:location2];
        [annotationArray addObject:annotation2];
    }
    
    for (int i = 200; i < 300; i++) {
        lat = arc4random()%20 +50;
        lng = -3.0  + arc4random()%10;
        
        CLLocationCoordinate2D location3 = CLLocationCoordinate2DMake(lat, lng);
        HACAnnotationMap *annotation3 = [[HACAnnotationMap alloc]initWithImageName:@"pin_camping" title:[NSString stringWithFormat:@"item %i",i] coordinate:location3];
        [annotationArray addObject:annotation3];
    }
    
    return annotationArray;
}

@end
