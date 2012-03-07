//
//  SNOptionsListView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.26.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNOptionsListView_iPhone.h"

#import "SNOptionItemView_iPhone.h"
#import "SNOptionVO.h"

@implementation SNOptionsListView_iPhone


-(id)initWithFrame:(CGRect)frame {	
	if ((self = [super initWithFrame:frame])) {
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_deviceSelected:) name:@"DEVICE_SELECTED" object:nil];
		
		_optionViews = [[NSMutableArray alloc] init];
		_optionVOs = [[NSMutableArray alloc] init];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.opaque = NO;
		_scrollView.scrollsToTop = YES;
		_scrollView.pagingEnabled = NO;
		_scrollView.delegate = self;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceVertical = YES;
		_scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0f, 0.0f, 0.0f);
		_scrollView.contentOffset = CGPointMake(0.0, 0.0);
		_scrollView.contentSize = frame.size;
		[self addSubview:_scrollView];
		
		NSString *testOptionsPath = [[NSBundle mainBundle] pathForResource:@"options" ofType:@"plist"];
		NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:testOptionsPath] options:NSPropertyListImmutable format:nil error:nil];
		
		int cnt = 0;
		for (NSDictionary *testOption in plist) {
			SNOptionVO *vo = [SNOptionVO optionWithDictionary:testOption];
			SNOptionItemView_iPhone *itemView = [[[SNOptionItemView_iPhone alloc] initWithFrame:CGRectMake(0.0, cnt * 64, frame.size.width, 64) withVO:vo] autorelease];
			
			[_optionViews addObject:itemView];
			[_optionVOs addObject:vo];
			[_scrollView addSubview:itemView];
			cnt++;
		}
		
		_scrollView.contentSize = CGSizeMake(frame.size.width, cnt * 64);
		
		UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_goSwipe:)];
		[panRecognizer setMinimumNumberOfTouches:1];
		[panRecognizer setMaximumNumberOfTouches:1];
		[panRecognizer setDelegate:self];
		[self addGestureRecognizer:panRecognizer];
	}
	
	return (self);
}

#pragma mark - Navigation
-(void)_goBack {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"OPTIONS_RETURN" object:nil];
}


-(void)_goSwipe:(id)sender {
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self];
	NSLog(@"SWIPE @:(%f, %d)", translatedPoint.x, abs(translatedPoint.y));
	
	
	if (translatedPoint.x < -20 && abs(translatedPoint.y) < 30) {
		[self _goBack];
	}
}


#pragma mark - Notification handlers
/*
-(void)_deviceSelected:(NSNotification *)notification {
	SNDeviceVO *vo = (SNDeviceVO *)[notification object];
	
	if (vo.type_id != 4) {
		for (SNDeviceItemView_iPhone *deviceItemView in _deviceViews) {
			if (deviceItemView.vo != vo)
				[deviceItemView deselect];
		}
	}
	
	[self performSelector:@selector(_goBack) withObject:nil afterDelay:0.25];
}
*/

@end
