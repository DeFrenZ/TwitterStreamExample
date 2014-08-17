//
//  WebImageDownloader.m
//  TwitterStreamExample
//
//  Created by Davide De Franceschi on 17/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "WebImageDownloader.h"

@interface WebImageDownloader ()

@property (strong, nonatomic) NSCache *imageCache;

@end

@implementation WebImageDownloader

#pragma mark Initializations

- (instancetype)init
{
	return [self initWithCache:[NSCache new]];
}

- (instancetype)initWithCache:(NSCache *)cache
{
	self = [super init];
	if (self) {
		_imageCache = cache;
	}
	return self;
}

#pragma mark WebImageDownloader

- (void)downloadImageFromURL:(NSURL *)imageURL completion:(void (^)(UIImage *))completion
{
#warning Could make the download with NSURLConnection to be less computationally expensive
	if (imageURL == nil) completion(nil);
	else {
		UIImage *cachedProfileImage = [self.imageCache objectForKey:imageURL];
		if (cachedProfileImage != nil) {
			completion(cachedProfileImage);
		} else {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
				UIImage *downloadedImage = [UIImage imageWithData:imageData];
				if (downloadedImage != nil) [self.imageCache setObject:downloadedImage forKey:imageURL];
				if (completion != nil) completion(downloadedImage);
			});
		}
	}
}

@end
