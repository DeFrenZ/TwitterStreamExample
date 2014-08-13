//
//  TweetCell.h
//  TwitterStreamExample
//
//  Created by Davide De Franceschi on 13/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TweetCell : UITableViewCell

@property (strong, nonatomic) NSURL *profileImageURL;

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *tweetTextLabel;


- (void)loadProfileImage;
- (void)setAndLoadProfileImageFromURL:(NSURL *)URL;


@end
