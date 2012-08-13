//
//  SNSplashViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.10.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <FBiOSSDK/FacebookSDK.h>

#import "SNSplashViewController_iPhone.h"
#import "SNRootViewController_iPhone.h"
#import "SNLoginViewController_iPhone.h"

#import "SNAppDelegate.h"
#import "SNTopicVO.h"
#import "SNImageVO.h"

#import "MBLResourceLoader.h"

@interface SNSplashViewController_iPhone() <MBLResourceObserverProtocol>
@property(nonatomic, strong) MBLAsyncResource *topicsListResource;
@property(nonatomic, strong) MBLAsyncResource *popularArticlesResource;
@property(nonatomic, strong) MBLAsyncResource *popularImagesResource;
@end

@implementation SNSplashViewController_iPhone

@synthesize topicsListResource = _topicsListResource;
@synthesize popularArticlesResource = _popularArticlesResource;
@synthesize popularImagesResource = _popularImagesResource;

-(id)init {
	if ((self = [super init])) {
		_frameIndex = 1;
		_topicIndex = 0;
		_imgIndex = 0;
		_topicNames = [NSMutableArray new];//arrayWithObjects:@"Funny", @"Apps", @"Games", @"Pics", @"Videos", nil];
		_imageURLs = [NSMutableArray new];
		
		_isIntroComplete = NO;
		_hasDeviceToken = NO;
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:[NSNumber numberWithInt:1] forKey:@"splash_state"];
		[defaults synchronize];
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}
		  
-(void)dealloc {
	if (_topicsListResource != nil) {
		[_topicsListResource unsubscribe:self];
		_topicsListResource = nil;
	}
	
	if (_popularArticlesResource != nil) {
		[_popularArticlesResource unsubscribe:self];
		_popularArticlesResource = nil;
	}
	
	if (_popularImagesResource != nil) {
		[_popularImagesResource unsubscribe:self];
		_popularImagesResource = nil;
	}
	
	_topicNames = nil;
	_imageURLs = nil;
}

-(void)setTopicsListResource:(MBLAsyncResource *)topicsListResource {
	if (_topicsListResource != nil) {
		[_topicsListResource unsubscribe:self];
		_topicsListResource = nil;
	}
	
	_topicsListResource = topicsListResource;
	
	if (_topicsListResource != nil)
		[_topicsListResource subscribe:self];
}

-(void)setPopularArticlesResource:(MBLAsyncResource *)popularArticlesResource {
	if (_popularArticlesResource != nil) {
		[_popularArticlesResource unsubscribe:self];
		_popularArticlesResource = nil;
	}
	
	_popularArticlesResource = popularArticlesResource;
	
	if (_popularArticlesResource != nil)
		[_popularArticlesResource subscribe:self];
}

-(void)setPopularImagesResource:(MBLAsyncResource *)popularImagesResource {
	if (_popularImagesResource != nil) {
		[_popularImagesResource unsubscribe:self];
		_popularImagesResource = nil;
	}
	
	_popularImagesResource = popularImagesResource;
	
	if (_popularImagesResource != nil)
		[_popularImagesResource subscribe:self];
}

- (void)restart {
	_topicsListResource = nil;
	NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
	[formValues setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		
	NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, kTopicsAPI];
	self.topicsListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate dateWithTimeIntervalSinceNow:60.0 * 60.0]]; // 1 hour for now
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_boot.png"];
	[self.view addSubview:bgImgView];
	
	_logoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(29.0, 175.0, 64.0, 64.0)];
	_logoImgView.alpha = 0.0;
	_logoImgView.image = [UIImage imageNamed:@"logoLoader_001.png"];
	[self.view addSubview:_logoImgView];
	
	_topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(35.0, 253.0, 290.0, 18.0)];
	_topicLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:15];
	_topicLabel.textColor = [UIColor whiteColor];
	_topicLabel.backgroundColor = [UIColor clearColor];
	_topicLabel.alpha = 0.0;
	_topicLabel.text = @"Assembling";
	[self.view addSubview:_topicLabel];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_logoImgView.alpha = 1.0;
	}];
	
	if (_topicsListResource == nil) {
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
	
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, kTopicsAPI];
		self.topicsListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate dateWithTimeIntervalSinceNow:60.0 * 60.0]]; // 1 hour for now
	}
	
	//_frameTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(_nextFrame) userInfo:nil repeats:YES];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}


