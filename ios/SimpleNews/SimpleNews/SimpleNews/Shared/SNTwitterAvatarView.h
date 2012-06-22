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
	NSString *_handle;
}

@property (nonatomic, retain) UIButton *btn;
@property (nonatomic, retain) NSString *handle;

- (id)initWithPosition:(CGPoint)pos imageURL:(NSString *)url handle:(NSString *)name;

@end
