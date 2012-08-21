//
//  SNFacebookThumbView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNFacebookThumbView.h"
#import "MBLResourceLoader.h"

@interface SNFacebookThumbView () <MBLResourceObserverProtocol>
@property(nonatomic, strong) MBLAsyncResource *imageResource;
@end

@implementation SNFacebookThumbView

@synthesize imageResource = _imageResource;
@synthesize btn = _btn;
@synthesize handle = _handle;
@synthesize fbUser = _fbUser;

- (id)initWithPosition:(CGPoint)pos fbUser:(NSDictionary *)user {
	if ((self = [super initWithFrame:CGRectMake(pos.x, pos.y, 60.0, 60.0)])) {
		_fbUser = user;
		
		_imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 60.0, 60.0)];
		[_imgView setBackgroundColor:[UIColor colorWithWhite:0.961 alpha:1.0]];
		[self addSubview:_imgView];
		
		_handle = [user objectForKey:@"name"];
		_btn = [UIButton buttonWithType:UIButtonTypeCustom];
		_btn.frame = CGRectMake(0.0, 0.0, 60.0, 60.0);
		[_btn addTarget:self action:@selector(_goPress) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_btn];
		
		self.imageResource = [[MBLResourceLoader sharedInstance] downloadURL:[user objectForKey:@"sq_image"] forceFetch:NO expiration:[NSDate dateWithTimeIntervalSinceNow:60.0 * 60.0 * 24.0]]; // 1 day expiration
	}
	
	return (self);
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

- (void)setHandle:(NSString *)handle {
	_handle = handle;
}


#pragma mark - AsyncResource Observers
- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data {
	//NSLog(@"MBLAsyncResource.data [%@]", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	_imgView.image = [UIImage imageWithData:data];
}

- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error {
	_imageResource = nil;
}

#pragma mark - Navigation
- (void)_goPress {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_USER_PRESSED" object:_fbUser];
}

@end
