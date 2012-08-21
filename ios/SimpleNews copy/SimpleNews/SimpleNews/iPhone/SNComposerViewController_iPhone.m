//
//  SNComposerViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.14.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>
//#import <FBiOSSDK/FacebookSDK.h>
#import <FacebookSDK/FacebookSDK.h>

#import "SNComposerViewController_iPhone.h"
#import "SNAppDelegate.h"

#import "SNHeaderView_iPhone.h"
#import "SNNavDoneBtnView.h"
#import "SNNavBackBtnView.h"

#import "SNComposeTypeView_iPhone.h"
#import "SNComposeSourceView_iPhone.h"
#import "SNComposeFriendsView_iPhone.h"

@interface SNComposerViewController_iPhone() <UINavigationControllerDelegate, UIImagePickerControllerDelegate, FBFriendPickerDelegate>
@property (strong, nonatomic) FBFriendPickerViewController *friendPickerController;
@end

@implementation SNComposerViewController_iPhone

@synthesize friendPickerController = _friendPickerController;

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_fbUserPressed:) name:@"FB_USER_PRESSED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_composeSubmitted:) name:@"COMPOSE_SUBMITTED" object:nil];
		
		_isCameraSource = NO;
		_isCameraRollSource = NO;
		_isFriendsSource = NO;
		_isArticleSource = NO;
		
		_isFirstAppearance = YES;
	}
	
	return (self);
}

- (id)initWithTypeCamera {
	if ((self = [self init])) {
		_isCameraSource = YES;
	}
	
	return (self);
}

- (id)initWithTypeCameraRoll {
	if ((self = [self init])) {
		_isCameraRollSource = YES;
	}
	
	return (self);
}

- (id)initWithTypeFriends {
	if ((self = [self init])) {
		_isFriendsSource = YES;
	}
	
	return (self);
}

- (id)initWithArticle:(SNArticleVO *)vo {
	if ((self = [self init])) {
		_vo = vo;
		_isArticleSource = YES;
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
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (_isFirstAppearance) {
		_isFirstAppearance = NO;
	
		if (_isCameraSource) {
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SOURCE_CAMERA" object:nil];
				
				UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
				imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
				imagePicker.delegate = self;
				imagePicker.allowsEditing = YES;
				
				[self.navigationController presentViewController:imagePicker animated:NO completion:nil];
				
			} else {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Camera not aviable." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alertView show];
			}
		}
		
		if (_isCameraRollSource) {
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SOURCE_CAMERAROLL" object:nil];
				
				UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
				imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
				imagePicker.delegate = self;
				imagePicker.allowsEditing = YES;
				//imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
				
				[self.navigationController presentViewController:imagePicker animated:NO completion:nil];
				
			} else {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Photo roll not available." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alertView show];
			}
		}
		
		if (_isFriendsSource) {
			[_headerView addSubview:_backBtnView];
			
			self.friendPickerController = [[FBFriendPickerViewController alloc] initWithNibName:nil bundle:nil];
			self.friendPickerController.delegate = self;
			self.friendPickerController.allowsMultipleSelection = NO;
			[self.navigationController setNavigationBarHidden:NO animated:NO];
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
		
		if (_isArticleSource) {
			_composeEditorView = [[SNComposeEditorView_iPhone alloc] initWithFrame:CGRectOffset(self.view.frame, 0.0, 45.0) withArticle:_vo];
			[self.view addSubview:_composeEditorView];
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Notifications
- (void)_fbUserPressed:(NSNotification *)notification {
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	
	[_composeFriendsView removeFromSuperview];
	_composeEditorView = [[SNComposeEditorView_iPhone alloc] initWithFrame:CGRectOffset(self.view.frame, 0.0, 45.0) withFriend:(NSDictionary *)[notification object]];
	[self.view addSubview:_composeEditorView];
}


- (void)_composeSubmitted:(NSNotification *)notification {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Navigation
-(void)_goBack {
	[_composeEditorView removeFromSuperview];
	
	if (_isFriendsSource) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
		self.friendPickerController = [[FBFriendPickerViewController alloc] initWithNibName:nil bundle:nil];
		self.friendPickerController.delegate = self;
		self.friendPickerController.allowsMultipleSelection = NO;
		self.friendPickerController.title = @"Select friends";
		
		ABAddressBookCreate();
		ABPersonSortOrdering sortOrdering = ABPersonGetSortOrdering();
		ABPersonCompositeNameFormat nameFormat = ABPersonGetCompositeNameFormat();
		
		self.friendPickerController.sortOrdering = (sortOrdering == kABPersonSortByFirstName) ? FBFriendSortByFirstName : FBFriendSortByLastName;
		self.friendPickerController.displayOrdering = (nameFormat == kABPersonCompositeNameFormatFirstNameFirst) ? FBFriendDisplayByFirstName : FBFriendDisplayByLastName;
		
		[self.friendPickerController loadData];
		[self.navigationController pushViewController:self.friendPickerController animated:NO];
	}
}

-(void)_goDone {
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark - FBFriendPickerDelegate methods
- (void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker {
	_fiendsList = friendPicker.selection;
	[friendPicker.navigationController popViewControllerAnimated:NO];
	id<FBGraphUser> friend = [_fiendsList objectAtIndex:0];
	
	NSString *largeImgURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", friend.id];
	NSDictionary *friendDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:friend.id, friend.name, largeImgURL, nil] forKeys:[NSArray arrayWithObjects:@"id", @"name", @"lg_image", nil]];
	
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	[_composeFriendsView removeFromSuperview];
	_composeEditorView = [[SNComposeEditorView_iPhone alloc] initWithFrame:CGRectOffset(self.view.frame, 0.0, 45.0) withFriend:friendDict];
	[self.view addSubview:_composeEditorView];
}

#pragma mark - ImagePicker Delegates
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissModalViewControllerAnimated:NO];
	
	_composeEditorView = [[SNComposeEditorView_iPhone alloc] initWithFrame:CGRectOffset(self.view.frame, 0.0, 45.0) withImage:image];
	[self.view addSubview:_composeEditorView];
}


@end
