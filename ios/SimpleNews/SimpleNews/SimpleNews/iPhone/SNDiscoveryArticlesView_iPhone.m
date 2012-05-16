//
//  SNDiscoveryArticlesView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>
#import "GANTracker.h"
#import "ImageFilter.h"

#import "SNDiscoveryArticlesView_iPhone.h"
#import "SNDiscoveryArticleCardView_iPhone.h"
#import "SNArticleCommentsViewController_iPhone.h"
#import "SNArticleDetailsViewController_iPhone.h"
#import "SNHeaderView_iPhone.h"

#import "SNHeaderView_iPhone.h"
#import "SNNavTitleView.h"
#import "SNNavListBtnView.h"
#import "SNNavLogoBtnView.h"
#import "SNAppDelegate.h"
#import "SNTweetVO.h"

#import "SNWebPageViewController_iPhone.h"

@implementation SNDiscoveryArticlesView_iPhone

#define kImageScale 0.9

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_twitterTimeline:) name:@"TWITTER_TIMELINE" object:nil];
		
		_articles = [NSMutableArray new];
		_cardViews = [NSMutableArray new];
		_timelineTweets = [NSMutableArray new];
	}
	
	return (self);
}


-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo {
	if ((self = [self initWithFrame:frame])) {
		_vo = vo;
		
		[self setBackgroundColor:[UIColor whiteColor]];
		
		self.layer.cornerRadius = 8.0;
		self.clipsToBounds = YES;
		
//		CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//		gradientLayer.frame = CGRectMake(self.frame.size.width, 0.0, 30.0, self.frame.size.height);
//		gradientLayer.colors = [NSArray arrayWithObjects: (id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
//		gradientLayer.startPoint = CGPointMake(-2.0, 0.5);
//		gradientLayer.endPoint = CGPointMake(1.0, 0.5);   
//		[self.layer addSublayer:gradientLayer];
		
		_articlesRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", 8] forKey:@"action"];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
		[_articlesRequest setDelegate:self];
		[_articlesRequest startAsynchronous];
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/lists/%d", _vo.list_id] withError:&error])
			NSLog(@"error in trackPageview");
		
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.frame.size.width, self.frame.size.height - 44.0)];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.opaque = YES;
		_scrollView.scrollsToTop = NO;
		_scrollView.pagingEnabled = YES;
		_scrollView.delegate = self;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.alwaysBounceVertical = NO;
		_scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
		[self addSubview:_scrollView];
		
		SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:_vo.list_name];
		[self addSubview:headerView];
		
		SNNavListBtnView *listBtnView = [[SNNavListBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
		[[listBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:listBtnView];
		
		SNNavLogoBtnView *logoBtnView = [[SNNavLogoBtnView alloc] initWithFrame:CGRectMake(276.0, 0.0, 44.0, 44.0)];
		[[logoBtnView btn] addTarget:self action:@selector(_goFlip) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:logoBtnView];
		
		_blackMatteView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		[_blackMatteView setBackgroundColor:[UIColor blackColor]];
		_blackMatteView.alpha = 0.0;
		[self addSubview:_blackMatteView];
	}
	
	return (self);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	
	if (CGRectContainsPoint(_videoPlayerView.frame, touchPoint))
		[_videoPlayerView toggleControls];//NSLog(@"TOUCHED:(%f, %f)", touchPoint.x, touchPoint.y);
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"START_TIMER" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"STOP_TIMER" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHOW_TWITTER_PROFILE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHOW_TWEET_PAGE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHOW_SOURCE_PAGE" object:nil];
}

#pragma mark - Navigation
-(void)_goBack {	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DISCOVERY_RETURN" object:nil];	
}

-(void)_goFlip {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_ARTICLE_SOURCES" object:nil];	
}

#pragma mark - Notification handlers
-(void)_leaveArticles:(NSNotification *)notification {
	[self _goBack];
}

-(void)_twitterTimeline:(NSNotification *)notification {
	_timelineTweets = (NSMutableArray *)[notification object];
}

#pragma mark - ScrollView delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_paginationView updToPage:round(scrollView.contentOffset.x / self.frame.size.width)];
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
	
	//[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Image View delegates
-(void)imageViewLoadedImage:(EGOImageView *)imageView {
	imageView.image = [SNAppDelegate imageWithFilters:imageView.image filter:[NSArray arrayWithObjects:
																									  [NSDictionary dictionaryWithObjectsAndKeys:
																										@"sepia", @"type", nil, nil], 
																									  nil]];
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	//NSLog(@"SNDiscoveryArticlesView_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	if ([request isEqual:_articlesRequest]) {
		@autoreleasepool {
			NSError *error = nil;
			NSArray *parsedArticles = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			if (error != nil)
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			else {
				NSMutableArray *articleList = [NSMutableArray array];
				_cardViews = [NSMutableArray new];
				
				int tot = 0;
				for (NSDictionary *serverArticle in parsedArticles) {
					SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverArticle];
					//NSLog(@"ARTICLE \"%@\"", vo.title);
					
					if (vo != nil)
						[articleList addObject:vo];
					
					int height = 220;
					CGSize size;
					
					if (vo.type_id > 1) {
						height += 270.0 * vo.imgRatio;
						height += 20;
					}
					
					size = [vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:16] constrainedToSize:CGSizeMake(227.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
					height += size.height;
					
					if (vo.type_id > 4)
						height += 222;
					
					
					SNDiscoveryArticleCardView_iPhone *articleItemView = [[SNDiscoveryArticleCardView_iPhone alloc] initWithFrame:CGRectMake(tot * 320.0, 0.0, _scrollView.frame.size.width, height) articleVO:vo];
					[_cardViews addObject:articleItemView];
					
					tot++;					
				}
				
				_articles = [articleList copy];
				for (SNDiscoveryArticleCardView_iPhone *itemView in _cardViews)
					[_scrollView addSubview:itemView];
				
				_scrollView.contentSize = CGSizeMake(tot * 320.0, self.frame.size.height - 44.0);
				
				_paginationView = [[SNPaginationView alloc] initWithTotal:[_cardViews count] coords:CGPointMake(160.0, 460.0)];
				[self addSubview:_paginationView];
			}
		}
	}
}


-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
