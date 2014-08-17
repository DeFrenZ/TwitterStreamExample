//
//  TwitterServerTest.m
//  TwitterStreamExample
//
//  Created by Davide De Franceschi on 17/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

@import XCTest;
#import "TwitterServer.h"

#define TEST_TIMEOUT_TIME_S 2.0
#define TEST_TIMEOUT_TIME_NS ((int64_t)(TEST_TIMEOUT_TIME_S * NSEC_PER_SEC))
#pragma mark -

@interface TwitterServerTest : XCTestCase <TwitterServerDelegate>

@property (strong, nonatomic) TwitterFakeServer *exampleServer;
@property (strong, nonatomic) NSMutableArray *exampleTweetsReceived;

@end

@implementation TwitterServerTest

#pragma mark TwitterServerDelegate

- (void)twitterServer:(TwitterServer *)server didReceiveTweet:(Tweet *)tweet
{
	[self.exampleTweetsReceived addObject:tweet];
}

#pragma mark XCTestCase

- (void)setUp
{
	[super setUp];
	self.exampleServer = [TwitterFakeServer twitterFakeServerWithTweet:[Tweet tweetWithDictionary:@{@"user": @{@"name": @"Test User", @"profile_image_url": @"http://www.example.com/test_img_url.jpg", @"screen_name": @"testuser"}, @"text": @"This is a tweet."}] andInterval:0.1];
	self.exampleServer.delegate = self;
	self.exampleTweetsReceived = [@[] mutableCopy];
}

#pragma mark TwitterServerTest

- (void)testServerInitialization
{
	TwitterServer *server;
	server = [TwitterServer new];
	XCTAssertNotNil(server, @"Should have returned a not nil TwitterServer.");
	XCTAssertTrue([server isMemberOfClass:[TwitterServer class]], @"Should have returned a TwitterServer instance instead of a %@ one.", [server class]);
	
	server = [TwitterFakeServer new];
	XCTAssertNotNil(server, @"Should have returned a not nil TwitterServer.");
	XCTAssertTrue([server isMemberOfClass:[TwitterFakeServer class]], @"Should have returned a TwitterFakeServer instance instead of a %@ one.", [server class]);
	
	server = [TwitterFakeServer twitterFakeServerWithTweet:nil andInterval:0];
	XCTAssertNotNil(server, @"Should have returned a not nil TwitterServer.");
	XCTAssertTrue([server isMemberOfClass:[TwitterFakeServer class]], @"Should have returned a TwitterFakeServer instance instead of a %@ one.", [server class]);
}

- (void)testServerStreaming
{
	[self.exampleServer sendStreamingRequestWithParameters:@{}];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, TEST_TIMEOUT_TIME_NS), dispatch_get_main_queue(), ^{
		XCTAssertTrue([self.exampleTweetsReceived count] > 0, @"Should have received at least 1 Tweet from the server in %f seconds.", TEST_TIMEOUT_TIME_S);
	});
}

- (void)testServerStopping
{
	[self.exampleServer sendStreamingRequestWithParameters:@{}];
	[self.exampleServer stopStreaming];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, TEST_TIMEOUT_TIME_NS), dispatch_get_main_queue(), ^{
		XCTAssertTrue([self.exampleTweetsReceived count] == 0, @"Should have not received any Tweet from the server in %f seconds, instead it received %d.", TEST_TIMEOUT_TIME_S, [self.exampleTweetsReceived count]);
	});
}

@end
