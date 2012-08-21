//
//  SNFacebookThumbView.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "MBLAsyncResource.h"

#import <UIKit/UIKit.h>

@interface SNFacebookThumbView : UIView {
	UIImageView *_imgView;
}

@property (nonatomic, retain) NSDictionary *fbUser;
@property (nonatomic, retain) UIButton *btn;
@property (nonatomic, retain) NSString *handle;


- (id)initWithPosition:(CGPoint)pos fbUser:(NSDictionary *)user;

@end
