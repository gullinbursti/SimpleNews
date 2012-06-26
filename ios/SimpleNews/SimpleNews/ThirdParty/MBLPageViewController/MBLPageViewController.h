//
//  MBLPageViewController.h
//  MBLAssetLoader
//
//  Created by Jesse Boley on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBLPageItemViewController.h"

@class MBLPageViewController;

@protocol MBLPageViewControllerDelegate <NSObject>
- (MBLPageItemViewController *)makeItemViewControllerForPageViewController:(MBLPageViewController *)pageViewController;
- (void)pageViewController:(MBLPageViewController *)pageViewController selectionDidChangeToIndex:(NSUInteger)index;
@end

@interface MBLPageViewController : UIViewController <UISplitViewControllerDelegate>
@property(nonatomic, assign) NSObject<MBLPageViewControllerDelegate> *delegate;
@property(nonatomic, strong) IBOutlet UIScrollView *scrollView;

- (void)configureWithSelectedIndex:(NSUInteger)index fromItems:(NSArray *)allItems;
@property(nonatomic, readonly) NSUInteger selectedIndex;
@end
