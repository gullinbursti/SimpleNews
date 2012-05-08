//
//  SNFollowingListViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.07.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNFollowingListViewCell_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNFollowingListViewCell_iPhone

@synthesize listVO = _listVO;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)init {
	if ((self = [super init])) {		
		_followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_followButton.frame = CGRectMake(160.0, 10.0, 84.0, 44.0);
		[_followButton setBackgroundImage:[UIImage imageNamed:@"followButton_nonActive.png"] forState:UIControlStateNormal];
		[_followButton setBackgroundImage:[UIImage imageNamed:@"followButton_Active.png"] forState:UIControlStateHighlighted];
		[_followButton addTarget:self action:@selector(_goToggleFollow) forControlEvents:UIControlEventTouchUpInside];
		[_followButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		_followButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
		[self addSubview:_followButton];
	}
	
	return (self);
}

#pragma mark - Accessors
- (void)setListVO:(SNListVO *)listVO {
	_listVO = listVO;
	_nameLabel.text = _listVO.list_name;
}

#pragma mark - Navigation
-(void)_goToggleFollow {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"LIST_UNSUBSCRIBE" object:_listVO];
}

@end
