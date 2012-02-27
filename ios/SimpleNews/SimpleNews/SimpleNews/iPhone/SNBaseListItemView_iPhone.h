//
//  SNBaseListItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.27.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNBaseListItemView_iPhone : UIView {
	UILabel *_titleLabel;
	UIImageView *_checkImageView;
	
	BOOL _isSelected;
}

-(void)toggleSelected:(BOOL)isSelected;
-(void)deselect;
@end
