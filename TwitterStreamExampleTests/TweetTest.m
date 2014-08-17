//
//  TweetTest.m
//  TwitterStreamExample
//
//  Created by Davide De Franceschi on 17/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

@import XCTest;
#import "Tweet.h"

@interface TweetTest : XCTestCase

@property (strong, nonatomic) NSDictionary *exampleDictionary;

@end

@implementation TweetTest

- (void)setUp
{
	[super setUp];
	self.exampleDictionary = @{@"user": @{@"name": @"Test User",
										  @"profile_image_url": @"http://www.example.com/test_img_url.jpg",
										  @"screen_name": @"testuser"},
							   @"text": @"This is a tweet."};
}

- (void)testTweetWithValidDictionary
{
	NSDictionary *testDictionary = self.exampleDictionary;
	Tweet *testTweet = [Tweet tweetWithDictionary:testDictionary];
	XCTAssertNotNil(testTweet, @"Should have returned a not nil Tweet.");
}

- (void)testTweetWithInvalidDictionary
{
	Tweet *testTweet;
	NSDictionary *testDictionary;
	
	testDictionary = @{};
	testTweet = [Tweet tweetWithDictionary:testDictionary];
	XCTAssertNil(testTweet, @"Should have returned a nil Tweet.");
	
	testDictionary = @{@"text": self.exampleDictionary[@"text"]};
	testTweet = [Tweet tweetWithDictionary:testDictionary];
	XCTAssertNil(testTweet, @"Should have returned a nil Tweet.");
	
	testDictionary = @{@"user": self.exampleDictionary[@"user"]};
	testTweet = [Tweet tweetWithDictionary:testDictionary];
	XCTAssertNil(testTweet, @"Should have returned a nil Tweet.");
}

- (void)testTweetWithValidJSONData
{
	NSDictionary *testDictionary = self.exampleDictionary;
	NSError *JSONError;
	NSData *testJSONData = [NSJSONSerialization dataWithJSONObject:testDictionary options:0 error:&JSONError];
	XCTAssertNotNil(testJSONData, @"Error in conversion to JSON (%@).", [JSONError localizedDescription]);
	Tweet *testTweet = [Tweet tweetWithJSONData:testJSONData];
	XCTAssertNotNil(testTweet, @"Should have returned a not nil Tweet.");
}

- (void)testTweetWithInvalidJSONData
{
	Tweet *testTweet;
	NSDictionary *testDictionary;
	NSError *JSONError;
	NSData *testJSONData;
	
	testJSONData = [NSData data];
	testTweet = [Tweet tweetWithJSONData:testJSONData];
	XCTAssertNil(testTweet, @"Should have returned a nil Tweet.");
	
	testDictionary = @{};
	testJSONData = [NSJSONSerialization dataWithJSONObject:testDictionary options:0 error:&JSONError];
	XCTAssertNotNil(testJSONData, @"Error in conversion to JSON (%@).", [JSONError localizedDescription]);
	testTweet = [Tweet tweetWithJSONData:testJSONData];
	XCTAssertNil(testTweet, @"Should have returned a nil Tweet.");
	
	testDictionary = @{@"text": self.exampleDictionary[@"text"]};
	testJSONData = [NSJSONSerialization dataWithJSONObject:testDictionary options:0 error:&JSONError];
	XCTAssertNotNil(testJSONData, @"Error in conversion to JSON (%@).", [JSONError localizedDescription]);
	testTweet = [Tweet tweetWithJSONData:testJSONData];
	XCTAssertNil(testTweet, @"Should have returned a nil Tweet.");
	
	testDictionary = @{@"user": self.exampleDictionary[@"user"]};
	testJSONData = [NSJSONSerialization dataWithJSONObject:testDictionary options:0 error:&JSONError];
	XCTAssertNotNil(testJSONData, @"Error in conversion to JSON (%@).", [JSONError localizedDescription]);
	testTweet = [Tweet tweetWithJSONData:testJSONData];
	XCTAssertNil(testTweet, @"Should have returned a nil Tweet.");
}

@end
