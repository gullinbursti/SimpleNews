//
//  SNTwitterFriendViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.22.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNTwitterFriendViewCell_iPhone.h"
#import "SNAppDelegate.h"
#import "SNTwitterAvatarView.h"

@implementation SNTwitterFriendViewCell_iPhone

@synthesize twitterUserVO = _twitterUserVO;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)initAsHeader {
	if ((self = [self init])) {
		UIImage *img = [UIImage imageNamed:@"topBackground.png"];
		_bgImgView.image = [img stretchableImageWithLeftCapWidth:0.0 topCapHeight:7.0];
	}
	
	return (self);
}

- (id)initAsMiddle {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"midBackground.png"];
	}
	
	return (self);
}

- (id)initAsFooter {
	if ((self = [self init])) {
		UIImage *img = [UIImage imageNamed:@"botBackground.png"];
		_bgImgView.image = [img stretchableImageWithLeftCapWidth:0.0 topCapHeight:7.0];		
		[_lineView removeFromSuperview];
	}
	
	return (self);
}



-(id)init {
	//if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
	if ((self = [super init])) { //WithStyle:UITableViewCellStyleDefault reuseIdentifier:nil])) {
		_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width - 20.0, 56.0)];
		[self addSubview:_bgImgView];
		
		_handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 23.0, 200.0, 16.0)];
		_handleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		_handleLabel.textColor = [SNAppDelegate snLinkColor];
		_handleLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_handleLabel];
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 32.0, 200.0, 16.0)];
		_nameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		_nameLabel.textColor = [SNAppDelegate snLinkColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		
		
		_inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_inviteButton.frame = CGRectMake(220.0, 6.0, 54.0, 44.0);
		[_inviteButton setBackgroundImage:[[UIImage imageNamed:@"genericButtonB_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[_inviteButton setBackgroundImage:[[UIImage imageNamed:@"genericButtonB_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:0.0] forState:UIControlStateHighlighted];		
		[_inviteButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		[_inviteButton addTarget:self action:@selector(_goInvite) forControlEvents:UIControlEventTouchUpInside];
		_inviteButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10.0];
		[_inviteButton setTitle:@"Invite" forState:UIControlStateNormal];
		[self addSubview:_inviteButton];

		
		_lineView = [[UIView alloc] initWithFrame:CGRectMake(12.0, 56.0, self.frame.size.width - 43.0, 1.0)];
		[_lineView setBackgroundColor:[SNAppDelegate snLineColor]];
		//[self addSubview:_lineView];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goInvite {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"INVITE_FOLLOWER" object:_twitterUserVO];
}


#pragma mark - Accessors
- (void)setTwitterUserVO:(SNTwitterUserVO *)twitterUserVO {
	_twitterUserVO = twitterUserVO;
	
	SNTwitterAvatarView *avatarImgView = [[SNTwitterAvatarView alloc] initWithPosition:CGPointMake(25.0, 18.0) imageURL:twitterUserVO.avatarURL];
	[self addSubview:avatarImgView];
	
	_handleLabel.text = [NSString stringWithFormat:@"@%@", _twitterUserVO.handle];
}

@end
