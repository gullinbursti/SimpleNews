//
//  SNComposerViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.14.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <FBiOSSDK/FacebookSDK.h>

#import "SNComposerViewController_iPhone.h"
#import "SNAppDelegate.h"

#import "SNHeaderView_iPhone.h"
#import "SNNavDoneBtnView.h"
#import "SNNavBackBtnView.h"

#import "SNComposeTypeView_iPhone.h"
#import "SNComposeSourceView_iPhone.h"
#import "SNComposeFriendsView_iPhone.h"

@interface SNComposerViewController_iPhone() <FBFriendPickerDelegate>
@property (strong, nonatomic) FBFriendPickerViewController *friendPickerController;
@end

@implementation SNComposerViewController_iPhone

@synthesize friendPickerController = _friendPickerController;

- (id)initWithArticleVO:(SNArticleVO *)vo
{
	if ((self = [super init])) {
		_vo = vo;
		_composeState = 0;
		_isFriendsSource = NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_composeTypeSticker:) name:@"COMPOSE_TYPE_STICKER" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_composeTypeQuote:) name:@"COMPOSE_TYPE_QUOTE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_composeSourceFriends:) name:@"COMPOSE_SOURCE_FRIENDS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_fbUserPressed:) name:@"FB_USER_PRESSED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_composeSubmitted:) name:@"COMPOSE_SUBMITTED" object:nil];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)loadView
{
	[super loadView];
	//[self.view setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.85]];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_timeline.png"];
	[self.view addSubview:bgImgView];
	
	_headerView = [[SNHeaderView_iPhone alloc] initWithTitle:@"Composer"];
	[self.view addSubview:_headerView];	
	
	_backBtnView = [[SNNavBackBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 64.0, 44.0)];
	[[_backBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	
	SNNavDoneBtnView *doneBtnView = [[SNNavDoneBtnView alloc] initWithFrame:CGRectMake(256.0, 0.0, 64.0, 44.0)];
	[[doneBtnView btn] addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:doneBtnView];
	
	_composeSourceView = [[SNComposeSourceView_iPhone alloc] initWithFrame:CGRectOffset(self.view.frame, 0.0, 45.0)];
	[self.view addSubview:_composeSourceView];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Notifications
- (void)_composeSourceFriends:(NSNotification *)notification {
	_composeState++;
	_isFriendsSource = YES;
	[_headerView addSubview:_backBtnView];
	
//	[_composeSourceView removeFromSuperview];
//	_composeFriendsView = [[SNComposeFriendsView_iPhone alloc] initWithFrame:CGRectOffset(self.view.frame, 0.0, 45.0)];
//	[self.view addSubview:_composeFriendsView];
	
	self.friendPickerController = [[FBFriendPickerViewController alloc] initWithNibName:nil bundle:nil];
	self.friendPickerController.delegate = self;
	self.friendPickerController.title = @"Select friends";
	self.friendPickerController.view.frame = CGRectOffset(self.friendPickerController.view.frame, 0.0, 45.0);
	
	ABAddressBookCreate();
	ABPersonSortOrdering sortOrdering = ABPersonGetSortOrdering();
	ABPersonCompositeNameFormat nameFormat = ABPersonGetCompositeNameFormat();
	
	self.friendPickerController.sortOrdering = (sortOrdering == kABPersonSortByFirstName) ? FBFriendSortByFirstName : FBFriendSortByLastName;
	self.friendPickerController.displayOrdering = (nameFormat == kABPersonCompositeNameFormatFirstNameFirst) ? FBFriendDisplayByFirstName : FBFriendDisplayByLastName;
	
	[self.friendPickerController loadData];
	[self.navigationController pushViewController:self.friendPickerController animated:NO];
}


- (void)_fbUserPressed:(NSNotification *)notification {
	_composeState++;
	
	[_composeFriendsView removeFromSuperview];
	_composeEditorView = [[SNComposeEditorView_iPhone alloc] initWithFrame:CGRectOffset(self.view.frame, 0.0, 45.0) withFriend:(NSDictionary *)[notification object]];
	[self.view addSubview:_composeEditorView];
}


- (void)_composeSubmitted:(NSNotification *)notification {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Navigation
-(void)_goBack {
	_composeState--;
	
	switch (_composeState) {
		case 0:
			[_backBtnView removeFromSuperview];
			[_composeFriendsView removeFromSuperview];
			[self.view addSubview:_composeSourceView];
			break;
			
		case 1:
			[_composeEditorView removeFromSuperview];
			
			if (_isFriendsSource) {
				self.friendPickerController = [[FBFriendPickerViewController alloc] initWithNibName:nil bundle:nil];
				self.friendPickerController.delegate = self;
				self.friendPickerController.title = @"Select friends";
				
				ABAddressBookCreate();
				ABPersonSortOrdering sortOrdering = ABPersonGetSortOrdering();
				ABPersonCompositeNameFormat nameFormat = ABPersonGetCompositeNameFormat();
				
				self.friendPickerController.sortOrdering = (sortOrdering == kABPersonSortByFirstName) ? FBFriendSortByFirstName : FBFriendSortByLastName;
				self.friendPickerController.displayOrdering = (nameFormat == kABPersonCompositeNameFormatFirstNameFirst) ? FBFriendDisplayByFirstName : FBFriendDisplayByLastName;
				
				[self.friendPickerController loadData];
				[self.navigationController pushViewController:self.friendPickerController animated:NO];
			}
			
			break;
	}
}

-(void)_goDone {
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark - FBFriendPickerDelegate methods
- (void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker {
	_fiendsList = friendPicker.selection;
	[friendPicker.navigationController popViewControllerAnimated:NO];
	
	_composeState++;
	
	id<FBGraphUser> friend = [_fiendsList objectAtIndex:0];
	
	NSString *largeImgURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", friend.id];
	NSDictionary *friendDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:friend.id, friend.name, largeImgURL, nil] forKeys:[NSArray arrayWithObjects:@"id", @"name", @"lg_image", nil]];
	
	
	[_composeFriendsView removeFromSuperview];
	_composeEditorView = [[SNComposeEditorView_iPhone alloc] initWithFrame:CGRectOffset(self.view.frame, 0.0, 45.0) withFriend:friendDict];
	[self.view addSubview:_composeEditorView];
}

@end
