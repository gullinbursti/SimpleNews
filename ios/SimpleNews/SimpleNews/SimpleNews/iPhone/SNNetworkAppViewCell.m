//
//  SNNetworkAppViewCell.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNNetworkAppViewCell.h"
#import "SNAppDelegate.h"

#import "MBLResourceLoader.h"

@interface SNNetworkAppViewCell () <MBLResourceObserverProtocol>
@property(nonatomic, strong) MBLAsyncResource *imageResource;
@end

@implementation SNNetworkAppViewCell

@synthesize networkAppVO = _networkAppVO;
@synthesize imageResource = _imageResource;

-(id)init {
	if ((self = [super init])) {
		_imgView = [[UIImageView alloc] initWithFrame:CGRectMake(4.0, 4.0, 26.0, 26.0)];
		[_imgView setBackgroundColor:[UIColor colorWithWhite:0.961 alpha:1.0]];
		[self addSubview:_imgView];
		
		_nameLabel.frame = CGRectOffset(_nameLabel.frame, 34.0, 0.0);
	}
	
	return (self);
}

#pragma mark - Accessors
- (void)setNetworkAppVO:(SNNetworkAppVO *)networkAppVO {
	NSLog(@"APP :[%@]", networkAppVO.title);
	_networkAppVO = networkAppVO;
	_nameLabel.text = _networkAppVO.title;
	
	self.imageResource = [[MBLResourceLoader sharedInstance] downloadURL:networkAppVO.icoURL forceFetch:NO expiration:[NSDate dateWithTimeIntervalSinceNow:60.0 * 60.0 * 24.0]]; // 1 day expiration
}

- (void)setImageResource:(MBLAsyncResource *)imageResource {
	if (_imageResource != nil) {
		[_imageResource unsubscribe:self];
		_imageResource = nil;
	}
	
	_imageResource = imageResource;
	
	if (_imageResource != nil)
		[_imageResource subscribe:self];
}


#pragma mark - AsyncResource Observers
- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data {
	//NSLog(@"MBLAsyncResource.data [%@]", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	_imgView.image = [UIImage imageWithData:data];
}

- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error {
	_imageResource = nil;
}


@end
