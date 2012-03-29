//
//  SNArticleReactionItemView.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.28.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNReactionVO.h"

@interface SNArticleReactionItemView : UIView {
	SNReactionVO *_vo;
}

-(id)initWithFrame:(CGRect)frame reactionVO:(SNReactionVO *)vo;

@end
