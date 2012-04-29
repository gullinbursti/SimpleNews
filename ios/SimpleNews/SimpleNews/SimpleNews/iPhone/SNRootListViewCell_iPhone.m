//
//  SNRootListViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SNRootListViewCell_iPhone.h"
#import "SNAppDelegate.h"


@implementation SNRootListViewCell_iPhone

@synthesize listVO = _listVO;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)init {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		_avatarImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(15.0, 20.0, 37.0, 37.0)];
		_avatarImgView.layer.cornerRadius = 4.0;
		_avatarImgView.clipsToBounds = YES;
		_avatarImgView.layer.borderColor = [[UIColor colorWithWhite:0.671 alpha:1.0] CGColor];
		_avatarImgView.layer.borderWidth = 1.0;
		[self addSubview:_avatarImgView];
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(62.0, 20.0, 256.0, 20.0)];
		_nameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		_nameLabel.textColor = [UIColor blackColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_nameLabel];
		
		CGSize size = [@"created by " sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12] constrainedToSize:CGSizeMake(250.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *createdLabel = [[UILabel alloc] initWithFrame:CGRectMake(62.0, 40.0, size.width, size.height)];
		createdLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12];
		createdLabel.textColor = [UIColor colorWithWhite:0.639 alpha:1.0];
		createdLabel.backgroundColor = [UIColor clearColor];
		createdLabel.text = @"created by ";
		[self addSubview:createdLabel];
		
		_curatorsLabel = [[UILabel alloc] initWithFrame:CGRectMake(createdLabel.frame.origin.x + size.width, 40.0, 135.0, size.height)];
		_curatorsLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		_curatorsLabel.textColor = [SNAppDelegate snLinkColor];
		_curatorsLabel.lineBreakMode = UILineBreakModeTailTruncation;
		_curatorsLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_curatorsLabel];
		
		UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 80.0, self.frame.size.width - 30.0, 1.0)];
		lineImgView.image = [UIImage imageNamed:@"dividerLine.png"];
		[self addSubview:lineImgView];
	}
	
	return (self);
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}


#pragma mark - Accessors
- (void)setListVO:(SNListVO *)listVO {
	_listVO = listVO;
	
	_avatarImgView.imageURL = [NSURL URLWithString:_listVO.thumbURL];
	_nameLabel.text = _listVO.list_name;
	_curatorsLabel.text = _listVO.curatorHandles;
}

@end
