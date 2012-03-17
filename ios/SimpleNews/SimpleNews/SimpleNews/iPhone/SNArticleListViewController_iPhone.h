//
//  SNArticleListViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "ASIFormDataRequest.h"
#import "SNShareSheetView.h"

@interface SNArticleListViewController_iPhone : UIViewController <UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, ASIHTTPRequestDelegate> {
	NSMutableArray *_articles;
	ASIFormDataRequest *_articlesRequest;
	
	UIView *_overlayView;
	UIView *_cardHolderView;
	
	NSMutableArray *_cardViews;
	NSMutableArray *_scaledImages;
	
	int _cardIndex;
	BOOL _isSwiping;
	
	SNShareSheetView *_shareSheetView;
}

-(id)initAsMostRecent;
-(id)initWithFollower:(int)follower_id;
-(id)initWithFollowers;
-(id)initWithTag:(int)tag_id;
-(id)initWithTags:(NSString *)tags;

@end