-(void)_nextFrame {
	//NSLog(@"TIMER TICK");
	
	_logoImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"logoLoader_00%d.png", (_frameIndex % 6) + 1]];
	
	_frameIndex++;
	if (_frameIndex == 7) {
		[_frameTimer invalidate];
		_frameTimer = nil;
		
		UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35.0, 277.0, 290.0, 18.0)];
		subtitleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:15];
		subtitleLabel.textColor = [UIColor colorWithWhite:0.545 alpha:1.0];
		subtitleLabel.backgroundColor = [UIColor clearColor];
		subtitleLabel.alpha = 0.0;
		subtitleLabel.text = @"for you to discover & share";
		[self.view addSubview:subtitleLabel];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_topicLabel.alpha = 1.0;
			subtitleLabel.alpha = 1.0;
		}];
		
		_topicTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(_nextTopic) userInfo:nil repeats:YES];
	}
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)_nextTopic {
	_topicIndex++;
	
	if (_topicIndex == [_topicNames count] - 1) {
		[_topicTimer invalidate];
		_topicTimer = nil;
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:[NSNumber numberWithInt:2] forKey:@"splash_state"];
		[defaults synchronize];
		_isIntroComplete = YES;
		
		if (_hasDeviceToken && _isIntroComplete) {
			//[SNAppDelegate openSession];
			
			if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
				[self.navigationController pushViewController:[[SNRootViewController_iPhone alloc] init] animated:YES];
			
			else
				[self.navigationController pushViewController:[[SNLoginViewController_iPhone alloc] init] animated:YES];
			
//			[self.navigationController pushViewController:[[SNLoginViewController_iPhone alloc] init] animated:YES];
		}
	}
	
	_topicLabel.text = [NSString stringWithFormat:@"Assembling %@", [_topicNames objectAtIndex:_topicIndex]];
}

- (void)proceedToList {
	_hasDeviceToken = YES;
	
	if (_isIntroComplete) {
		if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
			[self.navigationController pushViewController:[[SNRootViewController_iPhone alloc] init] animated:YES];
		
		else
			[self.navigationController pushViewController:[[SNLoginViewController_iPhone alloc] init] animated:YES];

		
		//[self.navigationController pushViewController:[[SNLoginViewController_iPhone alloc] init] animated:YES];
		//[self.navigationController pushViewController:[[SNRootViewController_iPhone alloc] init] animated:YES];
	}
}

#pragma mark - Async Resource Observers
- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data {
	NSLog(@"MBLAsyncResource.data [%@]", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	
	if (resource == _topicsListResource) {
		NSError *error = nil;
		NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];//[unsortedLists sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
		
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedDescription]);
		
		} else {
			NSMutableArray *list = [NSMutableArray array];
			for (NSDictionary *serverList in parsedLists) {
				SNTopicVO *vo = [SNTopicVO topicWithDictionary:serverList];
				if (vo != nil)
					[list addObject:vo.title];
			}
			
			_topicNames = list;
			_frameTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(_nextFrame) userInfo:nil repeats:YES];
			
			if (_popularArticlesResource == nil) {
				NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
				[formValues setObject:[NSString stringWithFormat:@"%d", 10] forKey:@"action"];
				
				NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, kArticlesAPI];
				self.popularArticlesResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:NO expiration:[NSDate dateWithTimeIntervalSinceNow:60.0 * 5.0]]; // 5 minutes for now
			}
		}
	
	} else if (resource == _popularArticlesResource) {
		NSError *error = nil;
		NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];//[unsortedLists sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
		
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedDescription]);			
		
		} else {
			NSMutableArray *list = [NSMutableArray array];
			for (NSDictionary *serverList in parsedLists) {
				SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverList];
				[list addObject:((SNImageVO *)[vo.images objectAtIndex:0]).url];
			}
			
			_imageURLs = list;
			
			_imgIndex = 0;
			if (_popularImagesResource == nil) {
				self.popularImagesResource = [[MBLResourceLoader sharedInstance] downloadURL:[_imageURLs objectAtIndex:_imgIndex] forceFetch:NO expiration:[NSDate dateWithTimeIntervalSinceNow:60.0 * 60.0 * 24.0]]; // 1 day from now
			}
		}
	
	} else if (resource == _popularImagesResource) {
		NSError *error = nil;
		
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedDescription]);			
		
		} else {
			_imgIndex++;
			
			if (_imgIndex < [_imageURLs count]) {
				self.popularImagesResource = [[MBLResourceLoader sharedInstance] downloadURL:[_imageURLs objectAtIndex:_imgIndex] forceFetch:NO expiration:[NSDate dateWithTimeIntervalSinceNow:60.0 * 60.0]];
			}
		}
	}
}

- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error {
}


-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}


@end
