//
//  SNAirplayListView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.26.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNAirplayListView_iPhone.h"

#import "SNDeviceItemView_iPhone.h"
#import "SNDeviceVO.h"

@implementation SNAirplayListView_iPhone


-(id)initWithFrame:(CGRect)frame {	
	if ((self = [super initWithFrame:frame])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_deviceSelected:) name:@"DEVICE_SELECTED" object:nil];
		
		_deviceViews = [[NSMutableArray alloc] init];
		
		NSString *testDevicesPath = [[NSBundle mainBundle] pathForResource:@"devices" ofType:@"plist"];
		NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:testDevicesPath] options:NSPropertyListImmutable format:nil error:nil];
		
		int cnt = 0;
		for (NSDictionary *testCategory in plist) {
			SNDeviceVO *vo = [[SNDeviceVO deviceWithDictionary:testCategory] autorelease];
			SNDeviceItemView_iPhone *itemView = [[[SNDeviceItemView_iPhone alloc] initWithFrame:CGRectMake(0.0, cnt * 64, frame.size.width, 64) withVO:vo] autorelease];
			
			[_deviceViews addObject:itemView];
			[self addSubview:itemView];
			cnt++;
		}
	}
	
	return (self);
}

#pragma mark - Navigation
-(void)_goBack {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AIRPLAY_BACK" object:nil];
}


#pragma mark - Notification handlers
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


@end
