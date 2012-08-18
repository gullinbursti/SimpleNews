//
//  SNComposeEditorView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGOImageView.h"
#import "ASIFormDataRequest.h"

@interface SNComposeEditorView_iPhone : UIView <UITextViewDelegate, EGOImageViewDelegate, ASIHTTPRequestDelegate> {
	NSDictionary *_fbFriend;
	
	UIButton *_cycleButton;
	int _cnt;
	BOOL _isQuote;
	
	NSMutableArray *_quoteList;
	NSMutableArray *_stickerList;
	
	UITextView *_quoteTxtView;
	
	UIView *_canvasView;
	
	UIButton *_quoteToggleButton;
	UIButton *_stickerToggleButton;
}

- (id)initWithFrame:(CGRect)frame withFriend:(NSDictionary *)fbFriend;

@end
