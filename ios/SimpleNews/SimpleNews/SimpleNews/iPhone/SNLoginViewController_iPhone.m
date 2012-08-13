//
//  SNLoginViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.11.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNLoginViewController_iPhone.h"
#import "SNRootViewController_iPhone.h"
#import "SNAppDelegate.h"
#import <FBiOSSDK/FacebookSDK.h>

@interface SNLoginViewController_iPhone () <FBLoginViewDelegate>
@end

@implementation SNLoginViewController_iPhone

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sessionStateChanged:) name:@"SESSION_STATE_CHANGED" object:nil];
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
	
	UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[facebookButton addTarget:self action:@selector(_goFacebook) forControlEvents:UIControlEventTouchUpInside];
	facebookButton.frame = CGRectMake(30.0, 250.0, 100.0, 48.0);
	[facebookButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
	[facebookButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
	[facebookButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	facebookButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	[facebookButton setTitle:@"Facebook" forState:UIControlStateNormal];
	[self.view addSubview:facebookButton];
	
	UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[twitterButton addTarget:self action:@selector(_goTwitter) forControlEvents:UIControlEventTouchUpInside];
	twitterButton.frame = CGRectMake(190.0, 250.0, 100.0, 48.0);
	[twitterButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
	[twitterButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
	[twitterButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	twitterButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	[twitterButton setTitle:@"Twitter" forState:UIControlStateNormal];
	[self.view addSubview:twitterButton];
	
	// Create Login View so that the app will be granted "status_update" permission.
//	FBLoginView *loginview = [[FBLoginView alloc] initWithPermissions:[NSArray arrayWithObject:@"status_update"]];
//	
//	loginview.frame = CGRectOffset(loginview.frame, 30.0, 250.0);
//	loginview.delegate = self;
//	
//	[self.view addSubview:loginview];
	//[SNAppDelegate openSession];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

#pragma mark - Notifications
- (void)_sessionStateChanged:(NSNotification *)notification {
	[self.navigationController pushViewController:[[SNRootViewController_iPhone alloc] init] animated:NO];
}

#pragma mark - Navigation
- (void)_goFacebook {
	NSArray *permissions = [NSArray arrayWithObjects:@"publish_actions", @"user_photos", nil];
	[FBSession sessionOpenWithPermissions:permissions completionHandler:
	 ^(FBSession *session, FBSessionState state, NSError *error) {
		 switch (state) {
			 case FBSessionStateOpen: {
				 [self.navigationController pushViewController:[[SNRootViewController_iPhone alloc] init] animated:YES];
				 
				 // FBSample logic
				 // Pre-fetch and cache the friends for the friend picker as soon as possible to improve
				 // responsiveness when the user tags their friends.
				 FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
				 [cacheDescriptor prefetchAndCacheForSession:session];
			 }
				 break;
			 case FBSessionStateClosed:
			 case FBSessionStateClosedLoginFailed:				 
				 break;
			 default:
				 break;
		 }
		 
		 //		 [[NSNotificationCenter defaultCenter] postNotificationName:SCSessionStateChangedNotification object:session];
		 
		 if (error) {
			 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
																				  message:error.localizedDescription
																				 delegate:nil
																	 cancelButtonTitle:@"OK"
																	 otherButtonTitles:nil];
			 [alertView show];
		 } 
	 }];
}

- (void)_goTwitter {
	[self.navigationController pushViewController:[[SNRootViewController_iPhone alloc] init] animated:YES];
}
@end
