//
//  SNAnyListViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.07.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNAnyListViewCell_iPhone.h"

@implementation SNAnyListViewCell_iPhone

@synthesize listVO = _listVO;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)init {
	if ((self = [super init])) {		
		_followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_followButton.frame = CGRectMake(200.0, 10.0, 44.0, 44.0);
		[_followButton setBackgroundImage:[UIImage imageNamed:@"followIcon_nonActive.png"] forState:UIControlStateNormal];
		[_followButton setBackgroundImage:[UIImage imageNamed:@"followIcon_Active.png"] forState:UIControlStateHighlighted];
		[_followButton addTarget:self action:@selector(_goToggleFollow) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_followButton];
	}
	
	return (self);
}

#pragma mark - Accessors
- (void)setListVO:(SNListVO *)listVO {
	_listVO = listVO;
	_nameLabel.text = _listVO.list_name;
	
	if (listVO.isSubscribed)
		[_followButton setBackgroundImage:[UIImage imageNamed:@"followIcon_Selected.png"] forState:UIControlStateNormal];
}

#pragma mark - Navigation
-(void)_goToggleFollow {
	
	_listVO.isSubscribed = !_listVO.isSubscribed;
	
	if (_listVO.isSubscribed) {
		[_followButton setBackgroundImage:[UIImage imageNamed:@"followIcon_Selected.png"] forState:UIControlStateNormal];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"LIST_SUBSCRIBE" object:_listVO];
	
	} else {
		[_followButton setBackgroundImage:[UIImage imageNamed:@"followIcon_nonActive.png"] forState:UIControlStateNormal];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"LIST_UNSUBSCRIBE" object:_listVO];
	}
}

@end
