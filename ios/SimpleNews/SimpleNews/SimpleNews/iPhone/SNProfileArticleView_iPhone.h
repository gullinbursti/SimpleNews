//
//  SNProfileArticleView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.26.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNArticleVO.h"

@interface SNProfileArticleView_iPhone : UIView {
	SNArticleVO *_vo;
}

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo;

@end
