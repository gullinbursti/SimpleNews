//
//  MBLPageItemViewController.h
//  MBLAssetLoader
//
//  Created by Jesse Boley on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBLPageItemViewController : UIViewController
@property(nonatomic, strong) id item;

- (void)updateAnimationWithPercent:(float)percent appearing:(BOOL)appearing;

- (void)pageItemViewWasPlacedOffscreen;
- (void)pageItemViewDidBecomeFocusAnimated:(BOOL)animated;
@end
