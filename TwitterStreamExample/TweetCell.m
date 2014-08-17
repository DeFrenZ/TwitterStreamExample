//
//  TweetCell.m
//  TwitterStreamExample
//
//  Created by Davide De Franceschi on 13/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "TweetCell.h"

@implementation TweetCell

#pragma mark TweetCell

- (void)loadProfileImage
{
	if (self.profileImageURL != nil) {
		if (self.profileImageDownloader != nil) {
#warning Could make a UIActivityIndicatorView appear while downloading the profile image
			[self.profileImageDownloader downloadImageFromURL:self.profileImageURL completion:^(UIImage *downloadedImage) {
				[self.profileImageView setImage:downloadedImage];
			}];
		} else {
			NSLog(@"Trying to retrieve the profile image without having a downloader set.");
		}
	} else {
		NSLog(@"Trying to retrieve the profile image without having an URL.");
	}
}

- (void)setAndLoadProfileImageFromURL:(NSURL *)URL
{
	self.profileImageURL = URL;
	[self loadProfileImage];
}

@end
