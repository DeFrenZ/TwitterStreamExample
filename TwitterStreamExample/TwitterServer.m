//
//  TwitterServer.m
//  TwitterStreamExample
//
//  Created by Davide De Franceschi on 17/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "TwitterServer.h"

@interface TwitterServer ()

@property (strong, nonatomic) NSURLConnection *connection;

@end

@implementation TwitterServer

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	Tweet *receivedTweet = [Tweet tweetWithJSONData:data];
	if (receivedTweet != nil) {
		NSLog(@"Received and correctly parsed %d bytes of data.", [data length]);
		if (self.delegate != nil) [self.delegate twitterServer:self didReceiveTweet:receivedTweet];
	}
}

#pragma mark TwitterServer

static NSString *serviceURLStreaming = @"https://stream.twitter.com/1.1/statuses/filter.json";

- (void)sendStreamingRequestWithParameters:(NSDictionary *)requestParameters
{
	if (self.account == nil) {
		NSLog(@"Cannot send a request without an account.");
		return;
	}
	
	NSURL *requestURL = [NSURL URLWithString:serviceURLStreaming];
	SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:requestURL parameters:requestParameters];
	request.account = self.account;
	
	if (self.connection != nil) {
		NSLog(@"WARNING: Possibly overwriting another active connection.");
	}
	self.connection = [NSURLConnection connectionWithRequest:[request preparedURLRequest] delegate:self];
	[self.connection start];
}

- (void)stopStreaming
{
	if (self.connection != nil) {
		[self.connection cancel];
		self.connection = nil;
	}
}

@end

#pragma mark -

@interface TwitterFakeServer ()

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation TwitterFakeServer

#pragma mark Initializations

- (instancetype)initWithTweet:(Tweet *)tweet andInterval:(NSTimeInterval)interval
{
	self = [super init];
	if (self) {
		_fakeTweet = tweet;
		_timeInterval = interval;
	}
	return self;
}

+ (instancetype)twitterFakeServerWithTweet:(Tweet *)tweet andInterval:(NSTimeInterval)interval
{
	return [[self alloc] initWithTweet:tweet andInterval:interval];
}

#pragma mark TwitterFakeServer

- (void)sendStreamingRequestWithParameters:(NSDictionary *)requestParameters
{
	self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(sendFakeTweet) userInfo:nil repeats:YES];
}

- (void)stopStreaming
{
	[self.timer invalidate];
}

- (void)sendFakeTweet
{
	if (self.delegate != nil) [self.delegate twitterServer:self didReceiveTweet:self.fakeTweet];
}

@end
