//
//  ViewController.m
//  TwitterStreamExample
//
//  Created by Davide De Franceschi on 12/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "MainViewController.h"
#import "TweetCell.h"
#import "Tweet.h"
#import "WebImageDownloader.h"

#define ALPHA_TRANSPARENT 0.0
#define ALPHA_OPAQUE 1.0
#define FADING_ANIMATION_DURATION 0.4
#define TABLE_CELL_SEPARATOR_HEIGHT 1.0
#define STATUS_BAR_HEIGHT 20.0
#define LOADING_VIEW_CORNER_RADIUS 20.0
#define NUMBER_OF_TWEETS_SHOWN 10
#pragma mark -

@interface MainViewController ()

@property (strong, nonatomic) WebImageDownloader *profileImagesDownloader;
@property (strong, nonatomic) TwitterServer *twitterServer;
@property (strong, nonatomic) NSArray *twitterAccountsList;
@property (strong, nonatomic) NSMutableArray *tweetsArray;
@property (strong, nonatomic) TweetCell *prototypeCell;

@property (strong, nonatomic) IBOutlet UIButton *accountSelectionButton;
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UITableView *twitterTableView;
- (IBAction)accountSelectionButtonPressed:(id)sender;

@end


@implementation MainViewController

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.tweetsArray count];
}

#pragma mark UITableViewDelegate

static NSString *cellID = @"Cell";

- (TweetCell *)prototypeCell
{
	if (!_prototypeCell) {
		_prototypeCell = [self.twitterTableView dequeueReusableCellWithIdentifier:cellID];
	}
	return _prototypeCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#warning could be made faster by getting the constraints' lenghts and using sizeWithFont:
	[self configureCell:self.prototypeCell forRowAtIndexPath:indexPath];
	[self.prototypeCell layoutIfNeeded];
	
	CGSize cellSize = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
	return cellSize.height + TABLE_CELL_SEPARATOR_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#warning could make the first cell appear as an UIActivityIndicatorView to let the user know it is doing something (waiting for tweets)
	TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	[self configureCell:cell forRowAtIndexPath:indexPath];
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([cell isKindOfClass:[TweetCell class]]) {
		TweetCell *tweetCell = (TweetCell *)cell;
		tweetCell.profileImageDownloader = self.profileImagesDownloader;
		Tweet *cellData = self.tweetsArray[[indexPath row]];
		
		[tweetCell setAndLoadProfileImageFromURL:cellData.user.profileImageURL];
		[tweetCell.usernameLabel setText:cellData.user.name];
		[tweetCell.screenNameLabel setText:[NSString stringWithFormat:@"@%@", cellData.user.screenName]];
		[tweetCell.tweetTextLabel setText:cellData.text];
	}
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	ACAccount *selectedAccount;
	if (buttonIndex == [actionSheet cancelButtonIndex]) {
		selectedAccount = nil;
	} else {
		selectedAccount = self.twitterAccountsList[buttonIndex];
	}
	[self didSetTwitterAccount:selectedAccount];
}

#pragma mark TwitterServerDelegate

- (void)twitterServer:(TwitterServer *)server didReceiveTweet:(Tweet *)tweet
{
	[self addTweet:tweet];
}

#pragma mark UIButton

- (IBAction)accountSelectionButtonPressed:(id)sender
{
	[self requestTwitterAccount];
}

#pragma mark UIViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.tweetsArray = [NSMutableArray arrayWithCapacity:NUMBER_OF_TWEETS_SHOWN];
	self.profileImagesDownloader = [WebImageDownloader new];
#warning Could use the popular SDWebImage library but wanted to do without using 3rd party libraries for now
	self.twitterServer = [TwitterServer new];
	[self.twitterServer setDelegate:self];
	
	[self.loadingView.layer setCornerRadius:LOADING_VIEW_CORNER_RADIUS];
	[self.twitterTableView setContentInset:UIEdgeInsetsMake(STATUS_BAR_HEIGHT, self.twitterTableView.contentInset.left, self.twitterTableView.contentInset.bottom, self.twitterTableView.contentInset.right)];
}

#warning Ignored didReceiveMemoryWarning as the maximum NSCache size is very small

#pragma mark MainViewController

- (void)showTableView:(BOOL)showTable
{
	[self.view setUserInteractionEnabled:NO];
	[UIView animateWithDuration:FADING_ANIMATION_DURATION animations:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.twitterTableView setAlpha:(showTable)? ALPHA_OPAQUE : ALPHA_TRANSPARENT];
			[self.accountSelectionButton setAlpha:(showTable)? ALPHA_TRANSPARENT : ALPHA_OPAQUE];
		});
	} completion:^(BOOL finished) {
		[self.view setUserInteractionEnabled:YES];
	}];
}

- (void)addTweet:(Tweet *)tweet
{
	[self.tweetsArray insertObject:tweet atIndex:0];
	
	[self.twitterTableView beginUpdates]; {
		if ([self.tweetsArray count] > NUMBER_OF_TWEETS_SHOWN) {
			[self.twitterTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(NUMBER_OF_TWEETS_SHOWN - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
			[self.tweetsArray removeLastObject];
		}
		[self.twitterTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
	} [self.twitterTableView endUpdates];
}

#pragma mark MainViewController (Loading)

- (void)startLoading
{
	[self.view setUserInteractionEnabled:NO];
	[UIView animateWithDuration:FADING_ANIMATION_DURATION animations:^{
		[self.loadingView setAlpha:ALPHA_OPAQUE];
	}];
}

- (void)finishLoading
{
	[UIView animateWithDuration:FADING_ANIMATION_DURATION animations:^{
		[self.loadingView setAlpha:ALPHA_TRANSPARENT];
	} completion:^(BOOL finished) {
		[self.view setUserInteractionEnabled:YES];
	}];
}

#pragma mark MainViewController (Twitter)

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
		[self didSetTwitterAccount:twitterAccounts[0]];
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

- (void)didSetTwitterAccount:(ACAccount *)account
{
	NSLog(@"Twitter account selected: %@", [account username]);
	[self.twitterServer setAccount:account];
	if (account != nil) {
		[self showTableView:YES];
		[self.twitterServer sendStreamingRequestWithParameters:@{@"track": @"banking"}];
	}
}

@end
