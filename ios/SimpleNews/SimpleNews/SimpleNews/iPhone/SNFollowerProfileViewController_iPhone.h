//
//  SNFollowerProfileViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.25.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNFollowerVO.h"
#import "ASIFormDataRequest.h"

@interface SNFollowerProfileViewController_iPhone : UIViewController <ASIHTTPRequestDelegate, UIScrollViewDelegate> {
	SNFollowerVO *_vo;
	ASIFormDataRequest *_articlesRequest;
	
	NSMutableArray *_articles;
	NSMutableArray *_articleViews;
	UIScrollView *_scrollView;
	
	CGSize _infoSize;
}

-(id)initWithFollowerVO:(SNFollowerVO *)vo;
@end
