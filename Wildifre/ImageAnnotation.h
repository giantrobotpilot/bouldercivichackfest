//
//  ImageAnnotation.h
//  MapView
//
//  Created by Charlie Fish on 6/1/13.
//  Copyright (c) 2013 App-Whiz. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface ImageAnnotation : MKPointAnnotation

@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic) double heading;
@property (nonatomic, strong) NSDate *date;
@end
