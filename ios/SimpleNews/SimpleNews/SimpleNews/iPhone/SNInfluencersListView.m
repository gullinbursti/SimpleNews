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
#import "SNCuratorVO.h"
#import "SNAppDelegate.h"

@implementation SNInfluencersListView

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		self.layer.cornerRadius = 8.0;
		self.clipsToBounds = YES;
		self.layer.borderColor = [[UIColor colorWithWhite:0.671 alpha:1.0] CGColor];
		self.layer.borderWidth = 1.0;
		
		UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 45.0)] autorelease];
		[headerView setBackgroundColor:[UIColor colorWithWhite:0.941 alpha:1.0]];
		[self addSubview:headerView];
		
		UIView *headerLineView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 45.0, self.frame.size.width, 1.0)] autorelease];
		[headerLineView setBackgroundColor:[UIColor colorWithWhite:0.545 alpha:1.0]];
		[self addSubview:headerLineView];
		
		UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(15.0, 14.0, 200.0, 20.0)] autorelease];
		titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:18];
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.text = _vo.list_name;
		[self addSubview:titleLabel];
		
		UIImageView *verifiedImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(12.0, 55.0, 24.0, 24.0)] autorelease];
		verifiedImgView.image = [UIImage imageNamed:@"verifiedIcon.png"];
		[self addSubview:verifiedImgView];
		
		UILabel *curatorLabel = [[[UILabel alloc] initWithFrame:CGRectMake(38.0, 57.0, 200.0, 20.0)] autorelease];
		curatorLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:14];
		curatorLabel.textColor = [UIColor blackColor];
		curatorLabel.backgroundColor = [UIColor clearColor];
		curatorLabel.text = @"Curators Verified";
		[self addSubview:curatorLabel];
		
		CGSize infoSize = [_vo.list_info sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:14] constrainedToSize:CGSizeMake(270.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		UILabel *infoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 91.0, 270.0, infoSize.height)] autorelease];
		infoLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:14];
		infoLabel.textColor = [UIColor colorWithWhite:0.486 alpha:1.0];
		infoLabel.backgroundColor = [UIColor clearColor];
		infoLabel.numberOfLines = 0;
		infoLabel.text = _vo.list_info;
		[self addSubview:infoLabel];
		
		UIView *subheaderLineView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 104.0 + infoSize.height, self.frame.size.width, 1.0)] autorelease];
		[subheaderLineView setBackgroundColor:[UIColor colorWithWhite:0.545 alpha:1.0]];
		[self addSubview:subheaderLineView];
		
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 104.0 + infoSize.height, self.frame.size.width, self.frame.size.height - (104.0 + infoSize.height)) style:UITableViewStylePlain];
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
