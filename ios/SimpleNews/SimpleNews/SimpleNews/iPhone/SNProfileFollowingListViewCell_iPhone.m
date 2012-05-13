//
//  SNProfileFollowingListViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.12.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNProfileFollowingListViewCell_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNProfileFollowingListViewCell_iPhone

@synthesize listVO = _listVO;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)init {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 26.0, 256.0, 18.0)];
		_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		_titleLabel.textColor = [UIColor blackColor];
		_titleLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_titleLabel];
		
		UIImageView *chevronView = [[UIImageView alloc] initWithFrame:CGRectMake(284.0, 18.0, 24, 24)];		
		chevronView.image = [UIImage imageNamed:@"chevron_nonActive.png"];
		[self addSubview:chevronView];
		
		UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 70.0, self.frame.size.width - 40.0, 2.0)];
		UIImage *img = [UIImage imageNamed:@"line.png"];
		lineImgView.image = [img stretchableImageWithLeftCapWidth:2.0 topCapHeight:0.0];
		[self addSubview:lineImgView];
	}
	
	return (self);
}

#pragma mark - Accessors
- (void)setListVO:(SNListVO *)listVO {
	_listVO = listVO;
	_titleLabel.text = _listVO.list_name;
}

@end
