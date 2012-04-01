//
//  SNArticleInfluencerInfoView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.23.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNArticleVO.h"

@interface SNArticleInfluencerInfoView_iPhone : UIView {
	SNArticleVO *_vo;
}

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo;
@end
