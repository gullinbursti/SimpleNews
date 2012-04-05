//
//  SNInfluencersListView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SNInfluencersListView.h"
#import "SNInfluencerListViewCell_iPhone.h"
#import "SNInfluencerVO.h"
#import "SNAppDelegate.h"

@implementation SNInfluencersListView

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		self.layer.cornerRadius = 8.0;
		self.clipsToBounds = YES;
		self.layer.borderColor = [[UIColor colorWithWhite:0.671 alpha:1.0] CGColor];
		self.layer.borderWidth = 1.0;
		
		_listInfoView = [[SNListInfoView_iPhone alloc] initWithFrame:CGRectMake(15.0, 4.0, self.frame.size.width - 30.0, 80.0) listVO:_vo];
		[self addSubview:_listInfoView];
		
		UIImageView *gripImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(135.0, 0.0, 49.0, 14.0)] autorelease];
		gripImgView.image = [UIImage imageNamed:@"gripDown.png"];
		[self addSubview:gripImgView];
		
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 70.0, self.frame.size.width, self.frame.size.height - 70.0) style:UITableViewStylePlain];
		[_tableView setBackgroundColor:[UIColor clearColor]];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_tableView.rowHeight = 60.0;
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.allowsSelection = NO;
		_tableView.pagingEnabled = NO;
		_tableView.opaque = NO;
		_tableView.scrollsToTop = NO;
		_tableView.showsHorizontalScrollIndicator = NO;
		_tableView.showsVerticalScrollIndicator = NO;
		_tableView.alwaysBounceVertical = NO;
		[self addSubview:_tableView];
		
		_influencers = [NSMutableArray new];
		
		_influencersRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]] retain];
		[_influencersRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
		[_influencersRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
		[_influencersRequest setTimeOutSeconds:30];
		[_influencersRequest setDelegate:self];
		[_influencersRequest startAsynchronous];
	}
	
	return (self);
}

-(void)dealloc {
	[super dealloc];
}


#pragma mark - TableView DataSource Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"numberOfRowsInSection:[%d]", [_influencers count]);
	return ([_influencers count]);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNInfluencerListViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNInfluencerListViewCell_iPhone cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[[SNInfluencerListViewCell_iPhone alloc] init] autorelease];
	
	cell.influencerVO = (SNInfluencerVO *)[_influencers objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	[cell setUserInteractionEnabled:NO];
	
	return cell;	
}


#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (60.0);
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (29.0);
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	//NSLog(@"viewForHeaderInSection:[%@]", [_categories objectAtIndex:section]);
	
	UIView *sectionHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _tableView.frame.size.width, 29.0)] autorelease];
	
	UIImageView *bgImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 297.0, 29.0)] autorelease];
	bgImgView.image = [UIImage imageNamed:@"listHeaderBG.png"];
	[sectionHeaderView addSubview:bgImgView];
	
	UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 5.0, 296.0, 16.0)] autorelease];
	titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:11];
	titleLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	titleLabel.text = [NSString stringWithFormat:@"Following (%d)", [_influencers count]];;
	[sectionHeaderView addSubview:titleLabel];
	
	return (sectionHeaderView);
}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	return (nil);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNInfluencersListView_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSArray *parsedInfluencers = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSMutableArray *list = [NSMutableArray array];
			for (NSDictionary *serverInfluencer in parsedInfluencers) {
				SNInfluencerVO *vo = [SNInfluencerVO influencerWithDictionary:serverInfluencer];
				NSLog(@"LIST \"@%@\"", vo.handle);
				
				if (vo != nil)
					[list addObject:vo];
			}
			
			_influencers = [list retain];
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
