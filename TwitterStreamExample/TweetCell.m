//
//  TweetCell.m
//  TwitterStreamExample
//
//  Created by Davide De Franceschi on 13/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "TweetCell.h"


@interface TweetCell ()

@end


@implementation TweetCell

#pragma mark - UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - TweetCell

- (void)loadProfileImage
{
#warning load profileImage from profileImageURL and set on profileImageView
}

- (void)setAndLoadProfileImageFromURL:(NSURL *)URL
{
	self.profileImageURL = URL;
	[self loadProfileImage];
}


@end
