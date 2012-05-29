//
//  SNSplashViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.10.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNSplashViewController_iPhone.h"
#import "SNRootViewController_iPhone.h"

#import "SNAppDelegate.h"
#import "SNTopicVO.h"

@interface SNSplashViewController_iPhone()
@end

@implementation SNSplashViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		_frameIndex = 1;
		_topicIndex = 0;
		_topics = [NSMutableArray new];
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}
		  
-(void)dealloc {
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_boot.png"];
	[self.view addSubview:bgImgView];
	
	_logoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 170.0, 64.0, 64.0)];
	_logoImgView.alpha = 0.0;
	_logoImgView.image = [UIImage imageNamed:@"logoLoader_001.png"];
	[self.view addSubview:_logoImgView];
	
	_topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 245.0, 290.0, 16.0)];
	_topicLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	_topicLabel.textColor = [UIColor whiteColor];
	_topicLabel.backgroundColor = [UIColor clearColor];
	_topicLabel.alpha = 0.0;
	_topicLabel.text = @"Assembling";
	[self.view addSubview:_topicLabel];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_logoImgView.alpha = 1.0;
	}];
	
	ASIFormDataRequest *topicRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Topics.php"]]];
	[topicRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
	[topicRequest setDelegate:self];
	[topicRequest startAsynchronous];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}


-(void)_nextFrame {
	//NSLog(@"TIMER TICK");
	
	_logoImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"logoLoader_00%d.png", _frameIndex]];
	
	_frameIndex++;
	if (_frameIndex == 7) {
		[_frameTimer invalidate];
		_frameTimer = nil;
		
		UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 263.0, 290.0, 16.0)];
		subtitleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:12];
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
	NSLog(@"TIMER TICK");
	
	_topicIndex++;
	
	if (_topicIndex == [_topics count] - 1) {
		[_topicTimer invalidate];
		_topicTimer = nil;
		
		[self.navigationController pushViewController:[[SNRootViewController_iPhone alloc] init] animated:YES];
	}
	
	_topicLabel.text = [NSString stringWithFormat:@"Assembling %@", [_topics objectAtIndex:_topicIndex]];
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNSplashView_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSArray *parsedTopics = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSMutableArray *topicList = [NSMutableArray array];
			_topics = [NSMutableArray new];
			
			for (NSDictionary *serverTopic in parsedTopics) {
				SNTopicVO *vo = [SNTopicVO topicWithDictionary:serverTopic];
				
				//NSLog(@"ARTICLE \"%@\"", vo.title);
				
				if (vo != nil)
					[topicList addObject:vo.title];
				
				
				NSLog(@"TITLE:[%@]", vo.title);
			}
			
			_topics = [topicList copy];
			_frameTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(_nextFrame) userInfo:nil repeats:YES];
		}
	}
}


-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}


@end
