//
//  SNRootOtherViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNRootOtherViewCell_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNRootOtherViewCell_iPhone

-(id)initWithTitle:(NSString *)title {
	if ((self = [super init])) {
		_nameLabel.text = title;
	}
	
	return (self);
}

@end
