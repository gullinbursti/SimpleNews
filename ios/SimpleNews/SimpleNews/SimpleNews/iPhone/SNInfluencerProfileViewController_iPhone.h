//
//  SNInfluencerProfileViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.25.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNInfluencerVO.h"
#import "ASIFormDataRequest.h"

@interface SNInfluencerProfileViewController_iPhone : UIViewController <ASIHTTPRequestDelegate, UIScrollViewDelegate> {
	SNInfluencerVO *_vo;
	ASIFormDataRequest *_articlesRequest;
	
	NSMutableArray *_articles;
	NSMutableArray *_articleViews;
	UIScrollView *_scrollView;
	
	CGSize _infoSize;
}

-(id)initWithInfluencerVO:(SNInfluencerVO *)vo;
@end
