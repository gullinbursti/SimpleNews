//
//  SNTwitterAvatarView.h
//  SimpleNews
//
//  Created by Sparkle Mountain iMac on 5/30/12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBLAsyncResource.h"

@interface SNTwitterAvatarView : UIView {
	UIImageView *_imgView;
	UIButton *_btn;
}

@property (nonatomic, retain) UIButton *btn;

- (id)initWithPosition:(CGPoint)pos imageURL:(NSString *)url;

@end
