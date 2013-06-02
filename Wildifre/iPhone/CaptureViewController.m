//
//  CaptureViewController.m
//  Wildifre
//
//  Created by Drew on 6/1/13.
//  Copyright (c) 2013 Giant Robot Pilot. All rights reserved.
//

#import "CaptureViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AFNetworking.h"
#import "UIImage+fixOrientation.h"

#define BAD_LOCATION_COLOR  [UIColor redColor];
#define GOOD_LOCATION_COLOR [UIColor greenColor];
#define OK_LOCATION_COLOR   [UIColor yellowColor];

@interface CaptureViewController () <CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIView *locationStatusView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UILabel *latLabel;
@property (weak, nonatomic) IBOutlet UILabel *lngLabel;

@property (strong, nonatomic) AFHTTPClient *serverClient;
@property (weak, nonatomic) IBOutlet UIView *uploadingPanel;
@property (weak, nonatomic) IBOutlet UIProgressView *uploadProgress;

@end

@implementation CaptureViewController


#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *baseURL = [NSURL URLWithString:@"http://wildfire.elasticbeanstalk.com"];
    self.serverClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                        message:@"Please enable location services to use this app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        self.locationStatusView.backgroundColor = BAD_LOCATION_COLOR;
    } else {
        [self startLocationTracking];
    }
}

- (IBAction)photoButtonPressed:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [imagePicker setDelegate:self];
    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];
}

- (void)startLocationTracking
{
    self.locationStatusView.backgroundColor = OK_LOCATION_COLOR;
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    [self.locationManager setDelegate:self];
    [self.locationManager startUpdatingHeading];
    [self.locationManager startUpdatingLocation];
}


#pragma mark - UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    //NSDictionary *metaData = [info valueForKey:UIImagePickerControllerMediaMetadata];
    UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"imageSize = %@", NSStringFromCGSize([originalImage size]));
    [self postImage:[originalImage fixOrientation]];
}

- (void)postImage:(UIImage *)image
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.uploadingPanel.hidden = NO;
    NSNumber *lat = [NSNumber numberWithDouble:self.locationManager.location.coordinate.latitude];
    NSNumber *lng = [NSNumber numberWithDouble:self.locationManager.location.coordinate.longitude];
    NSNumber *heading = [NSNumber numberWithDouble:self.locationManager.heading.magneticHeading];
    
    NSDictionary *dict = @{@"lat"   :   lat,
                           @"lng"   :   lng,
                           @"heading"   :   heading
                           };
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    NSMutableURLRequest *request = [self.serverClient multipartFormRequestWithMethod:@"POST"
                                                                                path:@"upload"
                                                                            parameters:dict
                                                           constructingBodyWithBlock:^(id formData) {
                                                               [formData appendPartWithFileData:imageData name:@"image.jpg" fileName:@"image.jpg" mimeType:@"image/jpeg"];
                                                           }];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesRead, long long totalbytesRead, long long totalBytesExpectedToWrite) {
        self.uploadProgress.progress = (CGFloat)totalbytesRead / totalBytesExpectedToWrite;
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"responseObject: %@", response);
        self.uploadingPanel.hidden = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error uploading image"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        self.uploadingPanel.hidden = YES;
    }];
    
    [operation start];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}


#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.locationStatusView.backgroundColor = BAD_LOCATION_COLOR;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.locationStatusView.backgroundColor = GOOD_LOCATION_COLOR;
    self.latLabel.text = [NSString stringWithFormat:@"%.3f", newLocation.coordinate.latitude];
    self.lngLabel.text = [NSString stringWithFormat:@"%.3f", newLocation.coordinate.longitude];
}

@end
