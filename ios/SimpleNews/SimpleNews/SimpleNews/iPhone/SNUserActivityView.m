//
//  SNUserActivityView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.22.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNAppDelegate.h"

#import "SNUserActivityView.h"
#import "SNActivityViewCell.h"
#import "SNArticleVO.h"
#import "SNHeaderView.h"
#import "MBLResourceLoader.h"

@interface SNUserActivityView () <MBLResourceObserverProtocol>
- (void)_refreshActivityList;
@property(nonatomic, strong) MBLAsyncResource *activityListResource;
@end


@implementation SNUserActivityView

@synthesize activityListResource = _activityListResource;

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		_articles = [NSMutableArray new];
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
		bgImgView.image = [UIImage imageNamed:@"background_timeline.png"];
		[self addSubview:bgImgView];
		
		SNHeaderView *headerView = [[SNHeaderView alloc] initWithTitle:@"Activity"];
		[self addSubview:headerView];
		
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, 320.0, self.frame.size.height - 45.0) style:UITableViewStylePlain];
		[_tableView setBackgroundColor:[UIColor clearColor]];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_tableView.rowHeight = 50.0;
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.scrollsToTop = NO;
		_tableView.showsVerticalScrollIndicator = NO;
		_tableView.userInteractionEnabled = NO;
		[self addSubview:_tableView];
		
		_tabNavView = [[SNTabNavView alloc] initWithFrame:CGRectMake(0.0, 420.0, 320.0, 60.0)];
		[self addSubview:_tabNavView];
		
		[[_tabNavView feedButton] addTarget:self action:@selector(_goFeed) forControlEvents:UIControlEventTouchUpInside];
		[[_tabNavView popularButton] addTarget:self action:@selector(_goPopular) forControlEvents:UIControlEventTouchUpInside];
		[[_tabNavView activityButton] addTarget:self action:@selector(_goActivity) forControlEvents:UIControlEventTouchUpInside];
		[[_tabNavView profileButton] addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
		[[_tabNavView composeButton] addTarget:self action:@selector(_goCompose) forControlEvents:UIControlEventTouchUpInside];
		
		[self _refreshActivityList];
	}
	
	return (self);
}

- (void)setActivityListResource:(MBLAsyncResource *)activityListResource
{
	if (_activityListResource != nil) {
		[_activityListResource unsubscribe:self];
		_activityListResource = nil;
	}
	
	_activityListResource = activityListResource;
	
	if (_activityListResource != nil)
		[_activityListResource subscribe:self];
}

- (void)_refreshActivityList
{
	if (_activityListResource == nil) {
		//		_hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		//		_hud.labelText = NSLocalizedString(@"Loading Topics…", @"Status message when loading topics list");
		//		_hud.mode = MBProgressHUDModeIndeterminate;
		//		_hud.graceTime = 2.0;
		//		_hud.taskInProgress = YES;
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
		[formValues setObject:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, kArticlesAPI];
		self.activityListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:NO expiration:[NSDate dateWithTimeIntervalSinceNow:(60.0 * 60.0 * 24.0)]]; // 1 day expiration for now
	}
}


#pragma mark - Navigation
- (void)_goFeed {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_FEED" object:nil];
}

- (void)_goPopular {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_POPULAR" object:nil];
}

- (void)_goActivity {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_ACTIVITY" object:nil];
}

- (void)_goProfile {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_PROFILE" object:nil];
}

- (void)_goCompose {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_COMPOSER" object:nil];
}


#pragma mark - AsyncResource Observers
- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data
{
	NSLog(@"MBLAsyncResource.data [%@]", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	if (resource == _activityListResource) {
		_hud.taskInProgress = NO;
		
		NSError *error = nil;
		//NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		//NSArray *unsortedLists = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];//[unsortedLists sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
		
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedDescription]);
			_hud.graceTime = 0.0;
			_hud.mode = MBProgressHUDModeCustomView;
			_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
			_hud.labelText = NSLocalizedString(@"Download Failed", @"Status message when downloading fails");
			[_hud show:NO];
			[_hud hide:YES afterDelay:1.5];
			_hud = nil;
		
		} else {
			NSMutableArray *list = [NSMutableArray array];
			for (NSDictionary *serverList in parsedLists) {
				SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverList];
				//NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
				if (vo != nil)
					[list addObject:vo];
			}
			
			[_hud hide:YES];
			_hud = nil;
			
			_articles = list;
			[_tableView reloadData];
			_tableView.userInteractionEnabled = YES;
		}
	}
}

- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error
{
	if (_hud != nil) {
		_hud.graceTime = 0.0;
		_hud.mode = MBProgressHUDModeCustomView;
		_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
		_hud.labelText = NSLocalizedString(@"Error", @"Error");
		[_hud show:NO];
		[_hud hide:YES afterDelay:1.5];
		_hud = nil;
	}
	
	// Show an error overlay?	
	if (resource == _activityListResource)
		_activityListResource = nil;
}



#pragma mark - TableView DataSource Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_articles count]);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNActivityViewCell *activityCell;
	
	switch (indexPath.section) {
		case 0:
			activityCell = [tableView dequeueReusableCellWithIdentifier:[SNActivityViewCell cellReuseIdentifier]];
			
			if (activityCell == nil)
				activityCell = [[SNActivityViewCell alloc] init];
			
			activityCell.articleVO = (SNArticleVO *)[_articles objectAtIndex:indexPath.row];
			[activityCell setSelectionStyle:UITableViewCellSelectionStyleNone];
			
			return (activityCell);
			break;
			
		default:
			return (nil);
			break;
	}
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (50.0);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
	[((SNActivityViewCell *)[tableView cellForRowAtIndexPath:indexPath]) tapped];
}

@end
