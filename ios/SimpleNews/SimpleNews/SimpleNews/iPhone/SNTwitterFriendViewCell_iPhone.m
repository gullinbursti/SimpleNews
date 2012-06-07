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
@synthesize overlayView = _overlayView;
@synthesize isFinderCell = _isFinderCell;

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
		_bgImgView.image = [UIImage imageNamed:@"botBackground.png"];		
		[_lineView removeFromSuperview];
	}
	
	return (self);
}


- (id)initAsSolo {
	if ((self = [self init])) {
		_bgImgView.frame = CGRectMake(12.0, 0.0, 284, 69.0);
		_bgImgView.image = [UIImage imageNamed:@"soloBackground.png"];
		
		_handleLabel.frame = CGRectMake(59.0, 27.0, 200.0, 16.0);
		_overlayView.frame = CGRectMake(5.0, 4.0, self.frame.size.width - 31.0, 58.0);
		[_lineView removeFromSuperview];
	}
	
	return (self);
}



-(id)init {
	//if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
	if ((self = [super init])) { //WithStyle:UITableViewCellStyleDefault reuseIdentifier:nil])) {
		_isSoloCell = NO;
		
		_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width - 20.0, 56.0)];
		[self addSubview:_bgImgView];
		
		_handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 21.0, 200.0, 16.0)];
		_handleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		_handleLabel.textColor = [SNAppDelegate snLinkColor];
		_handleLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_handleLabel];
		
		_overlayView = [[UIView alloc] initWithFrame:CGRectMake(12.0, 0.0, self.frame.size.width - 43.0, 56.0)];
		[_overlayView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.33]];
		_overlayView.alpha = 0.0;
		[self addSubview:_overlayView];
		
		//_lineView = [[UIView alloc] initWithFrame:CGRectMake(12.0, 57.0, self.frame.size.width - 43.0, 1.0)];
		//[_lineView setBackgroundColor:[SNAppDelegate snLineColor]];
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
	
	SNTwitterAvatarView *avatarImgView = [[SNTwitterAvatarView alloc] initWithPosition:CGPointMake(25.0, 15.0) imageURL:twitterUserVO.avatarURL];
	[self addSubview:avatarImgView];
	
	if (_isSoloCell) {
		CGRect frame = avatarImgView.frame;
		frame.origin.y += 4.0;
		avatarImgView.frame = frame;
		
		_handleLabel.frame = CGRectMake(59.0, 24.0, 200.0, 16.0);
	}
	
	_handleLabel.text = [NSString stringWithFormat:@"@%@", _twitterUserVO.handle];
}

- (void)setIsFinderCell:(BOOL)isFinderCell {
	_isFinderCell = isFinderCell;
	_isSoloCell = YES;
	
	if (_isFinderCell) {
		_inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_inviteButton.frame = CGRectMake(215.0, 7.0, 63.0, 44.0);
		[_inviteButton setBackgroundImage:[[UIImage imageNamed:@"genericButtonB_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[_inviteButton setBackgroundImage:[[UIImage imageNamed:@"genericButtonB_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:0.0] forState:UIControlStateHighlighted];		
		[_inviteButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		[_inviteButton addTarget:self action:@selector(_goInvite) forControlEvents:UIControlEventTouchUpInside];
		_inviteButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:11.0];
		[_inviteButton setTitle:@"Invite" forState:UIControlStateNormal];
		[self addSubview:_inviteButton];
		
	} else {
		UIImageView *chevronView = [[UIImageView alloc] initWithFrame:CGRectMake(250.0, 17.0, 24.0, 24.0)];
		chevronView.image = [UIImage imageNamed:@"chevron.png"];
		[self addSubview:chevronView];
		
		if (_isSoloCell)
			chevronView.frame = CGRectMake(250.0, 21.0, 24.0, 24.0);
	}
}

@end
