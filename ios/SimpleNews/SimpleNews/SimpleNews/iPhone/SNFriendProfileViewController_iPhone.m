//
//  SNFriendProfileViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.25.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNFriendProfileViewController_iPhone.h"

#import "SNHeaderView_iPhone.h"
#import "SNNavBackBtnView.h"
#import "SNProfileViewCell_iPhone.h"
#import "SNAppDelegate.h"
#import "EGOImageView.h"
#import "SNWebPageViewController_iPhone.h"
#import "SNProfileArticlesViewController_iPhone.h"
#import "SNFindFriendsViewController_iPhone.h"
#import "ASIFormDataRequest.h"

@implementation SNFriendProfileViewController_iPhone

- (id)initWithTwitterUser:(SNTwitterUserVO *)vo {
	if ((self = [super init])) {
		_vo = vo;
	}
	
	return (self);
}


#pragma mark - View lifecycle

-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_plain.png"];
	[self.view addSubview:bgImgView];
	
	EGOImageView *avatarImg = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0, 66.0, 25.0, 25.0)];
	avatarImg.imageURL = [NSURL URLWithString:_vo.avatarURL];
	[self.view addSubview:avatarImg];
	
	UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	avatarButton.frame = avatarImg.frame;
	[avatarButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:avatarButton];
	
	UILabel *handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 71.0, 200.0, 16.0)];
	handleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	handleLabel.textColor = [SNAppDelegate snLinkColor];
	handleLabel.backgroundColor = [UIColor clearColor];
	handleLabel.text = [NSString stringWithFormat:@"@%@", _vo.handle];
	[self.view addSubview:handleLabel];
	
	UIButton *handleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	handleButton.frame = handleLabel.frame;
	[handleButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:handleButton];
	
	UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
	profileButton.frame = CGRectMake(267.0, 57.0, 44.0, 44.0);
	[profileButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive.png"] forState:UIControlStateNormal];
	[profileButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active.png"] forState:UIControlStateHighlighted];
	[profileButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:profileButton];
	
	UIView *statsBgView = [[UIView alloc] initWithFrame:CGRectMake(12.0, 115.0, 296.0, 70.0)];
	[statsBgView setBackgroundColor:[UIColor whiteColor]];
	[self.view addSubview:statsBgView];
	
	_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 17.0, 96.0, 18.0)];
	_likesLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
	_likesLabel.textAlignment = UITextAlignmentCenter;
	_likesLabel.textColor = [UIColor blackColor];
	_likesLabel.backgroundColor = [UIColor clearColor];
	
	[statsBgView addSubview:_likesLabel];
	
	UILabel *likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 40.0, 96.0, 16.0)];
	likesLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
	likesLabel.textAlignment = UITextAlignmentCenter;
	likesLabel.textColor = [SNAppDelegate snLinkColor];
	likesLabel.backgroundColor = [UIColor clearColor];
	likesLabel.text = @"Likes";
	[statsBgView addSubview:likesLabel];
	
	_commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(96.0, 17.0, 96.0, 18.0)];
	_commentsLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
	_commentsLabel.textAlignment = UITextAlignmentCenter;
	_commentsLabel.textColor = [UIColor blackColor];
	_commentsLabel.backgroundColor = [UIColor clearColor];
	[statsBgView addSubview:_commentsLabel];
	
	UILabel *commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(96.0, 40.0, 96.0, 16.0)];
	commentsLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
	commentsLabel.textAlignment = UITextAlignmentCenter;
	commentsLabel.textColor = [SNAppDelegate snLinkColor];
	commentsLabel.backgroundColor = [UIColor clearColor];
	commentsLabel.text = @"Comments";
	[statsBgView addSubview:commentsLabel];
	
	_sharesLabel = [[UILabel alloc] initWithFrame:CGRectMake(192.0, 17.0, 96.0, 18.0)];
	_sharesLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
	_sharesLabel.textAlignment = UITextAlignmentCenter;
	_sharesLabel.textColor = [UIColor blackColor];
	_sharesLabel.backgroundColor = [UIColor clearColor];
	[statsBgView addSubview:_sharesLabel];
	
	UILabel *sharesLabel = [[UILabel alloc] initWithFrame:CGRectMake(192.0, 40.0, 96.0, 16.0)];
	sharesLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
	sharesLabel.textAlignment = UITextAlignmentCenter;
	sharesLabel.textColor = [SNAppDelegate snLinkColor];
	sharesLabel.backgroundColor = [UIColor clearColor];
	sharesLabel.text = @"Shares";
	[statsBgView addSubview:sharesLabel];
	
	/*
	UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	likeButton.frame = CGRectMake(12.0, 115.0, 96.0, 70.0);
	[likeButton addTarget:self action:@selector(_goLikedArticles) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:likeButton];
	
	UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	commentButton.frame = CGRectMake(108.0, 115.0, 96.0, 70.0);
	[commentButton addTarget:self action:@selector(_goCommentedArticles) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:commentButton];
	
	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = CGRectMake(204.0, 115.0, 96.0, 70.0);
	[shareButton addTarget:self action:@selector(_goSharedArticles) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:shareButton];
	*/
	 
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:@"Profile"];
	[self.view addSubview:headerView];
	
	SNNavBackBtnView *backBtnView = [[SNNavBackBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
	[[backBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backBtnView];
	
	ASIFormDataRequest *statsRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Users.php"]]];
	[statsRequest setPostValue:[NSString stringWithFormat:@"%d", 5] forKey:@"action"];
	[statsRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.userID] forKey:@"userID"];
	[statsRequest setDelegate:self];
	[statsRequest startAsynchronous];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
-(void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)_goTwitterProfile {
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@", _vo.handle]] title:[NSString stringWithFormat:@"@%@", _vo.handle]];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_goNotificationsToggle:(UISwitch *)switchView {
	[SNAppDelegate notificationsToggle:switchView.on];
}

-(void)_goLikedArticles {
	[self.navigationController pushViewController:[[SNProfileArticlesViewController_iPhone alloc] initAsArticlesLiked] animated:YES];
}

-(void)_goCommentedArticles {
	[self.navigationController pushViewController:[[SNProfileArticlesViewController_iPhone alloc] initAsArticlesLiked] animated:YES];
}

-(void)_goSharedArticles {
	[self.navigationController pushViewController:[[SNProfileArticlesViewController_iPhone alloc] initAsArticlesLiked] animated:YES];
}

#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNFriendProfileViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSDictionary *parsedStats = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			_likesLabel.text = [NSString stringWithFormat:@"%d", [[parsedStats objectForKey:@"likes"] intValue]];
			_commentsLabel.text = [NSString stringWithFormat:@"%d", [[parsedStats objectForKey:@"comments"] intValue]];
			_sharesLabel.text = [NSString stringWithFormat:@"%d", [[parsedStats objectForKey:@"shares"] intValue]];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}


@end
