//
//  SNActivityViewCell.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.23.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNActivityViewCell.h"

#import "MBLResourceLoader.h"
#import "SNAppDelegate.h"

@interface SNActivityViewCell () <MBLResourceObserverProtocol>
@property(nonatomic, strong) MBLAsyncResource *imageResource;
@end

@implementation SNActivityViewCell

@synthesize articleVO = _articleVO;
@synthesize imageResource = _imageResource;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)init {
	if ((self = [super init])) {
		_imgView = [[UIImageView alloc] initWithFrame:CGRectMake(4.0, 4.0, 26.0, 26.0)];
		[_imgView setBackgroundColor:[UIColor colorWithWhite:0.961 alpha:1.0]];
		[self addSubview:_imgView];
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 6.0, 256.0, 28.0)];
		_nameLabel.frame = CGRectOffset(_nameLabel.frame, 34.0, 0.0);
		_nameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:15];
		_nameLabel.textColor = [UIColor grayColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_nameLabel];
		
		_activeBGImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 227.0, 42.0)];
		_activeBGImgView.image = [UIImage imageNamed:@"leftMenuRowActive.png"];
		_activeBGImgView.alpha = 0.0;
		[self addSubview:_activeBGImgView];
	}
	
	return (self);
}

#pragma mark - Accessors
- (void)setArticleVO:(SNArticleVO *)articleVO {
	NSLog(@"ARTICLE :[%@]", articleVO.title);
	_articleVO = articleVO;
	_nameLabel.text = _articleVO.title;
	
	self.imageResource = [[MBLResourceLoader sharedInstance] downloadURL:articleVO.avatarImage_url forceFetch:NO expiration:[NSDate dateWithTimeIntervalSinceNow:60.0 * 60.0 * 24.0]]; // 1 day expiration
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

- (void)tapped {
	_nameLabel.textColor = [UIColor colorWithWhite:0.373 alpha:1.0];
	
	[UIView animateWithDuration:0.15 animations:^(void) {
		_activeBGImgView.alpha = 1.0;
		
	} completion:^(BOOL finished) {
		_nameLabel.textColor = [UIColor whiteColor];
		_activeBGImgView.alpha = 0.0;
	}];
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
