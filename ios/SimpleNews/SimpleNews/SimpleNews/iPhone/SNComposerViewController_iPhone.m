//
//  SNComposerViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.14.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <FBiOSSDK/FacebookSDK.h>

#import "SNComposerViewController_iPhone.h"
#import "SNAppDelegate.h"

#import "SNHeaderView_iPhone.h"
#import "SNNavDoneBtnView.h"
#import "SNNavBackBtnView.h"

#import "SNComposeTypeView_iPhone.h"
#import "SNComposeSourceView_iPhone.h"
#import "SNComposeFriendsView_iPhone.h"

@implementation SNComposerViewController_iPhone

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
	[self.view setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.85]];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_timeline.png"];
	//[self.view addSubview:bgImgView];
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:@"Composer"];
	[self.view addSubview:headerView];	
	
	SNNavBackBtnView *backBtnView = [[SNNavBackBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 64.0, 44.0)];
	[[backBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backBtnView];
	
	SNNavDoneBtnView *doneBtnView = [[SNNavDoneBtnView alloc] initWithFrame:CGRectMake(256.0, 0.0, 64.0, 44.0)];
	[[doneBtnView btn] addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:doneBtnView];
	
	_composeTypeView = [[SNComposeTypeView_iPhone alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_composeTypeView];
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
- (void)_composeTypeSticker:(NSNotification *)notification {
	_composeState++;
	_isQuoteType = NO;
	
	[_composeTypeView removeFromSuperview];
	_composeSourceView = [[SNComposeSourceView_iPhone alloc] initWithFrame:CGRectOffset(self.view.frame, 0.0, 50.0)];
	[self.view addSubview:_composeSourceView];
}

- (void)_composeTypeQuote:(NSNotification *)notification {
	_composeState++;
	_isQuoteType = YES;
	
	[_composeTypeView removeFromSuperview];
	_composeSourceView = [[SNComposeSourceView_iPhone alloc] initWithFrame:CGRectOffset(self.view.frame, 0.0, 50.0)];
	[self.view addSubview:_composeSourceView];
}

- (void)_composeSourceFriends:(NSNotification *)notification {
	_composeState++;
	_isFriendsSource = YES;
	
	[_composeSourceView removeFromSuperview];
	_composeFriendsView = [[SNComposeFriendsView_iPhone alloc] initWithFrame:CGRectOffset(self.view.frame, 0.0, 50.0)];
	[self.view addSubview:_composeFriendsView];
}


- (void)_fbUserPressed:(NSNotification *)notification {
	_composeState++;
	
	[_composeFriendsView removeFromSuperview];
	_composeEditorView = [[SNComposeEditorView_iPhone alloc] initWithFrame:CGRectOffset(self.view.frame, 0.0, 50.0) withFriend:(NSDictionary *)[notification object] withType:(int)_isQuoteType];
	[self.view addSubview:_composeEditorView];
}


#pragma mark - Navigation
-(void)_goBack {
	_composeState--;
	
	switch (_composeState) {
		case 0:
			[_composeSourceView removeFromSuperview];
			[self.view addSubview:_composeTypeView];
			break;
			
		case 1:
			[_composeFriendsView removeFromSuperview];
			[self.view addSubview:_composeSourceView];
			break;
			
		case 2:
			[_composeEditorView removeFromSuperview];
			
			if (_isFriendsSource)
				[self.view addSubview:_composeFriendsView];
			
			break;
	}
}

-(void)_goDone {
	[self dismissModalViewControllerAnimated:NO];
}

@end
