//
//  SNPaginationView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.19.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNPaginationView_iPhone : UIView {
	UIImageView *_onImgView;
	int _currentPage;
}

-(void)changePage:(int)page;

@end
