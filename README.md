# HACClusterMapViewController
<img src="https://img.shields.io/twitter/url/https/github.com/litoarias/HACClusterMapViewController.svg?style=social"><br>
HACClusterMapViewController class is written in Objective-C and facilitates the use of maps when they have many pins that show.
Will require us to come up with an ultra quick data structure built for the task. We will need to build it in C for it to be performant.
This version 2.2 has been derived from the original authors version 2.0 , adding more flexibility in the delegates and the display of the annotations as well as correcting some issues.

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
- Copy `HACQuadTree.h` `HACQuadTree.m` `HACManagerQuadTree.h` `HACManagerQuadTree.m` `HAClusterAnnotation.h` `HAClusterAnnotation.m` `HAClusterAnnotationView.h` `HAClusterAnnotationView.m` and `HACMKMapView.h` `HACMKMapView.m` to your project
- Manual install [HACClusterMapViewController](https://github.com/litoarias/HACClusterMapViewController/#manual-install)

##Usage

Import in your .h HACMKMapView
```objective-c
#import "HACMKMapView.h"
```

#### Map `IBOutlet`
For using Interface Builder, set class in your MKMapView `HACMKMapView` and make `IBOutlet` of your map, and put name to IBOutlet for example `mapView`.

#### Delegate for using methods
```objective-c
@interface MapViewController () <HACMKMapViewDelegate>
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.mapDelegate = self;
}
```

#### Creat tree struct
It is easy to use , you must create the following structure in a loop.
```objective-c

 NSArray *data = @[
                      @{kLatitude:@48.47352, kLongitude:@3.87426,  kTitle : @"Title 1", kSubtitle : @"",            kIndex : @0},
                      @{kLatitude:@52.59758, kLongitude:@-1.93061, kTitle : @"Title 2", kSubtitle : @"Subtitle 2",  kIndex : @1},
                      @{kLatitude:@48.41370, kLongitude:@3.43531,  kTitle : @"Title 3", kSubtitle : @"Subtitle 3",  kIndex : @2},
                      @{kLatitude:@48.31921, kLongitude:@18.10184, kTitle : @"Title 4", kSubtitle : @"Subtitle 4",  kIndex : @3},
                      @{kLatitude:@47.84302, kLongitude:@22.81101, kTitle : @"Title 5", kSubtitle : @"Subtitle 5",  kIndex : @4},
                      @{kLatitude:@60.88622, kLongitude:@26.83792, kTitle : @"Title 6", kSubtitle : @""          ,  kIndex : @5}
                      ];
                      
```

#### We send build 
The last step would be to call the driver father and pass the array as a parameter to start the process
```objective-c
 [self.mapView.coordinateQuadTree buildTreeWithArray:data];
```
#### Delegate methods
With delegate methods we can set custom images of annotations or know what index of object be reference.
```objective-c

-(void)viewForAnnotationView:(HAClusterAnnotationView *)annotationView annotation:(HAClusterAnnotation *)annotation{
    if (annotation.index % 2 == 0) {
        annotationView.image = [UIImage imageNamed:@"pin_museum"];
    }else{
        annotationView.image = [UIImage imageNamed:@"pin_coffee"];
    }
}

-(void)didSelectAnnotationView:(HAClusterAnnotation *)annotation{
    NSLog(@"You ara select annotation index %ld", (long)annotation.index);
}

```
#### Customize
### Programmatically
```objective-c
    self.mapView.backgroundAnnotation = [UIColor redColor];
    self.mapView.borderAnnotation = [UIColor whiteColor];
    self.mapView.textAnnotation = [UIColor whiteColor];
    self.mapView.compassFrame = CGRectMake(10, 10, 25, 25);
    self.mapView.legalFrame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds)-50, CGRectGetHeight([UIScreen mainScreen].bounds)-50, 50, 50);
```

### Interface Builder
![Preview](https://github.com/litoarias/HACClusterMapViewController/blob/master/ExampleApp/IBInspectable.png)

Enjoy :D

## Contributing

1. Fork it ( https://github.com/[my-github-username]/HACClusterMapViewController/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
