//
//  SNRootTopicViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.07.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNRootTopicViewCell_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNRootTopicViewCell_iPhone

@synthesize topicVO = _topicVO;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)init {
	if ((self = [super init])) {
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10.0, 256.0, 28.0)];
		_nameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		_nameLabel.textColor = [UIColor blackColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_nameLabel];
		
		_followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_followButton.frame = CGRectMake(200.0, 4.0, 44.0, 44.0);
		[_followButton setBackgroundImage:[UIImage imageNamed:@"followIcon_Selected.png"] forState:UIControlStateNormal];
		[_followButton setBackgroundImage:[UIImage imageNamed:@"followIcon_Active.png"] forState:UIControlStateHighlighted];
		[_followButton addTarget:self action:@selector(_goUnfollow) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_followButton];
		
		UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 50.0, self.frame.size.width - 30.0, 2.0)];
		UIImage *img = [UIImage imageNamed:@"line.png"];
		lineImgView.image = [img stretchableImageWithLeftCapWidth:2.0 topCapHeight:0.0];
		[self addSubview:lineImgView];
	}
	
	return (self);
}

#pragma mark - Accessors
- (void)setTopicVO:(SNTopicVO *)topicVO {
	NSLog(@"TOPIC :[%@]", topicVO.title);
	_topicVO = topicVO;
	_nameLabel.text = _topicVO.title;
}

#pragma mark - Navigation
-(void)_goUnfollow {
	[_followButton setBackgroundImage:[UIImage imageNamed:@"followIcon_nonActive.png"] forState:UIControlStateNormal];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"LIST_UNSUBSCRIBE" object:_topicVO];
}

@end
