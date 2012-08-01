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
#import "SNImageVO.h"
#import "SNTwitterAvatarView.h"
#import "SNTwitterUserVO.h"

#import "ImageFilter.h"

@interface SNArticleDetailsViewController_iPhone () <MBLResourceObserverProtocol>
@property(nonatomic, strong) MBLAsyncResource *imageResource;
@end

@implementation SNArticleDetailsViewController_iPhone

@synthesize imageResource = _imageResource;

-(void)setImageResource:(MBLAsyncResource *)imageResource {
	if (_imageResource != nil) {
		[_imageResource unsubscribe:self];
		_imageResource = nil;
	}
	
	_imageResource = imageResource;
	
	if (_imageResource != nil)
		[_imageResource subscribe:self];
}


-(id)initWithArticleVO:(SNArticleVO *)vo {
	if ((self = [super init])) {
		_vo = vo;
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/%@/%d/details", _vo.topicTitle, _vo.article_id] withError:&error])
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
	
	UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
	bgView.image = [UIImage imageNamed:@"background_timeline.png"];
	[self.view addSubview:bgView];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 45.0, self.view.frame.size.width, self.view.frame.size.height - 85.0)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;	
	[_scrollView setBackgroundColor:[UIColor clearColor]];
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_scrollView];
	
//	NSString *cardBG;	
//	if (_vo.totalLikes > 0)
//		cardBG = @"defaultCardTimeline_Likes.png";
//	
//	else
//		cardBG = @"defaultCardTimeline_noLikes.png";
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -1.0, 320.0, _scrollView.frame.size.height)];
	UIImage *img = [UIImage imageNamed:@"articleFriendsBG.png"];
	bgImgView.image = [img stretchableImageWithLeftCapWidth:10.0 topCapHeight:20.0];
	[_scrollView addSubview:bgImgView];
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:_vo.title];
	[self.view addSubview:headerView];
	
	SNNavBackBtnView *backBtnView = [[SNNavBackBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 64.0, 44.0)];
	[[backBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backBtnView];
	
//	SNNavShareBtnView *shareBtnView = [[SNNavShareBtnView alloc] initWithFrame:CGRectMake(276.0, 0.0, 44.0, 44.0)];
//	[[shareBtnView btn] addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
//	[headerView addSubview:shareBtnView];
	
	CGSize size;
	CGSize size2;
	
	int offset = 21;
	SNTwitterAvatarView *avatarImgView = [[SNTwitterAvatarView alloc] initWithPosition:CGPointMake(15.0, 15.0) imageURL:_vo.avatarImage_url handle:_vo.twitterHandle];
	[_scrollView addSubview:avatarImgView];
	
	size = [@"via 	" sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *viaLabel = [[UILabel alloc] initWithFrame:CGRectMake(46.0, offset, size.width, size.height)];
	viaLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	viaLabel.textColor = [SNAppDelegate snGreyColor];
	viaLabel.backgroundColor = [UIColor clearColor];
	viaLabel.text = @"via ";
	[_scrollView addSubview:viaLabel];
	
	size2 = [[NSString stringWithFormat:@"@%@ ", _vo.twitterHandle] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11] constrainedToSize:CGSizeMake(180.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(46.0 + size.width, offset, size2.width, size2.height)];
	handleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	handleLabel.textColor = [SNAppDelegate snLinkColor];
	handleLabel.backgroundColor = [UIColor clearColor];
	handleLabel.text = [NSString stringWithFormat:@"@%@ ", _vo.twitterHandle];
	[_scrollView addSubview:handleLabel];
	
	UIButton *handleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[handleButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	handleButton.frame = handleLabel.frame;
	[_scrollView addSubview:handleButton];
	
	size = [@"into " sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *inLabel = [[UILabel alloc] initWithFrame:CGRectMake(handleLabel.frame.origin.x + size2.width, offset, size.width, size.height)];
	inLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	inLabel.textColor = [SNAppDelegate snGreyColor];
	inLabel.backgroundColor = [UIColor clearColor];
	inLabel.text = @"into ";
	[_scrollView addSubview:inLabel];
	
	size2 = [[NSString stringWithFormat:@"%@", _vo.topicTitle] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11] constrainedToSize:CGSizeMake(180.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(inLabel.frame.origin.x + size.width, offset, size2.width, size2.height)];
	topicLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	topicLabel.textColor = [SNAppDelegate snLinkColor];
	topicLabel.backgroundColor = [UIColor clearColor];
	topicLabel.text = [NSString stringWithFormat:@"%@", _vo.topicTitle];
	[_scrollView addSubview:topicLabel];
	
	
	UIButton *topicButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[topicButton addTarget:self action:@selector(_goTopic) forControlEvents:UIControlEventTouchUpInside];
	topicButton.frame = topicLabel.frame;
	[_scrollView addSubview:topicButton];
	
	NSString *timeSince = @"";
	int mins = [SNAppDelegate minutesAfterDate:_vo.added];
	int hours = [SNAppDelegate hoursAfterDate:_vo.added];
	int days = [SNAppDelegate daysAfterDate:_vo.added];
	
	if (days > 0) {
		timeSince = [NSString stringWithFormat:@"%dd", days];
		
	} else {
		if (hours > 0)
			timeSince = [NSString stringWithFormat:@"%dh", hours];
		
		else
			timeSince = [NSString stringWithFormat:@"%dm", mins];
	}
	
	size = [timeSince sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(287.0, offset + 1.0, size.width, size.height)];
	dateLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10];
	dateLabel.textColor = [SNAppDelegate snGreyColor];
	dateLabel.backgroundColor = [UIColor clearColor];
	dateLabel.textAlignment = UITextAlignmentRight;
	dateLabel.text = timeSince;
	[_scrollView addSubview:dateLabel];
	offset += 30;
	
	size = [_vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(274.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, offset, 280.0, size.height)];
	titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	titleLabel.textColor = [SNAppDelegate snGreyColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = _vo.title;
	titleLabel.numberOfLines = 0;
	[_scrollView addSubview:titleLabel];
	offset += size.height + 7;
	
	_articleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, offset, 290.0, 290.0 * ((SNImageVO *)[_vo.images objectAtIndex:0]).ratio)];
	//_articleImgView.imageURL = [NSURL URLWithString:((SNImageVO *)[_vo.images objectAtIndex:1]).url];
	[_scrollView addSubview:_articleImgView];
	offset += (290.0 * ((SNImageVO *)[_vo.images objectAtIndex:2]).ratio);
	
	if (_imageResource == nil) {			
		self.imageResource = [[MBLResourceLoader sharedInstance] downloadURL:((SNImageVO *)[_vo.images objectAtIndex:0]).url forceFetch:NO expiration:[NSDate dateWithTimeIntervalSinceNow:(60.0 * 60.0 * 24.0)]]; // 1 day expiration from now
	}
	
	offset += 8;
	if (_vo.type_id > 4) {
		_videoPlayerView = [[SNArticleVideoPlayerView_iPhone alloc] initWithFrame:CGRectMake(15.0, offset, 290.0, 202.0) articleVO:_vo];
		//[_videoPlayerView startPlayback];
		[_scrollView addSubview:_videoPlayerView];		
		offset += _videoPlayerView.frame.size.height + 38;
	}
	
	size = [_vo.content sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12] constrainedToSize:CGSizeMake(280.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, offset, size.width, size.height)];
	contentLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12];
	contentLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
	contentLabel.backgroundColor = [UIColor clearColor];
	contentLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	contentLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	contentLabel.text = _vo.content;
	contentLabel.numberOfLines = 0;
	[_scrollView addSubview:contentLabel];
	offset += size.height;
	
	offset += 13;
	
	int scrollSize = (_vo.totalLikes > 0) ? 44 : 0;		
	bgImgView.frame = CGRectMake(bgImgView.frame.origin.x, bgImgView.frame.origin.y, bgImgView.frame.size.width, offset);
	_scrollView.frame = CGRectMake(0.0, 45.0, _scrollView.frame.size.width, self.view.frame.size.height - (85.0 + scrollSize));
	_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, MAX(offset + 10.0, self.view.frame.size.height - (84.0 + scrollSize)));
	
	UIImageView *footerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 435.0, 320.0, 44.0)];
	footerImgView.image = [UIImage imageNamed:@"articleDetailsFooterBG.png"];
	footerImgView.userInteractionEnabled = YES;
	[self.view addSubview:footerImgView];
	
	NSString *likeActive = (_vo.totalLikes == 0) ? @"leftBottomUIBFull_Active.png" : @"leftBottomUIFull_Active.png";
	NSString *likeCaption = (_vo.hasLiked) ? @"Liked" : @"Like";
		
	_likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_likeButton.frame = CGRectMake(0.0, 1.0, 95.0, 43.0);
	[_likeButton setBackgroundImage:[UIImage imageNamed:likeActive] forState:UIControlStateHighlighted];
	[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];_likeButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -4.0, 0.0, 4.0);
	_likeButton.imageEdgeInsets = UIEdgeInsetsMake(2.0, -5.0, -2.0, 5.0);
	[_likeButton setImage:[UIImage imageNamed:@"likeIcon.png"] forState:UIControlStateNormal];
	[_likeButton setImage:[UIImage imageNamed:@"likeIcon_Active.png"] forState:UIControlStateHighlighted];
	_likeButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
	_likeButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, -2.0, 0.0);
	[_likeButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	[_likeButton setTitle:likeCaption forState:UIControlStateNormal];
	[footerImgView addSubview:_likeButton];
	
	if (_vo.hasLiked) {
		[_likeButton addTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"leftBottomUIB_Active.png"] forState:UIControlStateNormal];
	
	} else
		[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	
	NSString *commentCaption;
	if ([_vo.comments count] == 0)
		commentCaption = @"Comment";
	
	else
		commentCaption = [NSString stringWithFormat:@"Comments (%d)", [_vo.comments count]];
	
	commentCaption = ([_vo.comments count] >= 10) ? [NSString stringWithFormat:@"Comm… (%d)", [_vo.comments count]] : [NSString stringWithFormat:@"Comments (%d)", [_vo.comments count]];
	_commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_commentButton.frame = CGRectMake(96.0, 1.0, 130.0, 43.0);
	[_commentButton setBackgroundImage:[UIImage imageNamed:@"centerbottomUI_Active.png"] forState:UIControlStateHighlighted];
	[_commentButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
	_commentButton.imageEdgeInsets = UIEdgeInsetsMake(2.0, -5.0, -2.0, 5.0);
	[_commentButton setImage:[UIImage imageNamed:@"commentIcon.png"] forState:UIControlStateNormal];
	[_commentButton setImage:[UIImage imageNamed:@"commentIcon_Active.png"] forState:UIControlStateHighlighted];
	_commentButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
	_commentButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, -2.0, 0.0);
	[_commentButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	[_commentButton setTitle:commentCaption forState:UIControlStateNormal];
	[footerImgView addSubview:_commentButton];
	
	UIButton *sourceButton = [UIButton buttonWithType:UIButtonTypeCustom];
	sourceButton.frame = CGRectMake(226.0, 1.0, 95.0, 43.0);
	[sourceButton setBackgroundImage:[[UIImage imageNamed:@"rightBottomUI_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	sourceButton.imageEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, -2.0, 0.0);
	[sourceButton setImage:[UIImage imageNamed:@"moreIcon_nonActive.png"] forState:UIControlStateNormal];
	[sourceButton setImage:[UIImage imageNamed:@"moreIcon_Active.png"] forState:UIControlStateHighlighted];
	[sourceButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[footerImgView addSubview:sourceButton];
	
	if (_vo.totalLikes > 0) {
		UIImageView *likesImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 390.0, 320.0, 54.0)];
		likesImgView.image = [UIImage imageNamed:@"articleDetailsLikeBG.png"];
		[self.view addSubview:likesImgView];
		
		int offset2 = 10;
		int tot = 0;
		for (SNTwitterUserVO *tuVO in _vo.userLikes) {
			
			if ([tuVO.twitterID isEqualToString:[[SNAppDelegate profileForUser] objectForKey:@"twitter_id"]]) {
				_vo.hasLiked = YES;
				[_likeButton setTitle:@"Liked" forState:UIControlStateNormal];
				[_likeButton setBackgroundImage:[UIImage imageNamed:@"leftBottomUI_Active.png"] forState:UIControlStateNormal];
				[_likeButton removeTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
				[_likeButton addTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
			}
			
			if (tot < 9) {
				SNTwitterAvatarView *avatarView = [[SNTwitterAvatarView alloc] initWithPosition:CGPointMake(offset2, 401.0) imageURL:tuVO.avatarURL handle:tuVO.handle];
				[self.view addSubview:avatarView];
				offset2 += 34.0;
			}
			tot++;
		}
	}
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
	[self performSelector:@selector(_resetToggle) withObject:nil afterDelay:0.25];
	
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:_vo.article_url] title:_vo.topicTitle];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_goTwitterProfile {
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@", _vo.twitterHandle]] title:[NSString stringWithFormat:@"@%@", _vo.twitterHandle]];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_goComments {
	[self.navigationController pushViewController:[[SNArticleCommentsViewController_iPhone alloc] initWithArticleVO:_vo] animated:YES];
}

-(void)_goShare {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUB_SHARE_SHEET" object:_vo];
}

-(void)_goLike {
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_LIKED_ARTICLE" object:_vo];
		
		[_likeButton removeTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		[_likeButton addTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
		
		NSString *likeImg = (_vo.totalLikes > 0) ? @"leftBottomUI_Active.png" : @"leftBottomUIB_Active.png";		
		[_likeButton setBackgroundImage:[UIImage imageNamed:likeImg] forState:UIControlStateNormal];
		
		_likeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kArticlesAPI]]];
		[_likeRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[_likeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[_likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
		_likeRequest.delegate = self;
		[_likeRequest startAsynchronous];
		
		_vo.hasLiked = YES;
	}
}

-(void)_goDislike {
	
	[_likeButton removeTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
	[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	[_likeButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
	
	_likeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kArticlesAPI]]];
	[_likeRequest setPostValue:[NSString stringWithFormat:@"%d", 7] forKey:@"action"];
	[_likeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[_likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	_likeRequest.delegate = self;
	[_likeRequest startAsynchronous];
	
	_vo.hasLiked = NO;
}


-(void)_resetToggle {
}

- (void)_goTopic {
	[self.navigationController popViewControllerAnimated:YES];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_TOPIC" object:[NSNumber numberWithInt:_vo.topicID]];
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


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNArticleItem_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	if ([request isEqual:_likeRequest]) {
		NSError *error = nil;
		NSDictionary *parsedLike = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			_vo.totalLikes = [[parsedLike objectForKey:@"likes"] intValue];
			
			if (_vo.hasLiked)
				[_likeButton setTitle:@"Liked" forState:UIControlStateNormal];
			
			else
				[_likeButton setTitle:@"Like" forState:UIControlStateNormal];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

#pragma mark - Async Resource Observers
- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data {
	NSLog(@"MBLAsyncResource.data [%@]", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	_articleImgView.image = [UIImage imageWithData:data];
	
	//_articleImgView.image = [SNAppDelegate imageWithFilters:[UIImage imageWithData:data] filter:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"saturation", @"type", [NSNumber numberWithFloat:1.0], @"amount", nil], nil]];
}

- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error {
}
@end
