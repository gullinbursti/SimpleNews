//
//  SNInfluencerProfileViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.25.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNInfluencerProfileViewController_iPhone.h"
#import "SNAppDelegate.h"
#import "SNArticleVO.h"
#import "SNProfileArticleView_iPhone.h"

#import "SNOptionsPageViewController.h"

#import "EGOImageView.h"

@implementation SNInfluencerProfileViewController_iPhone

-(id)initWithInfluencerVO:(SNInfluencerVO *)vo {
	if ((self = [super init])) {
		_vo = vo;
		
		_articlesRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
		[_articlesRequest setPostValue:[SNAppDelegate subscribedInfluencers] forKey:@"influencers"];
		[_articlesRequest setTimeOutSeconds:30];
		[_articlesRequest setDelegate:self];
		[_articlesRequest startAsynchronous];
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)dealloc {
	[super dealloc];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	[self.view setBackgroundColor:[UIColor colorWithWhite:0.176 alpha:1.0]];
	
	UIImageView *headerImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 56.0)] autorelease];
	headerImgView.image = [UIImage imageNamed:@"subheaderBG.png"];
	[self.view addSubview:headerImgView];
	
	UIImageView *titleImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(100.0, 21.0, 114.0, 14.0)] autorelease];
	titleImgView.image = [UIImage imageNamed:@"titleProfile.png"];
	[self.view addSubview:titleImgView];
	
	UIButton *backButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
	backButton.frame = CGRectMake(12.0, 12.0, 64.0, 34.0);
	[backButton setBackgroundImage:[[UIImage imageNamed:@"backButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[[UIImage imageNamed:@"backButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	backButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	backButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	backButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 4.0, 0.0, -4.0);
	backButton.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	backButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	[backButton setTitle:@"Back" forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	UIButton *viewButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	viewButton.frame = CGRectMake(250.0, 12.0, 64.0, 34.0);
	[viewButton setBackgroundImage:[[UIImage imageNamed:@"doneButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[viewButton setBackgroundImage:[[UIImage imageNamed:@"doneButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	viewButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	viewButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[viewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	viewButton.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	viewButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	[viewButton setTitle:@"View" forState:UIControlStateNormal];
	[viewButton addTarget:self action:@selector(_goArticles) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:viewButton];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 56.0, self.view.bounds.size.width, self.view.bounds.size.height - 56.0)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.opaque = YES;
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.delegate = self;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.alwaysBounceVertical = NO;
	_scrollView.contentSize = self.view.frame.size;
	[self.view addSubview:_scrollView];
	
	_infoSize = [_vo.blurb sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:12] constrainedToSize:CGSizeMake(296.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	
	UIImageView *bgImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, -350.0 + _infoSize.height, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
	bgImgView.image = [UIImage imageNamed:@"background.jpg"];
	[_scrollView addSubview:bgImgView];
	
	EGOImageView *avatarImgView = [[[EGOImageView alloc] initWithFrame:CGRectMake(12.0, 12.0, 75.0, 75.0)] autorelease];
	avatarImgView.imageURL = [NSURL URLWithString:_vo.avatar_url];
	[_scrollView addSubview:avatarImgView];
	
	UILabel *nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(100.0, 31.0, 195.0, 26.0)] autorelease];
	nameLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:16];
	nameLabel.textColor = [UIColor whiteColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	nameLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	nameLabel.text = _vo.influencer_name;
	[_scrollView addSubview:nameLabel];
	
	int offset = 0;
	for (NSNumber *srcType in _vo.sources) {
		UIImageView *iconImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(100.0 + offset, 55.0, 14.0, 14.0)] autorelease];
		
		switch ([srcType intValue]) {
			case 1:
				iconImgView.image = [UIImage imageNamed:@"twitterIcon.png"];
				break;
				
			case 2:
				iconImgView.image = [UIImage imageNamed:@"facebookIcon.png"];
				break;
				
			case 3:
				iconImgView.image = [UIImage imageNamed:@"wordPressIcon.png"];
				break;
				
			case 4:
				iconImgView.image = [UIImage imageNamed:@"tumblerIcon.png"];
				break;
		}
		
		[_scrollView addSubview:iconImgView];
		offset += 18;
	}
	
	UILabel *infoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 107.0, 296.0, _infoSize.height)] autorelease];
	infoLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:12];
	infoLabel.textColor = [UIColor colorWithWhite:0.816 alpha:1.0];
	infoLabel.backgroundColor = [UIColor clearColor];
	infoLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	infoLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	infoLabel.text = _vo.blurb;
	infoLabel.numberOfLines = 0;
	[_scrollView addSubview:infoLabel];
	
	NSString *total = @"";
	if (_vo.totalArticles == 1)
		total = @"%d news story";
	
	else
		total = @"%d news stories";
	
	UIButton *profileButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
	profileButton.frame = CGRectMake(0.0, 0.0, _scrollView.frame.size.width, 100.0 + _infoSize.height);
	[profileButton addTarget:self action:@selector(_goProfilePage) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:profileButton];
	
	
	UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 135.0 + _infoSize.height, 214.0, 26.0)];
	totalLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:16];
	totalLabel.textColor = [UIColor whiteColor];
	totalLabel.backgroundColor = [UIColor clearColor];
	totalLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	totalLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	totalLabel.text = [NSString stringWithFormat:total, _vo.totalArticles];
	[_scrollView addSubview:totalLabel];
	
	UIImageView *overlayImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
	[self.view addSubview:overlayImgView];
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

-(void)_goArticles {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_NOW_PLAYING" object:nil];
}

-(void)_goProfilePage {
	SNOptionsPageViewController *tweetPageViewController = [[[SNOptionsPageViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@/", _vo.handle]]] autorelease];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:tweetPageViewController animated:YES];
}

#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

// called on start of dragging (may require some time and or distance to move)
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{	
}

// called on finger up as we are moving
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
}

// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
}

// called when scroll view grinds to a halt
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}



#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	//NSLog(@"SNArticleListViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	if ([request isEqual:_articlesRequest]) {
		@autoreleasepool {
			NSError *error = nil;
			NSArray *parsedArticles = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			if (error != nil)
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			else {
				NSMutableArray *articleList = [NSMutableArray array];
				_articleViews = [NSMutableArray new];
				
				int tot = 0;
				for (NSDictionary *serverArticle in parsedArticles) {
					SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverArticle];
					
					//NSLog(@"ARTICLE \"%@\"", vo.title);
					
					if (vo != nil)
						[articleList addObject:vo];
					
					SNProfileArticleView_iPhone *articleView = [[[SNProfileArticleView_iPhone alloc] initWithFrame:CGRectMake(0.0, 160.0 + _infoSize.height + (tot * 90.0), self.view.frame.size.width, 180.0) articleVO:vo] autorelease];
					[_articleViews addObject:articleView];
					
					tot++;
				}
				
				_articles = [articleList retain];
				
				for (SNProfileArticleView_iPhone *articleView in _articleViews)
					[_scrollView addSubview:articleView];
				
				_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, 175.0 + _infoSize.height + (tot * 90.0));
			}
		}	
	}
}


-(void)requestFailed:(ASIHTTPRequest *)request {
	if (request == _articlesRequest) {
		//[_delegates perform:@selector(jobList:didFailLoadWithError:) withObject:self withObject:request.error];
		//MBL_RELEASE_SAFELY(_jobListRequest);
	}
	
	//[_loadOverlay remove];
}

@end
