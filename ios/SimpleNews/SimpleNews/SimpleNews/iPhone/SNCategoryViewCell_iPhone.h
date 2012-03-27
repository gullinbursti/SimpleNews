//
//  SNCategoryViewCell_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.26.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNCategoryViewCell_iPhone : UITableViewCell {
	UIScrollView *_scrollView;
	NSMutableArray *_followers;
}

+(NSString *)cellReuseIdentifier;
@property(nonatomic, retain) NSMutableArray *followers;

@end
