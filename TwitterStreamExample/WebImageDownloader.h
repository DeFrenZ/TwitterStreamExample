//
//  WebImageDownloader.h
//  TwitterStreamExample
//
//  Created by Davide De Franceschi on 17/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

@import Foundation;

@interface WebImageDownloader : NSObject

- (instancetype)init;
- (instancetype)initWithCache:(NSCache *)cache;

- (void)downloadImageFromURL:(NSURL *)imageURL completion:(void (^)(UIImage *downloadedImage))completion;

@end
