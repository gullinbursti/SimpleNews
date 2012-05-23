//
//  SNTwitterFriendViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.22.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNTwitterFriendViewCell_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNTwitterFriendViewCell_iPhone

@synthesize twitterUserVO = _twitterUserVO;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)init {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		
		_avatarImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0, 22.0, 25.0, 25.0)];
		_avatarImgView.imageURL = [NSURL URLWithString:[SNAppDelegate twitterAvatar]];
		[self addSubview:_avatarImgView];
			
		_handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 27.0, 200.0, 16.0)];
		_handleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		_handleLabel.textColor = [SNAppDelegate snLinkColor];
		_handleLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_handleLabel];
		
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 32.0, 200.0, 16.0)];
		_nameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		_nameLabel.textColor = [SNAppDelegate snLinkColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		//[self addSubview:_nameLabel];
		
		UIImageView *chevronView = [[UIImageView alloc] initWithFrame:CGRectMake(284.0, 23.0, 24.0, 24.0)];		
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
- (void)setTwitterUserVO:(SNTwitterUserVO *)twitterUserVO {
	_twitterUserVO = twitterUserVO;
	_avatarImgView.imageURL = [NSURL URLWithString:_twitterUserVO.avatarURL];
	_handleLabel.text = [NSString stringWithFormat:@"@%@", _twitterUserVO.handle];
}

@end
