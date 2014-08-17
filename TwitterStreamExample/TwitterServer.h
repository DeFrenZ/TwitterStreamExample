//
//  TwitterServer.h
//  TwitterStreamExample
//
//  Created by Davide De Franceschi on 17/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

@import Foundation;
@import Accounts.ACAccount;
@import Social;
#import "Tweet.h"

@protocol TwitterServerDelegate;

#pragma mark -

@interface TwitterServer : NSObject <NSURLConnectionDelegate>

@property (strong, nonatomic) ACAccount *account;
@property (weak, nonatomic) id<TwitterServerDelegate> delegate;

- (void)sendStreamingRequestWithParameters:(NSDictionary *)requestParameters;
- (void)stopStreaming;

@end

#pragma mark -

@interface TwitterFakeServer : TwitterServer

@property (strong, nonatomic) Tweet *fakeTweet;
@property NSTimeInterval timeInterval;

+ (instancetype)twitterFakeServerWithTweet:(Tweet *)tweet andInterval:(NSTimeInterval)interval;
- (instancetype)initWithTweet:(Tweet *)tweet andInterval:(NSTimeInterval)interval;

@end

#pragma mark -

@protocol TwitterServerDelegate <NSObject>

- (void)twitterServer:(TwitterServer *)server didReceiveTweet:(Tweet *)tweet;

@end
