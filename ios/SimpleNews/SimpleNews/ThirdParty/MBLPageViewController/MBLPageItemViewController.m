//
//  MBLPageItemViewController.m
//  MBLAssetLoader
//
//  Created by Jesse Boley on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBLPageItemViewController.h"

@implementation MBLPageItemViewController

@synthesize item = _item;

- (void)updateAnimationWithPercent:(float)percent appearing:(BOOL)appearing
{
	// Subclasses should override
}

- (void)pageItemViewWasPlacedOffscreen
{
	// Subclasses should override
}

- (void)pageItemViewDidBecomeFocusAnimated:(BOOL)animated
{
	// Subclasses should override
}

@end
