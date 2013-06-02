//
//  ViewController.m
//  MapView
//
//  Created by Charlie Fish on 6/1/13.
//  Copyright (c) 2013 App-Whiz. All rights reserved.
//

#import "MapViewController.h"
#import "AFNetworking.h"

@interface MapViewController ()

@property (nonatomic, strong) AFHTTPClient  *photoClient;
@property (nonatomic, strong) NSArray       *annotations;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.photoClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://wildfire.elasticbeanstalk.com"]];
    
    NSMutableURLRequest *request = [self.photoClient requestWithMethod:@"GET" path:@"photos" parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *error;
        NSArray *results = [NSJSONSerialization JSONObjectWithData:responseObject
                                                           options:0
                                                             error:&error];
        if ([NSJSONSerialization isValidJSONObject:results]) {
            NSArray *photos = [results valueForKey:@"photos"];
            NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:[photos count]];
            for (NSDictionary *photo in photos) {
                ImageAnnotation *annotation = [[ImageAnnotation alloc] init];
                double lat = [[photo valueForKey:@"lat"] doubleValue];
                double lng = [[photo valueForKey:@"lng"] doubleValue];
                double heading = [[photo valueForKey:@"heading"] doubleValue];
                annotation.coordinate = CLLocationCoordinate2DMake(lat, lng);
                annotation.imageURL = [photo valueForKey:@"url"];
                annotation.heading = heading;
                annotation.title = @"Photo";
                
                [annotations addObject:annotation];
            }
            [self.mapview addAnnotations:annotations];
        } else {
            NSLog(@"not valid JSON");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
    }];
    [operation start];
    
    CLLocationCoordinate2D  points[4];
    
    points[0] = CLLocationCoordinate2DMake(41.000512, -109.050116);
    points[1] = CLLocationCoordinate2DMake(41.002371, -102.052066);
    points[2] = CLLocationCoordinate2DMake(36.993076, -102.041981);
    points[3] = CLLocationCoordinate2DMake(36.99892, -109.045267);

    /*
    ImageAnnotation *annotation = [[ImageAnnotation alloc] init];
    [annotation setCoordinate:points[0]];
    [annotation setTitle:@"Point 1"]; //You can set the subtitle too
    //annotation.image = [UIImage imageWithData:[NSDate dataWithContentsOfURL:[NSURL URLWithString:STRING]]];
    [self.mapview addAnnotation:annotation];
    
    
    
    ImageAnnotation *annotation1 = [[ImageAnnotation alloc] init];
    [annotation1 setCoordinate:points[1]];
    [annotation1 setTitle:@"Point 2"]; //You can set the subtitle too
    [self.mapview addAnnotation:annotation1];

    ImageAnnotation *annotation2 = [[ImageAnnotation alloc] init];
    [annotation2 setCoordinate:points[2]];
    [annotation2 setTitle:@"Point 3"]; //You can set the subtitle too
    [self.mapview addAnnotation:annotation2];

    ImageAnnotation *annotation3 = [[ImageAnnotation alloc] init];
    [annotation3 setCoordinate:points[3]];
    [annotation3 setTitle:@"Point 4"]; //You can set the subtitle too
    [self.mapview addAnnotation:annotation3];
    */
    
    MKPolygon* poly = [MKPolygon polygonWithCoordinates:points count:4];
    poly.title = @"Colorado";
 
    [self.mapview addOverlay:poly];
}


/*
 - (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[self.mapview userLocation].location completionHandler:^(NSArray *placemarks, NSError *error) {
        MKPlacemark *placemark = placemarks[0];
        self.state = placemark.administrativeArea;
        self.city = placemark.locality;

        NSLog(@"%@, %@",_city, _state);
        
        NSLog(@"%lu",(unsigned long)placemarks.count);
        NSLog(error.localizedDescription);
    }];

}
 */




- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolygon class]])
    {
        MKPolygonView*    aView = [[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay];
        
        aView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        aView.lineWidth = 3;
        
        return aView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    PictureInfo *pictureinfo = [self.storyboard instantiateViewControllerWithIdentifier:@"PictureInfo"];
    //image url set here
    [self.navigationController pushViewController:pictureinfo animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (annotation == [mapView userLocation]) {
        return nil;
    }
    /*
    MKPinAnnotationView *pinannotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    pinannotation.rightCalloutAccessoryView = button;
    pinannotation.canShowCallout = YES;
    return pinannotation;
     */
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PhotoAnnotate"];
    
    ImageAnnotation *imgAnnotation = (ImageAnnotation *)annotation;
    double header = imgAnnotation.heading;
    if (header < 22.5) {
        annotationView.image = [UIImage imageNamed:@"N.png"];
    } else if (header >= 22.5 && header < 67.5) {
        annotationView.image = [UIImage imageNamed:@"NE.png"];
    } else if (header >= 67.5 && header < 112.5) {
        annotationView.image = [UIImage imageNamed:@"E.png"];
    } else if (header >= 112.5 && header < 157.5) {
        annotationView.image = [UIImage imageNamed:@"SE.png"];
    } else if (header >= 157.5 && header < 202.5) {
        annotationView.image = [UIImage imageNamed:@"S.png"];
    } else if (header >= 202.5 && header < 247.5) {
        annotationView.image = [UIImage imageNamed:@"SW.png"];
    } else if (header >= 247.5 && header < 292.5) {
        annotationView.image = [UIImage imageNamed:@"W.png"];
    } else if (header >= 292.5 && header < 337.5) {
        annotationView.image = [UIImage imageNamed:@"NW.png"];
    } else {
        annotationView.image = [UIImage imageNamed:@"N.png"];
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    //NSLog(@"\n \n \n \n %f \n %f \n \n %f \n %f", mapView.region.center.latitude, mapView.region.center.longitude, mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
}

@end