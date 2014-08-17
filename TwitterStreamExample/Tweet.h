//
//  Tweet.h
//  TwitterStreamExample
//
//  Created by Davide De Franceschi on 17/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

@import Foundation;
@import CoreLocation.CLLocation;

@interface TwitterUser : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *profileImageURL;
@property (strong, nonatomic) NSString *screenName;

+ (instancetype)twitterUserWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

#pragma mark -

@interface Tweet : NSObject

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) TwitterUser *user;

+ (instancetype)tweetWithJSONData:(NSData *)data;
+ (instancetype)tweetWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithJSONData:(NSData *)data;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

