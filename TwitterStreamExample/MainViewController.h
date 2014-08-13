//
//  ViewController.h
//  TwitterStreamExample
//
//  Created by Davide De Franceschi on 12/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>


@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, NSURLConnectionDataDelegate>
@end
