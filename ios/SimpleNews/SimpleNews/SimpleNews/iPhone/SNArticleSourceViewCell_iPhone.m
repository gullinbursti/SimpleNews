//
//  SNArticleSourceViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleSourceViewCell_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNArticleSourceViewCell_iPhone

@synthesize sourceVO = _sourceVO;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)init {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		_iconImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0, 22.0, 25.0, 25.0)];
		_iconImgView.backgroundColor = [UIColor greenColor];
		[self addSubview:_iconImgView];
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 27.0, 256.0, 16.0)];
		_nameLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:11];
		_nameLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.0];
		_nameLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_nameLabel];
		
		UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 73.0, self.frame.size.width - 40.0, 2.0)];
		UIImage *img = [UIImage imageNamed:@"line.png"];
		lineImgView.image = [img stretchableImageWithLeftCapWidth:2.0 topCapHeight:0.0];
		[self addSubview:lineImgView];
	}
	
	return (self);
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}


#pragma mark - Accessors
- (void)setSourceVO:(SNArticleSourceVO *)sourceVO {
	_sourceVO = sourceVO;
	
	_nameLabel.text = _sourceVO.title;
}

@end
