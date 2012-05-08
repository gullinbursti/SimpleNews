//
//  SNProfileArticleViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.07.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNProfileArticleViewCell_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNProfileArticleViewCell_iPhone

@synthesize articleVO = _articleVO;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)init {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 15.0, 256.0, 20.0)];
		_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
		_titleLabel.textColor = [UIColor blackColor];
		_titleLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_titleLabel];
		
		_sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 30.0, 256.0, 20.0)];
		_sourceLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		_sourceLabel.textColor = [SNAppDelegate snLinkColor];
		_sourceLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_sourceLabel];
		
		UIImageView *chevronView = [[UIImageView alloc] initWithFrame:CGRectMake(285.0, 23.0, 24, 24)];		
		chevronView.image = [UIImage imageNamed:@"chevron_nonActive.png"];
		[self addSubview:chevronView];
		
		UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 70.0, self.frame.size.width - 30.0, 2.0)];
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
- (void)setArticleVO:(SNArticleVO *)articleVO {
	_articleVO = articleVO;
	_titleLabel.text = _articleVO.title;
	_sourceLabel.text = _articleVO.articleSource;
}

@end
