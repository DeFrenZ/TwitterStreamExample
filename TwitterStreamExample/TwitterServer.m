//
//  TwitterServer.m
//  TwitterStreamExample
//
//  Created by Davide De Franceschi on 17/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "TwitterServer.h"

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
	
	NSURLConnection *connection = [NSURLConnection connectionWithRequest:[request preparedURLRequest] delegate:self];
	[connection start];
}

@end

#pragma mark -

@implementation TwitterFakeServer

- (void)sendStreamingRequestWithParameters:(NSDictionary *)requestParameters
{
#warning repeatedly send self.fakeTweet at timeInterval intervals
}

@end
