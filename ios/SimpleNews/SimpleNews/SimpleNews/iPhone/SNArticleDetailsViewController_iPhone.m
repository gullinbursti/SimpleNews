//
//  SNArticleDetailsViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.17.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Twitter/Twitter.h>

#import "GANTracker.h"
#import "SNArticleDetailsViewController_iPhone.h"

#import "SNAppDelegate.h"
#import "SNHeaderView_iPhone.h"
#import "SNNavBackBtnView.h"
#import "SNNavShareBtnView.h"
#import "SNArticleCommentsViewController_iPhone.h"
#import "SNArticleVideoPlayerView_iPhone.h"
#import "SNWebPageViewController_iPhone.h"

#import "ImageFilter.h"

@implementation SNArticleDetailsViewController_iPhone

-(id)initWithArticleVO:(SNArticleVO *)vo {
	if ((self = [super init])) {
		_vo = vo;
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/lists/%d/%@/comments", _vo.list_id, _vo.title] withError:&error])
			NSLog(@"error in trackPageview");
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_plain.png"];
	[self.view addSubview:bgImgView];
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:_vo.title];
	[self.view addSubview:headerView];
	
	SNNavBackBtnView *backBtnView = [[SNNavBackBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
	[[backBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backBtnView];
	
	SNNavShareBtnView *shareBtnView = [[SNNavShareBtnView alloc] initWithFrame:CGRectMake(276.0, 0.0, 44.0, 44.0)];
	[[shareBtnView btn] addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:shareBtnView];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 49.0, self.view.frame.size.width, self.view.frame.size.height - 49.0)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;	
	[_scrollView setBackgroundColor:[UIColor clearColor]];
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	[self.view addSubview:_scrollView];
	
	_toggleLtImgView = [[UIImageView alloc] initWithFrame:CGRectMake(77.0, 8.0, 164.0, 44.0)];
	_toggleLtImgView.image = [UIImage imageNamed:@"toggleBGLeft.png"];
	[_scrollView addSubview:_toggleLtImgView];
	
	UILabel *textOnLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.0, 13.0, 100.0, 16.0)];
	textOnLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	textOnLabel.textColor = [UIColor colorWithWhite:0.659 alpha:1.0];
	textOnLabel.backgroundColor = [UIColor clearColor];
	textOnLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	textOnLabel.shadowOffset = CGSizeMake(0.0, -1.0);
	textOnLabel.text = @"Text View";
	[_toggleLtImgView addSubview:textOnLabel];
	
	UILabel *webOffLabel = [[UILabel alloc] initWithFrame:CGRectMake(97.0, 13.0, 100.0, 16.0)];
	webOffLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	webOffLabel.textColor = [UIColor blackColor];
	webOffLabel.backgroundColor = [UIColor clearColor];
	webOffLabel.text = @"Web View";
	[_toggleLtImgView addSubview:webOffLabel];
	
	_toggleRtImgView = [[UIImageView alloc] initWithFrame:CGRectMake(78.0, 8.0, 164.0, 44.0)];
	_toggleRtImgView.image = [UIImage imageNamed:@"toggleBGRight.png"];
	_toggleRtImgView.hidden = YES;
	[_scrollView addSubview:_toggleRtImgView];
	
	UILabel *textOffLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.0, 13.0, 100.0, 16.0)];
	textOffLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	textOffLabel.textColor = [UIColor blackColor];
	textOffLabel.backgroundColor = [UIColor clearColor];
	textOffLabel.text = @"Text View";
	[_toggleRtImgView addSubview:textOffLabel];
	
	UILabel *webOnLabel = [[UILabel alloc] initWithFrame:CGRectMake(97.0, 13.0, 100.0, 16.0)];
	webOnLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	webOnLabel.textColor = [UIColor colorWithWhite:0.659 alpha:1.0];
	webOnLabel.backgroundColor = [UIColor clearColor];
	webOnLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	webOnLabel.shadowOffset = CGSizeMake(0.0, -1.0);
	webOnLabel.text = @"Web View";
	[_toggleRtImgView addSubview:webOnLabel];
	
	UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	toggleButton.frame = CGRectMake(160.0, 8.0, 81.0, 44.0);
	[toggleButton addTarget:self action:@selector(_goArticleSource) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:toggleButton];
	
	int offset = 74;
	EGOImageView *thumbImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0, offset, 25.0, 25.0)];
	thumbImgView.imageURL = [NSURL URLWithString:_vo.avatarImage_url];
	[_scrollView addSubview:thumbImgView];
	
	UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	avatarButton.frame = thumbImgView.frame;
	[avatarButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:avatarButton];
	offset += 6;
	
	NSString *timeSince = @"";
	int mins = [SNAppDelegate minutesAfterDate:_vo.added];
	int hours = [SNAppDelegate hoursAfterDate:_vo.added];
	int days = [SNAppDelegate daysAfterDate:_vo.added];
	
	if (days > 0) {
		timeSince = [NSString stringWithFormat:@"%dd via ", days];
		
	} else {
		if (hours > 0)
			timeSince = [NSString stringWithFormat:@"%dh via ", hours];
		
		else
			timeSince = [NSString stringWithFormat:@"%dm via ", mins];
	}
	
	CGSize size = [timeSince sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, offset, size.width, size.height)];
	dateLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10];
	dateLabel.textColor = [UIColor colorWithWhite:0.675 alpha:1.0];
	dateLabel.backgroundColor = [UIColor clearColor];
	dateLabel.text = timeSince;
	[_scrollView addSubview:dateLabel];
	
	CGSize size2 = [[NSString stringWithFormat:@"@%@ ", _vo.articleSource] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(250.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(dateLabel.frame.origin.x + size.width, offset, size2.width, size.height)];
	sourceLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10];
	sourceLabel.textColor = [SNAppDelegate snLinkColor];
	sourceLabel.backgroundColor = [UIColor clearColor];
	sourceLabel.text = _vo.articleSource;
	[_scrollView addSubview:sourceLabel];
	
	UIButton *sourceButton = [UIButton buttonWithType:UIButtonTypeCustom];
	sourceButton.frame = sourceLabel.frame;
	[sourceButton addTarget:self action:@selector(_goArticleSource) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:sourceButton];
	offset += 39;
	
	size = [_vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:12] constrainedToSize:CGSizeMake(274.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, offset, 280.0, size.height)];
	titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:12];
	titleLabel.textColor = [UIColor blackColor];
	
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.text = _vo.title;
	titleLabel.numberOfLines = 0;
	[_scrollView addSubview:titleLabel];
	offset += size.height + 20;
	
	UIImageView *btnBGImgView = [[UIImageView alloc] initWithFrame:CGRectMake(73.0, offset, 174.0, 44.0)];
	btnBGImgView.image = [UIImage imageNamed:@"commentLikeButton_BG.png"];
	btnBGImgView.userInteractionEnabled = YES;
	[_scrollView addSubview:btnBGImgView];
	offset += 62;
	
	UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	commentButton.frame = CGRectMake(6.0, 0.0, 94.0, 44.0);
	[commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_nonActive.png"] forState:UIControlStateNormal];
	[commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Active.png"] forState:UIControlStateHighlighted];
	[commentButton addTarget:self action:@selector(_goComment) forControlEvents:UIControlEventTouchUpInside];
	[commentButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	commentButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10.0];
	commentButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, -10.0);
	[commentButton setTitle:@"Comment" forState:UIControlStateNormal];
	[btnBGImgView addSubview:commentButton];
	
	_likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_likeButton.frame = CGRectMake(98.0, 0.0, 74.0, 44.0);
	[_likeButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	_likeButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10.0];
	_likeButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, -8.0);
	[_likeButton setTitle:[NSString stringWithFormat:@"%d", _vo.totalLikes] forState:UIControlStateNormal];
	[btnBGImgView addSubview:_likeButton];
	
	if (_vo.hasLiked) {
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Selected.png"] forState:UIControlStateNormal];
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Selected.png"] forState:UIControlStateHighlighted];
	
	} else {
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive.png"] forState:UIControlStateNormal];
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active.png"] forState:UIControlStateHighlighted];
		[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	}
	
	EGOImageView *articleImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0, offset, 280.0, 280.0 * _vo.imgRatio)];
	articleImgView.delegate = self;
	articleImgView.imageURL = [NSURL URLWithString:_vo.bgImage_url];
	[_scrollView addSubview:articleImgView];
	offset += (280.0 * _vo.imgRatio);
	
	offset += 38;
	if (_vo.type_id > 4) {
		_videoPlayerView = [[SNArticleVideoPlayerView_iPhone alloc] initWithFrame:CGRectMake(25.0, offset, 270.0, 202.0) articleVO:_vo];
		//[_videoPlayerView startPlayback];
		[_scrollView addSubview:_videoPlayerView];		
		offset += _videoPlayerView.frame.size.height + 38;
	}
	
	size = [_vo.content sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12] constrainedToSize:CGSizeMake(280.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, offset, size.width, size.height)];
	contentLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	contentLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
	contentLabel.backgroundColor = [UIColor clearColor];
	contentLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	contentLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	contentLabel.text = _vo.content;
	contentLabel.numberOfLines = 0;
	[_scrollView addSubview:contentLabel];
	offset += size.height;
	
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, offset);
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

