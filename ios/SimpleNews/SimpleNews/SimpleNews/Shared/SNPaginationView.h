//
//  SNPaginationView.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.06.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNPaginationView : UIView {
	int _currPage;
	int _totPages;
	
	UIButton *_bgButton;
	UIImageView *_offImgView;
	UIImageView *_onImgView;
}

-(id)initWithTotal:(int)total coords:(CGPoint)pos;
-(void)updToPage:(int)page;

@end
