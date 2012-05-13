//
//  SNProfileHeaderViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.12.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "EGOImageView.h"
#import "SNProfileHeaderViewCell_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNProfileHeaderViewCell_iPhone

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)init {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		EGOImageView *avatarImg = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0, 20.0, 25.0, 25.0)];
		avatarImg.imageURL = [NSURL URLWithString:[SNAppDelegate twitterAvatar]];
		[self addSubview:avatarImg];
		
		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		avatarButton.frame = avatarImg.frame;
		[avatarButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:avatarButton];
		
		UILabel *handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 24.0, 200.0, 16.0)];
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
		profileButton.frame = CGRectMake(272.0, 16.0, 34.0, 34.0);
		[profileButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive.png"] forState:UIControlStateNormal];
		[profileButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active.png"] forState:UIControlStateHighlighted];
		[profileButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:profileButton];
	}
	
    return (self);
}


#pragma mark - Navigation
-(void)_goTwitterProfile {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TWITTER_PROFILE" object:nil];
}

@end
