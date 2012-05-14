//
//  SNProfileViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNProfileViewCell_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNProfileViewCell_iPhone

@synthesize profileVO = _profileVO;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)initAsHeaderCell:(BOOL)isHeaderCell {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		_isHeaderCellType = isHeaderCell;
		
		if (_isHeaderCellType) {
			EGOImageView *avatarImg = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0, 37.0, 25.0, 25.0)];
			avatarImg.imageURL = [NSURL URLWithString:[SNAppDelegate twitterAvatar]];
			[self addSubview:avatarImg];
			
			UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
			avatarButton.frame = avatarImg.frame;
			[avatarButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:avatarButton];
			
			UILabel *handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 42.0, 200.0, 16.0)];
			handleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
			handleLabel.textColor = [SNAppDelegate snLinkColor];
			handleLabel.backgroundColor = [UIColor clearColor];
			handleLabel.text = [NSString stringWithFormat:@"@%@", [SNAppDelegate twitterHandle]];
			[self addSubview:handleLabel];
			
			UIButton *handleButton = [UIButton buttonWithType:UIButtonTypeCustom];
			handleButton.frame = handleLabel.frame;
			[handleButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:handleButton];
			
			UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
			profileButton.frame = CGRectMake(272.0, 33.0, 34.0, 34.0);
			[profileButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive.png"] forState:UIControlStateNormal];
			[profileButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active.png"] forState:UIControlStateHighlighted];
			[profileButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:profileButton];
			
		} else {
			_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 26.0, 256.0, 18.0)];
			_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
			_titleLabel.textColor = [UIColor blackColor];
			_titleLabel.backgroundColor = [UIColor clearColor];
			[self addSubview:_titleLabel];
			
			UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 70.0, self.frame.size.width - 40.0, 2.0)];
			UIImage *img = [UIImage imageNamed:@"line.png"];
			lineImgView.image = [img stretchableImageWithLeftCapWidth:2.0 topCapHeight:0.0];
			[self addSubview:lineImgView];
		}
	}
	
	return (self);
}


#pragma mark - Accessors
- (void)setProfileVO:(SNProfileVO *)profileVO {
	if (!_isHeaderCellType) {
		_profileVO = profileVO;
		_titleLabel.text = _profileVO.title;
	}
}


#pragma mark - Navigation
-(void)_goTwitterProfile {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TWITTER_PROFILE" object:nil];
}

//-(void)drawRect:(CGRect)rect {
//	CGContextRef ctx = UIGraphicsGetCurrentContext();
//	CGContextSetRGBStrokeColor(ctx, 0.545, 0.545, 0.545, 1.0);
//	CGContextMoveToPoint(ctx, 0.0, 73.0);
//	CGContextAddLineToPoint(ctx, 73.0, self.frame.size.width);
//	CGContextStrokePath(ctx);
//}

@end
