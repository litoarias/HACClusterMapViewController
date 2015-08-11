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
    // Do any additional setup after loading the view from its nib.
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
    float lat = 39.163195;
    float lng = -0.255294;
    
    for (int i = 0; i < 100; i++) {
        lat += (arc4random()%1000) * 0.0001;
        lng -= (arc4random()%1000) * 0.0001;
        
        CLLocationCoordinate2D location1 = CLLocationCoordinate2DMake(lat, lng);
        HACAnnotationMap *annotation1 = [[HACAnnotationMap alloc]initWithImageName:@"pin_coffee" title:[NSString stringWithFormat:@"item %i",i] coordinate:location1];
        [annotationArray addObject:annotation1];
    }
    for (int i = 0; i < 100; i++) {
        lat -= (arc4random()%1000) * 0.0001;
        lng -= (arc4random()%1000) * 0.0001;
        CLLocationCoordinate2D location2 = CLLocationCoordinate2DMake(lat, lng);
        HACAnnotationMap *annotation2 = [[HACAnnotationMap alloc]initWithImageName:@"pin_museum" title:[NSString stringWithFormat:@"item %i",i] coordinate:location2];
        [annotationArray addObject:annotation2];
    }
    for (int i = 0; i < 100; i++) {
        lat += (arc4random()%1000) * 0.0001;
        lng += (arc4random()%1000) * 0.0001;
        CLLocationCoordinate2D location3 = CLLocationCoordinate2DMake(lat, lng);
        HACAnnotationMap *annotation3 = [[HACAnnotationMap alloc]initWithImageName:@"pin_camping" title:[NSString stringWithFormat:@"item %i",i] coordinate:location3];
        [annotationArray addObject:annotation3];
    }
    
    return annotationArray;
}

@end
