//
//  SNProfileTimelineViewController.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.24.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNProfileTimelineViewController.h"
#import "SNAppDelegate.h"
#import "MBLResourceLoader.h"
#import "SNImageVO.h"
#import "SNArticleItemView.h"
#import "GANTracker.h"
#import "SNProfileStatsView.h"
#import "SNHeaderView.h"
#import "SNNavBackBtnView.h"

@interface SNProfileTimelineViewController () <MBLResourceObserverProtocol>
@property(nonatomic, strong) MBLAsyncResource *articleListResource;
@property(nonatomic, strong) MBLAsyncResource *updateListResource;

- (void)_retrieveArticleList;
- (void)_updateArticleList;
- (void)reloadTableViewDataSource;

@end

@implementation SNProfileTimelineViewController

@synthesize articleListResource = _articleListResource;
@synthesize updateListResource = _updateListResource;

- (id)initWithUserID:(int)userID {
	if ((self = [super init])) {
		NSLog(@"USER ID:[%d]", userID);
		
		_userID = userID;
		_articles = [NSMutableArray new];
		_articleViews = [NSMutableArray new];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)loadView
{
	[super loadView];
	
	NSError *error;
	if (![[GANTracker sharedTracker] trackPageview:@"/activity/" withError:&error])
		NSLog(@"error in trackPageview");
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
	bgImgView.image = [UIImage imageNamed:@"background_timeline.png"];
	[self.view addSubview:bgImgView];
	
	_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	_activityIndicatorView.frame = CGRectMake(15.0, 60.0, 20.0, 20.0);
	[_activityIndicatorView startAnimating];
	[self.view addSubview:_activityIndicatorView];
	
	_loaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 63.0, 245.0, 16.0)];
	_loaderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_loaderLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	_loaderLabel.textColor = [UIColor blackColor];
	_loaderLabel.backgroundColor = [UIColor clearColor];
	_loaderLabel.text = @"Assembling Profile…";
	[self.view addSubview:_loaderLabel];
	
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.view.frame.size.width, self.view.frame.size.height - 44.0)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.opaque = NO;
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.delegate = self;
	_scrollView.showsVerticalScrollIndicator = YES;
	_scrollView.alwaysBounceVertical = NO;
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
	[self.view addSubview:_scrollView];
	
	SNProfileStatsView *profileStatsView = [[SNProfileStatsView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 84.0)];
	[_scrollView addSubview:profileStatsView];
	
	//		_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.frame.size.height, self.frame.size.width, self.frame.size.height)];
	//		_refreshHeaderView.delegate = self;
	//		[_scrollView addSubview:_refreshHeaderView];
	//		[_refreshHeaderView refreshLastUpdatedDate];
	
	
	SNHeaderView *headerView = [[SNHeaderView alloc] initWithTitle:@""];
	[self.view addSubview:headerView];
	
	
	SNNavBackBtnView *backBtnView = [[SNNavBackBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 64.0, 44.0)];
	[[backBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backBtnView];
	
	
	[self _retrieveArticleList];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Navigation
- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}



- (void)setArticleListResource:(MBLAsyncResource *)articleListResource {
	if (_articleListResource != nil) {
		[_articleListResource unsubscribe:self];
		_articleListResource = nil;
	}
	
	_articleListResource = articleListResource;
	
	if (_articleListResource != nil)
		[_articleListResource subscribe:self];
}

- (void)setUpdateListResource:(MBLAsyncResource *)updateListResource {
	if (_updateListResource != nil) {
		[_updateListResource unsubscribe:self];
		_updateListResource = nil;
	}
	
	_updateListResource = updateListResource;
	
	if (_updateListResource != nil)
		[_updateListResource subscribe:self];
}

- (void)_retrieveArticleList {
	if (_articleListResource == nil) {

		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 15] forKey:@"action"];
		[formValues setObject:[NSString stringWithFormat:@"%d", _userID] forKey:@"userID"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, kArticlesAPI];
		self.articleListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate dateWithTimeIntervalSinceNow:60.0]]; // 1 minute for now
	}
}

