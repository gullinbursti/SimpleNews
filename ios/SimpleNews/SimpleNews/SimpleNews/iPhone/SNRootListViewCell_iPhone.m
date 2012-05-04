//
//  SNRootListViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SNRootListViewCell_iPhone.h"
#import "SNAppDelegate.h"


@implementation SNRootListViewCell_iPhone

@synthesize listVO = _listVO;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)init {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 20.0, 256.0, 20.0)];
		_nameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		_nameLabel.textColor = [UIColor blackColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_nameLabel];
		
		_followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_followButton.frame = CGRectMake(200.0, 10.0, 44.0, 44.0);
		[_followButton setBackgroundImage:[UIImage imageNamed:@"followIcon_nonActive.png"] forState:UIControlStateNormal];
		[_followButton setBackgroundImage:[UIImage imageNamed:@"followIcon_Active.png"] forState:UIControlStateHighlighted];
		[_followButton addTarget:self action:@selector(_goToggleFollow) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_followButton];
		
		UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 50.0, self.frame.size.width - 30.0, 2.0)];
		UIImage *img = [UIImage imageNamed:@"line.png"];
		lineImgView.image = [img stretchableImageWithLeftCapWidth:1.0 topCapHeight:2.0];
		[self addSubview:lineImgView];
	}
	
	return (self);
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}


#pragma mark - Accessors
- (void)setListVO:(SNListVO *)listVO {
	_listVO = listVO;
	
	_nameLabel.text = _listVO.list_name;
	
	if (_listVO.isSubscribed)
		[_followButton setBackgroundImage:[UIImage imageNamed:@"followIcon_Selected.png"] forState:UIControlStateNormal];
}


#pragma mark - Navigation
-(void)_goToggleFollow {
	
}

@end
