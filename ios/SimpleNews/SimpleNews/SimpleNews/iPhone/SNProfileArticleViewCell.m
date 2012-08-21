//
//  SNProfileArticleViewCell.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNProfileArticleViewCell.h"
#import "SNAppDelegate.h"

@implementation SNProfileArticleViewCell

@synthesize articleVO = _articleVO;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)init {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 20.0, 256.0, 18.0)];
		_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		_titleLabel.textColor = [UIColor blackColor];
		_titleLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_titleLabel];
		
		_sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 31.0, 256.0, 14.0)];
		_sourceLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		_sourceLabel.textColor = [SNAppDelegate snLinkColor];
		_sourceLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_sourceLabel];
		
		UIImageView *chevronView = [[UIImageView alloc] initWithFrame:CGRectMake(284.0, 18.0, 24.0, 24.0)];
		chevronView.image = [UIImage imageNamed:@"chevron.png"];
		[self addSubview:chevronView];
		
		UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 64.0, self.frame.size.width - 40.0, 2.0)];
		UIImage *img = [UIImage imageNamed:@"line.png"];
		lineImgView.image = [img stretchableImageWithLeftCapWidth:2.0 topCapHeight:0.0];
		[self addSubview:lineImgView];
	}
	
	return (self);
}


#pragma mark - Accessors
- (void)setArticleVO:(SNArticleVO *)articleVO {
	_articleVO = articleVO;
	_titleLabel.text = _articleVO.title;
	_sourceLabel.text = _articleVO.topicTitle;
}

@end
