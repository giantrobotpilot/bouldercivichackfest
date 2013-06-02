//
//  ViewController.h
//  MapView
//
//  Created by Charlie Fish on 6/1/13.
//  Copyright (c) 2013 App-Whiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ImageAnnotation.h"
#import "PictureInfo.h"
@interface MapViewController : UIViewController

@property (nonatomic, retain) IBOutlet MKMapView *mapview;
@property (nonatomic, retain) IBOutlet PictureInfo *infoview;

@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *city;



@end
