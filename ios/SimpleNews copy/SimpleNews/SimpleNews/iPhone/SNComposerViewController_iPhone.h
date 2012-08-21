//
//  SNComposerViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.14.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNComposeTypeView_iPhone.h"
#import "SNComposeSourceView_iPhone.h"
#import "SNComposeFriendsView_iPhone.h"
#import "SNComposeEditorView_iPhone.h"
#import "SNHeaderView_iPhone.h"
#import "SNNavBackBtnView.h"

#import "SNArticleVO.h"

@interface SNComposerViewController_iPhone : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	SNArticleVO *_vo;
	
	BOOL _isQuoteType;
	BOOL _isCameraPic;
	
	BOOL _isCameraSource;
	BOOL _isCameraRollSource;
	BOOL _isFriendsSource;
	BOOL _isArticleSource;
	BOOL _isFirstAppearance;
	
	NSArray *_fiendsList;
	
	SNHeaderView_iPhone *_headerView;
	SNNavBackBtnView *_backBtnView;
	SNComposeTypeView_iPhone *_composeTypeView;
	SNComposeSourceView_iPhone *_composeSourceView;
	SNComposeFriendsView_iPhone *_composeFriendsView;
	SNComposeEditorView_iPhone *_composeEditorView;
}

- (id)initWithTypeCamera;
- (id)initWithTypeCameraRoll;
- (id)initWithTypeFriends;

- (id)initWithArticle:(SNArticleVO *)vo;

@end
