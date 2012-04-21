//
//  SNFinalListCardView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNFinalListCardView_iPhone.h"
#import "SNListVO.h"
#import "SNListItemViewCell_iPhone.h"

@implementation SNFinalListCardView_iPhone

-(id)initWithFrame:(CGRect)frame addlLists:(NSMutableArray *)lists {
	if ((self = [super initWithFrame:frame])) {
		_lists = lists;
		
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
		[_tableView setBackgroundColor:[UIColor clearColor]];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		_tableView.rowHeight = 74.0;
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.scrollsToTop = NO;
		_tableView.showsVerticalScrollIndicator = NO;
		[_holderView addSubview:_tableView];
	}
	
	return (self);
}

#pragma mark - TableView DataSource Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_lists count]);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNListItemViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNListItemViewCell_iPhone cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[[SNListItemViewCell_iPhone alloc] init] autorelease];
	
	cell.listVO = (SNListVO *)[_lists objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return cell;	
}


#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (74.0);
}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	return (indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	SNListVO *vo = (SNListVO *)[_lists objectAtIndex:indexPath.row];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"LIST_ARTICLES" object:vo];
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TWITTER_PROFILE2" object:vo.handle];
}

@end