- (void)_updateArticleList {
	if (_updateListResource == nil) {
		
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 12] forKey:@"action"];
		[formValues setObject:[NSString stringWithFormat:@"%d", _userID] forKey:@"userID"];
		[formValues setObject:[dateFormat stringFromDate:_lastDate] forKey:@"datetime"];
		
		NSLog(@"LAST DATE:[%@]", [dateFormat stringFromDate:_lastDate]);
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, kArticlesAPI];
		self.updateListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate date]]; // 1 hour expiration for now
	}
}


#pragma mark - EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
	return _reloading; // should return if data source model is reloading
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
	return [NSDate date]; // should return date data source was last change	
}

- (void)reloadTableViewDataSource {
	_reloading = YES;
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	//	if (_vo.topic_id == 0) {
	//		[self _updatePopularList];
	//	
	//	} else {
	//		NSLog(@"\n\n\n\n%d\n\n\n\n", _lastID);
	//		[self _updateTopicList];
	//	}
	
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.33];
} 

- (void)doneLoadingTableViewData {
	_reloading = NO;
	
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
}


#pragma mark - Async Resource Observers
- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data {
	NSLog(@"MBLAsyncResource.data [%@]", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	
	if (resource == _articleListResource) {
		NSError *error = nil;
		//NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		//NSArray *unsortedLists = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];//[unsortedLists sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
		
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedDescription]);

			
		} else {			
			if ([parsedLists count] > 0) {
				
				NSMutableArray *list = [NSMutableArray array];
				
				int tot = 0;
				int offset = 102;
				for (NSDictionary *serverList in parsedLists) {
					SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverList];
					//NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
					if (vo != nil)
						[list addObject:vo];
					
					int height = 87;
					
					CGSize size;
					
					height = 87;
					
					if (vo.totalLikes > 0) {
						height += 45;
					}
					
					int imgWidth = 290;
					//				if (vo.topicID == 1 || vo.topicID == 2)
					//					imgWidth = 296;			
					
					if ([vo.article_url rangeOfString:@"itunes.apple.com"].length > 0) {
						//						imgWidth = 145;
						//						//height -= 2;
						height += 39;
						
						if (((SNImageVO *)[vo.images objectAtIndex:0]).ratio > 1.0)
							height--;
					}
					
					if (vo.type_id > 1 && vo.type_id - 4 < 0) {
						height += imgWidth * ((SNImageVO *)[vo.images objectAtIndex:0]).ratio;
						height += 9; //20
					}
					
					
					if (vo.topicID == 1 || vo.topicID == 2) {
						size = [vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:13] constrainedToSize:CGSizeMake(260.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
						height += size.height + 11;
						
					} else if (vo.topicID == 10)
						height += 6;
					
					else
						height += 4;
					
					if (vo.type_id > 3) {
						height += 217;
						height += 7; //9
					}
					
					SNArticleItemView *articleItemView = [[SNArticleItemView alloc] initWithFrame:CGRectMake(10.0, offset, _scrollView.frame.size.width - 20.0, height) articleVO:vo showImage:YES];
					[_articleViews addObject:articleItemView];
					
					offset += height;
					tot++;
					
					offset += 3;
				}
				
				_articles = list;
				
				for (SNArticleItemView *itemView in _articleViews) {
					[_scrollView addSubview:itemView];
				}
				
				offset += 12.0;
				
				if ([_articles count] >= 10) {
					_loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
					_loadMoreButton.frame = CGRectMake(118.0, offset, 84.0, 38.0);
					[_loadMoreButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
					[_loadMoreButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
					[_loadMoreButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
					[_loadMoreButton addTarget:self action:@selector(_goLoadMore) forControlEvents:UIControlEventTouchUpInside];
					_loadMoreButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
					[_loadMoreButton setTitle:@"Load More" forState:UIControlStateNormal];
					[_scrollView addSubview:_loadMoreButton];
					offset += 80.0;
				}
				
				_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, offset);
				
				if ([_articles count] > 0) {
					_lastDate = ((SNArticleVO *)[_articles lastObject]).added;
					
					//NSLog(@"FIST DATE:[%@]", ((SNArticleVO *)[_articles objectAtIndex:0]).added);
					//NSLog(@"LAST DATE:[%@]", _lastDate);
				}
				
				[_activityIndicatorView removeFromSuperview];
				[_loaderLabel removeFromSuperview];
				
				_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
				_refreshHeaderView.delegate = self;
				[_scrollView addSubview:_refreshHeaderView];
				[_refreshHeaderView refreshLastUpdatedDate];
				
			} else {
				UIAlertView *alert = [[UIAlertView alloc] 
											 initWithTitle:@"Refresh Error!" 
											 message:@"Cannot Refresh Content"
											 delegate:nil
											 cancelButtonTitle:@"OK" 
											 otherButtonTitles:nil];
				
				[alert show];
				
				[_activityIndicatorView removeFromSuperview];
				[_loaderLabel removeFromSuperview];
			}
		}
		
	} else if (resource == _updateListResource) {
		NSError *error = nil;
		
		NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];//[unsortedLists sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedDescription]);
			
		} else {
			NSMutableArray *list = [NSMutableArray array];
			
			int tot = 0;
			int offset = _scrollView.contentSize.height - 75;
			for (NSDictionary *serverList in parsedLists) {
				SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverList];
				//NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
				if (vo != nil)
					[list addObject:vo];
				
				int height;
				height = 87;
				CGSize size;
				
				if (vo.totalLikes > 0) {
					height += 45;
				}
				
				int imgWidth = 290;
				if ([vo.article_url rangeOfString:@"itunes.apple.com"].length > 0) {
					//					imgWidth = 145;
					//height -= 2;
					height += 39;
					
					if (((SNImageVO *)[vo.images objectAtIndex:0]).ratio > 1.0)
						height--;
				}
				
				
				if (vo.type_id > 1 && vo.type_id - 4 < 0) {
					height += imgWidth * ((SNImageVO *)[vo.images objectAtIndex:0]).ratio;
					height += 9; //20
				}
				
				if (vo.topicID == 1 || vo.topicID == 2) {
					size = [vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:13] constrainedToSize:CGSizeMake(260.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
					height += size.height + 11;
					
				} else if (vo.topicID == 10)
					height += 6;
				
				else
					height += 4;
				
				if (vo.type_id > 3) {
					height += 217;
					height += 7; //9
				}
				
				SNArticleItemView *articleItemView = [[SNArticleItemView alloc] initWithFrame:CGRectMake(10.0, offset, _scrollView.frame.size.width - 20.0, height) articleVO:vo showImage:YES];
				[_articleViews addObject:articleItemView];
				
				[_scrollView addSubview:articleItemView];
				
				offset += height;
				tot++;
			}
			
			
			[_articles addObjectsFromArray:list];
			
			offset += 12.0;
			
			if ([_articles count] < 250) {
				_loadMoreButton.alpha = 1.0;
				_loadMoreButton.frame = CGRectMake(112.0, offset, 96.0, 44.0);
			}
			
			[_activityIndicatorView removeFromSuperview];
			[_loaderLabel removeFromSuperview];
			
			offset += 60.0;
			_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, offset);
			
			if ([_articles count] > 0) {
				_lastDate = ((SNArticleVO *)[_articles lastObject]).added;
				
				//NSLog(@"FIST DATE:[%@]", ((SNArticleVO *)[_articles objectAtIndex:0]).added);
				//NSLog(@"LAST DATE:[%@]", _lastDate);
			}
			
		}
	}
}


- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error
{
}

@end
