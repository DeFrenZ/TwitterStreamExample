//
//  Tweet.m
//  TwitterStreamExample
//
//  Created by Davide De Franceschi on 17/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "Tweet.h"

#define IF_NIL_RETURN_NIL_AND_LOG(value) if (value == nil) { NSLog(@"A parameter is nil in %s", __PRETTY_FUNCTION__); return nil; }
#define SET_VAR_OF_TYPE_OR_RETURN_NIL_AND_LOG(var, vartype, value) if (value == nil) { NSLog(@"Trying to set %s in %s but parameter is nil", #var, __PRETTY_FUNCTION__); return nil; } else if (![value isKindOfClass:[vartype class]]) { NSLog(@"Trying to set %s as a %@ in %s but parameter is a %@", #var, [vartype class], __PRETTY_FUNCTION__, [value class]); return nil; } else { var = value; }
#pragma mark -

@interface TwitterUser ()

@property (strong, nonatomic) NSDictionary *dictionary;

@end

@implementation TwitterUser

#pragma mark Initializations

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self) {
		IF_NIL_RETURN_NIL_AND_LOG(dictionary)
		SET_VAR_OF_TYPE_OR_RETURN_NIL_AND_LOG(_name, NSString, dictionary[@"name"])
		SET_VAR_OF_TYPE_OR_RETURN_NIL_AND_LOG(_profileImageURL, NSURL, [NSURL URLWithString:dictionary[@"profile_image_url"]])
		SET_VAR_OF_TYPE_OR_RETURN_NIL_AND_LOG(_screenName, NSString, dictionary[@"screen_name"])
	}
	return self;
}

+ (instancetype)twitterUserWithDictionary:(NSDictionary *)dictionary
{
	return [[self alloc] initWithDictionary:dictionary];
}

@end

#pragma mark -

@interface Tweet ()

@property (strong, nonatomic) NSData *JSONData;
@property (strong, nonatomic) NSDictionary *dictionary;

@end

@implementation Tweet

#pragma mark Initializations

- (instancetype)initWithJSONData:(NSData *)data
{
	IF_NIL_RETURN_NIL_AND_LOG(data)
	NSError *JSONError;
	NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONError];
	if (dataDictionary == nil) {
		NSLog(@"Error in JSON parsing while initializing a %@ object (%@). Data was %d bytes.", [self class], [JSONError localizedDescription], [data length]);
		return nil;
	}
	
	return [self initWithDictionary:dataDictionary];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self) {
		IF_NIL_RETURN_NIL_AND_LOG(dictionary)
		SET_VAR_OF_TYPE_OR_RETURN_NIL_AND_LOG(_text, NSString, dictionary[@"text"])
		SET_VAR_OF_TYPE_OR_RETURN_NIL_AND_LOG(_user, TwitterUser, [TwitterUser twitterUserWithDictionary:dictionary[@"user"]])
	}
	return self;
}

+ (instancetype)tweetWithJSONData:(NSData *)data
{
	return [[self alloc] initWithJSONData:data];
}

+ (instancetype)tweetWithDictionary:(NSDictionary *)dictionary
{
	return [[self alloc] initWithDictionary:dictionary];
}

@end
