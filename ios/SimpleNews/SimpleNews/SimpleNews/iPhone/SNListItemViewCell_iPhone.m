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
		_avatarImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(12.0, 9.0, 50.0, 50.0)];
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
		
		_curatorsLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 36.0, 210.0, 20.0)];
		_curatorsLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		_curatorsLabel.textColor = [UIColor colorWithWhite:0.694 alpha:1.0];
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
	_curatorsLabel.text = _listVO.curatorNames;
}
@end
