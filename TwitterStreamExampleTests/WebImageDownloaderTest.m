//
//  WebImageDownloaderTest.m
//  TwitterStreamExample
//
//  Created by Davide De Franceschi on 17/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

@import XCTest;
#import "WebImageDownloader.h"

#define TEST_TIMEOUT_TIME_S 2.0
#define TEST_TIMEOUT_TIME_NS ((int64_t)(TEST_TIMEOUT_TIME_S * 1000000000))
#pragma mark -

@interface WebImageDownloaderTest : XCTestCase

@property (strong, nonatomic) WebImageDownloader *exampleDownloader;
@property (strong, nonatomic) NSURL *exampleImageURL;
@property (strong, nonatomic) NSURL *exampleDifferentImageURL;
@property (strong, nonatomic) NSURL *exampleWrongURL;

@end

@implementation WebImageDownloaderTest

- (void)setUp
{
	[super setUp];
	
	self.exampleDownloader = [WebImageDownloader new];
	self.exampleImageURL = [NSURL URLWithString:@"http://www.google.com/trends/resources/2327917647-google-icon.png"];
	self.exampleDifferentImageURL = [NSURL URLWithString:@"http://www.google.com/intl/en-GB/homepage/images/google_favicon_64.png"];
	self.exampleWrongURL = [NSURL URLWithString:@"http://www.example.com/test_img_url.jpg"];
}

- (void)testDownloaderInitialization
{
	WebImageDownloader *downloader;
	downloader = [WebImageDownloader new];
	XCTAssertNotNil(downloader, @"Should have returned a not nil WebImageDownloader.");
	
	downloader = [[WebImageDownloader alloc] initWithCache:nil];
	XCTAssertNotNil(downloader, @"Should have returned a not nil WebImageDownloader.");
	
	downloader = [[WebImageDownloader alloc] initWithCache:[NSCache new]];
	XCTAssertNotNil(downloader, @"Should have returned a not nil WebImageDownloader.");
}

- (void)testDownloaderWithValidURL
{
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	
	[self.exampleDownloader downloadImageFromURL:self.exampleImageURL completion:^(UIImage *downloadedImage) {
		XCTAssertNotNil(downloadedImage, @"Should have returned a not nil UIImage. To test if the image is still available online go to %@", [self.exampleImageURL absoluteString]);
		dispatch_semaphore_signal(semaphore);
	}];
	
	if (dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, TEST_TIMEOUT_TIME_NS))) {
		XCTFail(@"Asynchronous test %s did not finish within the timeout of %f seconds.", __PRETTY_FUNCTION__, TEST_TIMEOUT_TIME_S);
	}
}

- (void)testDownloaderWithInvalidURL
{
	dispatch_group_t semaphores = dispatch_group_create();
	
	dispatch_group_enter(semaphores);
	[self.exampleDownloader downloadImageFromURL:nil completion:^(UIImage *downloadedImage) {
		XCTAssertNil(downloadedImage, @"Should have returned a nil UIImage");
		dispatch_group_leave(semaphores);
	}];
	
	dispatch_group_enter(semaphores);
	[self.exampleDownloader downloadImageFromURL:self.exampleWrongURL completion:^(UIImage *downloadedImage) {
		XCTAssertNil(downloadedImage, @"Should have returned a nil UIImage");
		dispatch_group_leave(semaphores);
	}];
	
	if (dispatch_group_wait(semaphores, dispatch_time(DISPATCH_TIME_NOW, TEST_TIMEOUT_TIME_NS))) {
		XCTFail(@"Asynchronous test %s did not finish within the timeout of %f seconds.", __PRETTY_FUNCTION__, TEST_TIMEOUT_TIME_S);
	}
}

- (void)testDownloaderCacheHit
{
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	
	__block UIImage *testImage;
	[self.exampleDownloader downloadImageFromURL:self.exampleImageURL completion:^(UIImage *downloadedImage) {
		XCTAssertNotNil(downloadedImage, @"Should have returned a not nil UIImage. To test if the image is still available online go to %@", [self.exampleImageURL absoluteString]);
		testImage = downloadedImage;
		dispatch_semaphore_signal(semaphore);
	}];
	
	if (dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, TEST_TIMEOUT_TIME_NS))) {
		XCTFail(@"Asynchronous test %s did not finish within the timeout of %f seconds.", __PRETTY_FUNCTION__, TEST_TIMEOUT_TIME_S);
	}
	
	[self.exampleDownloader downloadImageFromURL:self.exampleImageURL completion:^(UIImage *downloadedImage) {
		XCTAssertNotNil(downloadedImage, @"Should have returned a not nil UIImage. It should have been retrieved from the downloader's cache.");
		XCTAssertEqual(downloadedImage, testImage, @"The UIImage returned should be the same that was just dowloaded.");
		dispatch_semaphore_signal(semaphore);
	}];
	
	if (dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, TEST_TIMEOUT_TIME_NS))) {
		XCTFail(@"Asynchronous test %s did not finish within the timeout of %f seconds.", __PRETTY_FUNCTION__, TEST_TIMEOUT_TIME_S);
	}
}

- (void)testDownloaderCacheMiss
{
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	
	__block UIImage *testImage;
	[self.exampleDownloader downloadImageFromURL:self.exampleImageURL completion:^(UIImage *downloadedImage) {
		XCTAssertNotNil(downloadedImage, @"Should have returned a not nil UIImage. To test if the image is still available online go to %@", [self.exampleImageURL absoluteString]);
		testImage = downloadedImage;
		dispatch_semaphore_signal(semaphore);
	}];
	
	if (dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, TEST_TIMEOUT_TIME_NS))) {
		XCTFail(@"Asynchronous test %s did not finish within the timeout of %f seconds.", __PRETTY_FUNCTION__, TEST_TIMEOUT_TIME_S);
	}
	
	[self.exampleDownloader downloadImageFromURL:self.exampleDifferentImageURL completion:^(UIImage *downloadedImage) {
		XCTAssertNotNil(downloadedImage, @"Should have returned a not nil UIImage. To test if the image is still available online go to %@", [self.exampleDifferentImageURL absoluteString]);
		XCTAssertNotEqual(downloadedImage, testImage, @"The UIImage returned should be different from the one which was just dowloaded.");
		dispatch_semaphore_signal(semaphore);
	}];
	
	if (dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, TEST_TIMEOUT_TIME_NS))) {
		XCTFail(@"Asynchronous test %s did not finish within the timeout of %f seconds.", __PRETTY_FUNCTION__, TEST_TIMEOUT_TIME_S);
	}
}

@end
