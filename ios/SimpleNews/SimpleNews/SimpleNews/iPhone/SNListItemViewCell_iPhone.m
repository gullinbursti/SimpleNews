//
//  SNListItemViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SNListItemViewCell_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNListItemViewCell_iPhone

@synthesize listVO = _listVO;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)init {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		_avatarImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(12.0, 9.0, 37.0, 37.0)];
		_avatarImgView.layer.cornerRadius = 8.0;
		_avatarImgView.clipsToBounds = YES;
		_avatarImgView.layer.borderColor = [[UIColor colorWithWhite:0.671 alpha:1.0] CGColor];
		_avatarImgView.layer.borderWidth = 1.0;
		[self addSubview:_avatarImgView];
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 16.0, 256.0, 20.0)];
		_nameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		_nameLabel.textColor = [UIColor blackColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_nameLabel];
		
		CGSize size = [@"created by " sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:14] constrainedToSize:CGSizeMake(250.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *createdLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 36.0, size.width, size.height)];
		createdLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:14];
		createdLabel.textColor = [UIColor colorWithWhite:0.639 alpha:1.0];
		createdLabel.backgroundColor = [UIColor clearColor];
		createdLabel.text = @"created by ";
		[self addSubview:createdLabel];
		
		_curatorsLabel = [[UILabel alloc] initWithFrame:CGRectMake(createdLabel.frame.origin.x + size.width, 36.0, 220.0, 20.0)];
		_curatorsLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:14];
		_curatorsLabel.textColor = [SNAppDelegate snLinkColor];
		_curatorsLabel.lineBreakMode = UILineBreakModeTailTruncation;
		_curatorsLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_curatorsLabel];
		
		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 74.0, self.frame.size.width, 1.0)];
		[lineView setBackgroundColor:[UIColor colorWithWhite:0.545 alpha:1.0]];
		//[self addSubview:lineView];
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
	_nameLabel.text = [NSString stringWithFormat:@"%@", _listVO.list_name];
	_curatorsLabel.text = _listVO.curatorHandles;
}
@end