-(void)_goArticleSource {
	_toggleLtImgView.hidden = YES;
	_toggleRtImgView.hidden = NO;
	
	[self performSelector:@selector(_resetToggle) withObject:nil afterDelay:0.25];
	
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:_vo.article_url] title:_vo.articleSource];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_goTwitterProfile {
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@", _vo.twitterHandle]] title:[NSString stringWithFormat:@"@%@", _vo.twitterHandle]];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_goComment {
	[self.navigationController pushViewController:[[SNArticleCommentsViewController_iPhone alloc] initWithArticleVO:_vo listID:_vo.list_id] animated:YES];
}

-(void)_goShare {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
																				delegate:self 
																	cancelButtonTitle:@"Cancel" 
															 destructiveButtonTitle:nil 
																	otherButtonTitles:@"Twitter", @"Email", nil];
	[actionSheet showInView:self.view];

}

-(void)_goLike {
	ASIFormDataRequest *readRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
	[readRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	[readRequest setDelegate:self];
	[readRequest startAsynchronous];
	
	[_likeButton removeTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Selected.png"] forState:UIControlStateNormal];
	[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Selected.png"] forState:UIControlStateHighlighted];
	[_likeButton setTitle:[NSString stringWithFormat:@"%d", ++_vo.totalLikes] forState:UIControlStateNormal];
	
	ASIFormDataRequest *likeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
	[likeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	[likeRequest startAsynchronous];
	
	_vo.hasLiked = YES;
}


-(void)_resetToggle {
	_toggleLtImgView.hidden = NO;
	_toggleRtImgView.hidden = YES;
}

#pragma mark - MailComposeViewController Delegates
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status:" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
	
	switch (result) {
		case MFMailComposeResultCancelled:
			alert.message = @"Message Canceled";
			break;
			
		case MFMailComposeResultSaved:
			alert.message = @"Message Saved";
			[alert show];
			break;
			
		case MFMailComposeResultSent:
			alert.message = @"Message Sent";
			break;
			
		case MFMailComposeResultFailed:
			alert.message = @"Message Failed";
			[alert show];
			break;
			
		default:
			alert.message = @"Message Not Sent";
			[alert show];
			break;
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
			TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
			
			[twitter addURL:[NSURL URLWithString:_vo.article_url]];
			[twitter setInitialText:[NSString stringWithFormat:@"via Assembly - %@", _vo.title]];
			[self presentModalViewController:twitter animated:YES];
			
			twitter.completionHandler = ^(TWTweetComposeViewControllerResult result)  {
				[self dismissModalViewControllerAnimated:YES];
			};
			
	} else if (buttonIndex == 1) {
		if ([MFMailComposeViewController canSendMail]) {
			MFMailComposeViewController *mfViewController = [[MFMailComposeViewController alloc] init];
			mfViewController.mailComposeDelegate = self;
			[mfViewController setSubject:[NSString stringWithFormat:@"Assembly - %@", _vo.title]];
			[mfViewController setMessageBody:_vo.content isHTML:NO];
			
			[self presentViewController:mfViewController animated:YES completion:nil];
			
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status:" 
																			message:@"Your phone is not currently configured to send mail." 
																		  delegate:nil 
															  cancelButtonTitle:@"ok" 
															  otherButtonTitles:nil];
			[alert show];
		}
	}
}


#pragma mark - Image View delegates
-(void)imageViewLoadedImage:(EGOImageView *)imageView {
	imageView.image = [SNAppDelegate imageWithFilters:imageView.image filter:[NSArray arrayWithObjects:
																									  [NSDictionary dictionaryWithObjectsAndKeys:
																										@"sepia", @"type", nil, nil], 
																									  nil]];
}

@end
