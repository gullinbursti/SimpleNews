//
//  SNArticleListViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"

@interface SNArticleListViewController_iPhone : UIViewController <UIGestureRecognizerDelegate, ASIHTTPRequestDelegate> {
	NSMutableArray *_articles;
	ASIFormDataRequest *_articlesRequest;
	
	UIView *_overlayView;
	UIView *_cardHolderView;
	UIButton *_gridButton;
	
	NSMutableArray *_cardViews;
	NSMutableArray *_scaledImages;
	
	int _cardIndex;
	BOOL _isSwiping;
}

-(id)initAsMostRecent;
-(id)initWithFollower:(int)follower_id;
-(id)initWithFollowers;
-(id)initWithTag:(int)tag_id;
-(id)initWithTags:(NSString *)tags;

@end
