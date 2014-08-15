//
//  TweetCell.m
//  TwitterStreamExample
//
//  Created by Davide De Franceschi on 13/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "TweetCell.h"


@implementation TweetCell

#pragma mark - TweetCell

- (void)loadProfileImage
{
	if (self.profileImageURL != nil) {
		if (self.profileImageCache != nil) {
			UIImage *profileImage = [self.profileImageCache objectForKey:self.profileImageURL];
			if (profileImage != nil) {
				[self.profileImageView setImage:profileImage];
			} else {
#warning Could use the popular SDWebImage library but wanted to do without using 3rd party libraries for now
#warning Could make the download with NSURLConnection to be less computationally expensive
#warning Could make a UIActivityIndicatorView appear while downloading the profile image
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
					NSData *profileImageData = [NSData dataWithContentsOfURL:self.profileImageURL];
					UIImage *downloadedProfileImage = [UIImage imageWithData:profileImageData];
					dispatch_sync(dispatch_get_main_queue(), ^{
						[self.profileImageView setImage:downloadedProfileImage];
					});
				});
			}
		} else {
			NSLog(@"Trying to retrieve the profile image without having a cache set.");
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
