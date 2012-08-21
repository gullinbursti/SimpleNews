//
//  SNComposerViewController.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.14.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNComposeFriendsView.h"
#import "SNComposeEditorView.h"
#import "SNHeaderView.h"
#import "SNNavBackBtnView.h"

#import "SNArticleVO.h"

@interface SNComposerViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	SNArticleVO *_vo;
	
	BOOL _isQuoteType;
	BOOL _isCameraPic;
	
	BOOL _isCameraSource;
	BOOL _isCameraRollSource;
	BOOL _isFriendsSource;
	BOOL _isArticleSource;
	BOOL _isFirstAppearance;
	
	NSArray *_fiendsList;
	
	SNHeaderView *_headerView;
	SNNavBackBtnView *_backBtnView;
	SNComposeFriendsView *_composeFriendsView;
	SNComposeEditorView *_composeEditorView;
}

- (id)initWithTypeCamera;
- (id)initWithTypeCameraRoll;
- (id)initWithTypeFriends;

- (id)initWithArticle:(SNArticleVO *)vo;

@end
