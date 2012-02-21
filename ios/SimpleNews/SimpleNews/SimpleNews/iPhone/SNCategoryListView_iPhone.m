//
//  SNCategoryListView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.21.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNCategoryListView_iPhone.h"

@implementation SNCategoryListView_iPhone

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self setBackgroundColor:[UIColor grayColor]];		
	}
	
	return (self);
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	if ([touch view] == self) {
		NSLog(@"ENDED");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CATEGORY_SELECTED" object:nil];
		return;
	}		
}

@end
