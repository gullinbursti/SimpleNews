//
//  SNShareSheetView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNArticleVO.h"
#import "ASIFormDataRequest.h"

@interface SNShareSheetView_iPhone : UIView <ASIHTTPRequestDelegate> {
	SNArticleVO *_vo;
}

@property (nonatomic, retain) SNArticleVO *vo;

@end
