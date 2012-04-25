//
//  SNFlippedArticleView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "GANTracker.h"
#import "SNFlippedArticleView_iPhone.h"
#import "SNAppDelegate.h"
#import "SNInfluencerListViewCell_iPhone.h"
#import "SNInfluencerVO.h"
#import "SNHeaderView_iPhone.h"

@implementation SNFlippedArticleView_iPhone

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		[self setBackgroundColor:[UIColor whiteColor]];
		
		SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] init];
		[self addSubview:headerView];
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 14.0, 200.0, 20.0)];
		titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:18];
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.text = _vo.list_name;
		[self addSubview:titleLabel];
		
		UIImageView *verifiedImgView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 55.0, 24.0, 24.0)];
		verifiedImgView.image = [UIImage imageNamed:@"verifiedIcon.png"];
		[self addSubview:verifiedImgView];
		
		UILabel *curatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(38.0, 57.0, 200.0, 20.0)];
		curatorLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:14];
		curatorLabel.textColor = [UIColor blackColor];
		curatorLabel.backgroundColor = [UIColor clearColor];
		curatorLabel.text = @"Curators Verified";
		[self addSubview:curatorLabel];
		
		CGSize infoSize = [_vo.list_info sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:14] constrainedToSize:CGSizeMake(270.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 91.0, 270.0, infoSize.height)];
		infoLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:14];
		infoLabel.textColor = [UIColor colorWithWhite:0.486 alpha:1.0];
		infoLabel.backgroundColor = [UIColor clearColor];
		infoLabel.numberOfLines = 0;
		infoLabel.text = _vo.list_info;
		[self addSubview:infoLabel];
		
		int offset = 0;
		if (!_vo.isSubscribed) {
			UIButton *subscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
			subscribeButton.frame = CGRectMake(12.0, 104.0 + infoSize.height, 84.0, 30.0);
			[subscribeButton setBackgroundImage:[UIImage imageNamed:@"followButton_nonActive.png"] forState:UIControlStateNormal];
			[subscribeButton setBackgroundImage:[UIImage imageNamed:@"followButton_Active.png"] forState:UIControlStateHighlighted];
			[subscribeButton addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
			subscribeButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11.0];
			subscribeButton.titleLabel.textAlignment = UITextAlignmentCenter;
			[subscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			[subscribeButton setTitle:@"Follow Topic" forState:UIControlStateNormal];
			[self addSubview:subscribeButton];
			offset = 44;
		}
		
		UIView *subheaderLineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, offset + 104.0 + infoSize.height, self.frame.size.width, 1.0)];
		[subheaderLineView setBackgroundColor:[UIColor colorWithWhite:0.545 alpha:1.0]];
		[self addSubview:subheaderLineView];
		
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, offset + 104.0 + infoSize.height, self.frame.size.width, self.frame.size.height - (offset + 104.0 + infoSize.height)) style:UITableViewStylePlain];
		[_tableView setBackgroundColor:[UIColor clearColor]];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_tableView.rowHeight = 60.0;
		_tableView.delegate = self;
		_tableView.dataSource = self;
		//_tableView.allowsSelection = NO;
		_tableView.scrollsToTop = NO;
		_tableView.showsVerticalScrollIndicator = NO;
		[self addSubview:_tableView];
		
		UIImageView *overlayImgView = [[UIImageView alloc] initWithFrame:self.frame];
		overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
		[self addSubview:overlayImgView];
		
		_influencers = [NSMutableArray new];
		
		_influencersRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]];
		[_influencersRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
		[_influencersRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
		[_influencersRequest setDelegate:self];
		[_influencersRequest startAsynchronous];
	}
	
	return (self);
}

#pragma mark - Navigation 
-(void)_goSubscribe {
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		
		[alert show];
		
	} else {
		ASIFormDataRequest *subscribeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]];
		[subscribeRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
		[subscribeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[subscribeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
		[subscribeRequest setDelegate:self];
		[subscribeRequest startAsynchronous];
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackEvent:@"Following Topic" action:_vo.list_name label:nil value:-1 withError:&error])
			NSLog(@"error in trackEvent");
	}
}


#pragma mark - TableView DataSource Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_influencers count]);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNInfluencerListViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNInfluencerListViewCell_iPhone cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[SNInfluencerListViewCell_iPhone alloc] init];
	
	cell.influencerVO = (SNInfluencerVO *)[_influencers objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return cell;	
}


#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (60.0);
}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	return (indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	SNInfluencerVO *vo = (SNInfluencerVO *)[_influencers objectAtIndex:indexPath.row];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TWITTER_PROFILE" object:vo.handle];
}

#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	//NSLog(@"SNFlippedArticleView_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSArray *parsedInfluencers = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSMutableArray *list = [NSMutableArray array];
			for (NSDictionary *serverInfluencer in parsedInfluencers) {
				SNInfluencerVO *vo = [SNInfluencerVO influencerWithDictionary:serverInfluencer];
				//NSLog(@"LIST \"@%@\"", vo.handle);
				
				if (vo != nil)
					[list addObject:vo];
			}
			
			_influencers = [list copy];
			[_tableView reloadData];
		}
	}
}


-(void)requestFailed:(ASIHTTPRequest *)request {
	if (request == _influencersRequest) {
		//[_delegates perform:@selector(jobList:didFailLoadWithError:) withObject:self withObject:request.error];
		//MBL_RELEASE_SAFELY(_jobListRequest);
	}
	
	//[_loadOverlay remove];
}


@end
