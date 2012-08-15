//
//  SNComposerViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.14.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNArticleVO.h"
#import "EGOImageView.h"

@interface SNComposerViewController_iPhone : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, EGOImageViewDelegate> {
	SNArticleVO *_vo;
	
	NSDictionary *_fbHomeFeed;
	
	UIButton *_quoteButton;
	UIButton *_stickerButton;
	
	UIButton *_cameraButton;
	UIButton *_cameraRollButton;
	UIButton *_fbFriendsButton;
	
	BOOL _isQuoteType;
	BOOL _isCameraPic;
}

- (id)initWithArticleVO:(SNArticleVO *)vo;


@end
