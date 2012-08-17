//
//  SNComposeEditorView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGOImageView.h"

@interface SNComposeEditorView_iPhone : UIView <UITextViewDelegate, EGOImageViewDelegate> {
	NSDictionary *_fbFriend;
	
	UIButton *_cycleButton;
	int _type;
	int _cnt;
	
	NSMutableArray *_quoteList;
	NSMutableArray *_stickerList;
	
	UILabel *_quoteLabel;
	UITextView *_quoteTxtView;
	
	UIView *_canvasView;
}

- (id)initWithFrame:(CGRect)frame withFriend:(NSDictionary *)fbFriend withType:(int)type;

@end
