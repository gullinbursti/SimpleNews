//
//  SNArticleCommentViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.15.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "SNArticleCommentViewCell_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNArticleCommentViewCell_iPhone

@synthesize reactionVO = _reactionVO;


+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)init {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		_avatarImgView = [[[EGOImageView alloc] initWithFrame:CGRectMake(12.0, 12.0, 40.0, 40.0)] autorelease];
		_avatarImgView.layer.cornerRadius = 8.0;
		_avatarImgView.clipsToBounds = YES;
		_avatarImgView.layer.borderColor = [[UIColor colorWithWhite:0.671 alpha:1.0] CGColor];
		_avatarImgView.layer.borderWidth = 1.0;
		[self addSubview:_avatarImgView];
		
		_twitterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(62.0, 10.0, 256.0, 20.0)];
		_twitterNameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		_twitterNameLabel.textColor = [UIColor blackColor];
		_twitterNameLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_twitterNameLabel];
		
		_twitterBlurbLabel = [[UILabel alloc] initWithFrame:CGRectMake(62.0, 30.0, 256.0, 20.0)];
		_twitterBlurbLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		_twitterBlurbLabel.textColor = [UIColor colorWithWhite:0.482 alpha:1.0];
		_twitterBlurbLabel.numberOfLines = 0;
		_twitterBlurbLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_twitterBlurbLabel];
		
		UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 98.0, self.frame.size.width, 1.0)] autorelease];
		[lineView setBackgroundColor:[UIColor colorWithWhite:0.545 alpha:1.0]];
		[self addSubview:lineView];
	}
	
	return (self);
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}


#pragma mark - Accessors
- (void)setReactionVO:(SNReactionVO *)reactionVO {
	_reactionVO = reactionVO;
	
	_avatarImgView.imageURL = [NSURL URLWithString:_reactionVO.thumb_url];
	_twitterNameLabel.text = _reactionVO.twitterName;
	_twitterBlurbLabel.text = _reactionVO.content;
}
@end
