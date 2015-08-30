# HACClusterMapViewController
<img src="https://img.shields.io/twitter/url/https/github.com/litoarias/HACClusterMapViewController.svg?style=social"><br>
HACClusterMapViewController class is written in Objective-C and facilitates the use of maps when they have many pins that show.

<img src="https://img.shields.io/github/issues/litoarias/HACClusterMapViewController.svg?style=flat-square">
<img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square">
<img src="https://img.shields.io/cocoapods/v/HACClusterMapViewController.svg?style=flat-square">
<img src="https://img.shields.io/npm/dm/HACClusterMapViewController.svg?style=flat-square">


![Preview](https://github.com/litoarias/HACClusterMapViewController/blob/master/ExampleApp/hacclusterviewcontroller.gif)

##Requirements and Dependencies
- iOS >= 7.0
- ARC enabled
- CoreLocation Framework
- MKMapKit Framework

##Installation

####CocoaPods:

    pod 'HACClusterMapViewController'

####Manual install:
- Copy `HACAnnottionMap.h` `HACAnnottionMap.m` `HACAnnotationMapView.m` `HACAnnotationMapView.m` `HACMapLayoutGuide.m` `HACMapLayoutGuide.m` `HACClusterMapViewController.m` and `HACClusterMapViewController.m` to your project
- Manual install [HACClusterMapViewController](https://github.com/litoarias/HACClusterMapViewController/#manual-install)

##Usage

#### Subclassing HACClusterMapViewController
Import in your .h HACClusterMapViewController
```objective-c
#import "HACClusterMapViewController.h"
```
And subclasing your class
```objective-c
@interface Your_Map_View_Controller : HACClusterMapViewController
```
#### Map `IBOutlet`
Using Interface Builder make `IBOutlet` of your map and it is essential to put this name to IBOutlet map is `mapView`, so the parent class so recognized. For more information look at the sample project.
### Map `@synthesize`
You should also add the synthesized view `@synthesize mapView;`
```objective-c
@implementation Your_Map_View_Controller
@synthesize mapView;
```
#### Create annotations -> `HACAnnotationMap`
It's simple to use annotations to images you want, you can create all you want to test in a loop.
```objective-c
NSMutableArray *annotationArray = [[NSMutableArray alloc] init];
    float lat = 39.163195;
    float lng = -0.255294;
    
    for (int i = 0; i < 100; i++) {
        lat += (arc4random()%1000) * 0.0001;
        lng -= (arc4random()%1000) * 0.0001;
        
        CLLocationCoordinate2D location1 = CLLocationCoordinate2DMake(lat, lng);
        HACAnnotationMap *annotationCoffee = [[HACAnnotationMap alloc]initWithImageName:@"pin_coffee" title:[NSString stringWithFormat:@"item %i",i] coordinate:location1];
        [annotationArray addObject:annotationCoffee];
    }
    for (int i = 0; i < 100; i++) {
        lat -= (arc4random()%1000) * 0.0001;
        lng -= (arc4random()%1000) * 0.0001;
        CLLocationCoordinate2D location2 = CLLocationCoordinate2DMake(lat, lng);
        HACAnnotationMap *annotationMuseum = [[HACAnnotationMap alloc]initWithImageName:@"pin_museum" title:[NSString stringWithFormat:@"item %i",i] coordinate:location2];
        [annotationArray addObject:annotationMuseum];
    }
    for (int i = 0; i < 100; i++) {
        lat += (arc4random()%1000) * 0.0001;
        lng += (arc4random()%1000) * 0.0001;
        CLLocationCoordinate2D location3 = CLLocationCoordinate2DMake(lat, lng);
        HACAnnotationMap *annotationCamping = [[HACAnnotationMap alloc]initWithImageName:@"pin_camping" title:[NSString stringWithFormat:@"item %i",i] coordinate:location3];
        [annotationArray addObject:annotationCamping];
    }
```
#### The last step 
The last step would be to call the driver father and pass the array as a parameter to start the process
```objective-c
[self starterWithAnnotations:annotationArray];
```

Enjoy :D

## Contributing

1. Fork it ( https://github.com/[my-github-username]/HACClusterMapViewController/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
