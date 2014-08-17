//
//  ViewController.h
//  TwitterStreamExample
//
//  Created by Davide De Franceschi on 12/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

@import UIKit;
@import Accounts;
#import "TwitterServer.h"

@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, TwitterServerDelegate>
@end
