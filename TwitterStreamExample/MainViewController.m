//
//  ViewController.m
//  TwitterStreamExample
//
//  Created by Davide De Franceschi on 12/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "MainViewController.h"

#define ALPHA_TRANSPARENT 0.0
#define ALPHA_OPAQUE 1.0
#define LOADING_ANIMATION_DURATION 0.4
#define LOADING_VIEW_CORNER_RADIUS 20.0


@interface MainViewController ()

@property (strong, nonatomic) NSArray *twitterAccountsList;
@property (strong, nonatomic) ACAccount *twitterAccount;
@property (strong, nonatomic) NSArray *tweetsArray;

@property (strong, nonatomic) IBOutlet UIButton *accountSelectionButton;
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UITableView *twitterTableView;
- (IBAction)accountSelectionButtonPressed:(id)sender;

@end


@implementation MainViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.tweetsArray count];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellID = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
	}
	
	id cellData = [self.tweetsArray objectAtIndex:[indexPath row]];
	// set cellData in cell
	return cell;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == [actionSheet cancelButtonIndex]) {
		self.twitterAccount = nil;
	} else {
		ACAccount *selectedAccount = [self.twitterAccountsList objectAtIndex:buttonIndex];
		self.twitterAccount = selectedAccount;
		[self didSetTwitterAccount];
	}
}

#pragma mark - UIButton

- (IBAction)accountSelectionButtonPressed:(id)sender
{
	[self requestTwitterAccount];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self.loadingView.layer setCornerRadius:LOADING_VIEW_CORNER_RADIUS];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MainViewController (Loading)

- (void)startLoading
{
	[self.view setUserInteractionEnabled:NO];
	[UIView animateWithDuration:LOADING_ANIMATION_DURATION animations:^{
		[self.loadingView setAlpha:ALPHA_OPAQUE];
	}];
}

- (void)finishLoading
{
	[UIView animateWithDuration:LOADING_ANIMATION_DURATION animations:^{
		[self.loadingView setAlpha:ALPHA_TRANSPARENT];
	} completion:^(BOOL finished) {
		[self.view setUserInteractionEnabled:YES];
	}];
}

#pragma mark - MainViewController (Twitter)

- (void)createTwitterAccount
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No twitter account" message:@"Please set a twitter account from your settings page" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

- (void)selectTwitterAccountFromArray:(NSArray *)accountList
{
	self.twitterAccountsList = accountList;
	
	UIActionSheet *accountSelectionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a Twitter account" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	for (ACAccount *currentAccount in accountList) {
		[accountSelectionSheet addButtonWithTitle:[currentAccount username]];
	}
	accountSelectionSheet.cancelButtonIndex = [accountSelectionSheet addButtonWithTitle:@"Cancel"];
	[accountSelectionSheet showInView:[self view]];
}

- (void)retrieveTwitterAccountFromStore:(ACAccountStore *)accounts ofType:(ACAccountType *)accountType
{
	NSArray *twitterAccounts = [accounts accountsWithAccountType:accountType];
	NSUInteger numberOfTwitterAccounts = [twitterAccounts count];
	if (numberOfTwitterAccounts == 0) {
		[self createTwitterAccount];
	} else if (numberOfTwitterAccounts > 1) {
		[self selectTwitterAccountFromArray:twitterAccounts];
	} else {
		self.twitterAccount = [twitterAccounts firstObject];
		[self didSetTwitterAccount];
	}
}

- (void)requestTwitterAccount
{
	ACAccountStore *accounts = [ACAccountStore new];
	ACAccountType *accountType = [accounts accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	[self startLoading];
	[accounts requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self finishLoading];
			
			if (granted) {
				[self retrieveTwitterAccountFromStore:accounts ofType:accountType];
			} else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Access not granted" message:@"To use the app please go into the Privacy section and enable the use of twitter for this app" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
			}
		});
	}];
}

- (void)didSetTwitterAccount
{
	NSLog(@"Twitter account selected: %@", [self.twitterAccount username]);
}

- (void)sendRequestWithTwitterAccount:(ACAccount *)account
{
#warning change service to access to
	NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
	NSDictionary *parameters = @{@"screen_name" : @"@techotopia",
								 @"include_rts" : @"0",
								 @"trim_user" : @"1",
								 @"count" : @"20"};
	SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestURL parameters:parameters];
	postRequest.account = account;
	
	[postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		self.tweetsArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
		
		if (self.tweetsArray.count != 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.twitterTableView reloadData];
			});
		}
	}];
}


@end
