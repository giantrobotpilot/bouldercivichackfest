//
//  PictureInfo.m
//  MapView
//
//  Created by Charlie Fish on 6/1/13.
//  Copyright (c) 2013 App-Whiz. All rights reserved.
//

#import "PictureInfo.h"
#import "UIImageView+AFNetworking.h"

@interface PictureInfo ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;

@end

@implementation PictureInfo


- (void)viewDidLoad
{
    [super viewDidLoad];
	//self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageURL]]];
    [self.imageView setImageWithURL:[NSURL URLWithString:self.imageURL]];
    self.headingLabel.text = [NSString stringWithFormat:@"%.1f", self.heading];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
