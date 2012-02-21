//
//  SNVideoItemViewController.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNVideoItemVO.h"
#import "EGOImageView.h"

@interface SNVideoItemViewController : UIViewController {
	
	EGOImageView *_imageView;
	UILabel *_titleLabel;
	UILabel *_infoLabel;
	
	SNVideoItemVO *_vo;
}

-(id)initWithVO:(SNVideoItemVO *)vo;

@end
