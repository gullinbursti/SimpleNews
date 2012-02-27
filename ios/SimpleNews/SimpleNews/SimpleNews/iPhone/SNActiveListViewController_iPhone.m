//
//  SNActiveListViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNActiveListViewController_iPhone.h"
#import "SNVideoItemVO.h"

#import "EGOImageView.h"

@implementation SNActiveListViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_itemTapped:) name:@"ITEM_TAPPED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoProgression:) name:@"VIDEO_PROGRESSION" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_searchEntered:) name:@"SEARCH_ENTERED" object:nil];
		
		_items = [[NSMutableArray alloc] init];
		self.view.frame = CGRectMake(0.0, -55.0, self.view.frame.size.width, 138);
		self.view.clipsToBounds = YES;
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)dealloc {
	[super dealloc];
}


#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	//self.view.alpha = 0.67;
	
	_currImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 55.0, self.view.frame.size.width, 83.0)];
	_currImgView.imageURL = [NSURL URLWithString:@"http://dev.gullinbursti.cc/projs/simplenews/app/images/newsPost-02.jpg"];
	
	_nextImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 138.0, self.view.frame.size.width, 83.0)];
	_nextImgView.imageURL = [NSURL URLWithString:@"http://dev.gullinbursti.cc/projs/simplenews/app/images/newsPost-02.jpg"];
	
	[self.view addSubview:_currImgView];
	[self.view addSubview:_nextImgView];
	
	_videoSearchView = [[SNVideoSearchView_iPhone alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 55.0)];
	[self.view addSubview:_videoSearchView];
	
	// YT
	//NSString *videoID = @"NGC_EzojK6E";
	//NSString *htmlString = [NSString stringWithFormat:@"<html><head><meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 320\"/></head><body style=\"background:#000; margin-top:0px; margin-left:0px\"><div id=\"player\"></div><script>var tag = document.createElement('script');tag.src = 'http://www.youtube.com/player_api';var firstScriptTag = document.getElementsByTagName('script')[0];firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);var player;function onYouTubePlayerAPIReady() {player = new YT.Player('player', {width: '320', height: '83', videoId: '%@', playerVars: {'autoplay': 1, 'controls': 0}, events: {'onReady': onPlayerReady,'onStateChange': onPlayerStateChange}});}function onPlayerReady(event) {event.target.playVideo();}var isPaused = false;function onPlayerStateChange(event) {switch (event.data) {case YT.PlayerState.PLAYING:if (!isPaused) {isPaused = true;setTimeout(stopVideo, 100);}break;case YT.PlayerState.ENDED:break;}} function stopVideo(){player.stopVideo();}</script></body></html>", videoID];
	
	// VIDEO TAG -- DEFAULT
	//NSString *htmlString = @"<html><head><meta name=\"viewport\" content=\"initial-scale = 1.0, user-scalable = no, width = 320\"/></head><body style=\"background:#000; margin-top:0px; margin-left:0px\"><video id=\"vidPlayer\" width=\"320\" height=\"83\" autoplay=\"autoplay\" webkit-playsinline><source src=\"http://dev.gullinbursti.cc/projs/simplenews/app/videos/ffvi_intro.mp4\" type=\"video/mp4\" />Your browser does not support the video tag.</video></body></html>";
	
	// VIDEO TAG -- CONTROL BTNS
	//NSString *htmlString = @"<html><body><div style=\"text-align:center\"><button onclick=\"playPause()\">Play/Pause</button><button onclick=\"makeBig()\">Big</button><button onclick=\"makeSmall()\">Small</button><button onclick=\"makeNormal()\">Normal</button><br /><video id=\"video1\" webkit-playsinline><source src=\"http://dev.gullinbursti.cc/projs/simplenews/app/videos/ffvi_intro.mp4\" type=\"video/mp4\" />Your browser does not support HTML5 video.</video></div><script type=\"text/javascript\">var myVideo=document.getElementById('video1'); function playPause() {if (myVideo.paused) myVideo.play(); else myVideo.pause();} function makeBig(){myVideo.height=(myVideo.videoHeight*2);} function makeSmall(){myVideo.height=(myVideo.videoHeight/2);} function makeNormal(){myVideo.height=(myVideo.videoHeight);}</script></body></html>";
	
	// VIDEO TAG -- AUTOSTART
	//NSString *htmlString = @"<html><body><div style=\"text-align:center\"><video id=\"video1\" webkit-playsinline><source src=\"http://dev.gullinbursti.cc/projs/simplenews/app/videos/ffvi_intro.mp4\" type=\"video/mp4\" />Your browser does not support HTML5 video.</video></div><script type=\"text/javascript\">var myVideo=document.getElementById('video1'); function playPause() {if (myVideo.paused) myVideo.play(); else myVideo.pause();} function makeBig(){myVideo.height=(myVideo.videoHeight*2);} function makeSmall(){myVideo.height=(myVideo.videoHeight/2);} function makeNormal(){myVideo.height=(myVideo.videoHeight);}</script></body></html>";
	
	//NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://dev.gullinbursti.cc/projs/simplenews/app/videos/ffvi_intro.mp4"]];
	
	/*_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 55.0, self.view.frame.size.width, 83.0)];
	[_webView setBackgroundColor:[UIColor redColor]];
	_webView.allowsInlineMediaPlayback = YES;
	//[_webView loadRequest:request];
	[_webView loadHTMLString:htmlString baseURL:nil];
	[self.view addSubview:_webView];
	
	[self performSelector:@selector(_startPlayback) withObject:nil afterDelay:1.5];
	*/
	_progressBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, 55.0, 0.0, 8.0)];
	[_progressBar setBackgroundColor:[UIColor greenColor]];
	_progressBar.clipsToBounds = YES;
	[self.view addSubview:_progressBar];
	
	//UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_goPan:)];
	//[panRecognizer setMinimumNumberOfTouches:1];
	//[panRecognizer setMaximumNumberOfTouches:1];
	//[panRecognizer setDelegate:self];
	//[self.view addGestureRecognizer:panRecognizer];
}



-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}



-(void)_startPlayback {
	NSLog(@"START PLAYBACK");
	[_webView stringByEvaluatingJavaScriptFromString:@"playPause();"]; 
}

#pragma mark - Notification handlers
-(void)_itemTapped:(NSNotification *)notification {
	SNVideoItemVO *vo = (SNVideoItemVO *)[notification object];
	
	_nextImgView.imageURL = [NSURL URLWithString:vo.image_url];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		CGRect currImgFrame = _currImgView.frame;
		currImgFrame.origin.y = 28;
		_currImgView.frame = currImgFrame;
		
		CGRect nextImgFrame = _nextImgView.frame;
		nextImgFrame.origin.y = 55;
		_nextImgView.frame = nextImgFrame;
		
	} completion:^(BOOL finished) {
		_currImgView.imageURL = [NSURL URLWithString:vo.image_url];
		CGRect currFrame = _currImgView.frame;
		currFrame.origin.y = 55;
		_currImgView.frame = currFrame;
		
		CGRect nextFrame = _nextImgView.frame;
		nextFrame.origin.y = 138;
		_nextImgView.frame = nextFrame;
	}];
}


-(void)_videoProgression:(NSNotification *)notification {
	float percent = [(NSNumber *)[notification object] floatValue] / 120;
	
	NSLog(@"PROGESS:[%.2f]", percent);
	
	_progressBar.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width * percent, 8.0);
}

-(void)_searchEntered:(NSNotification *)notification {
	[UIView animateWithDuration:0.33 animations:^(void) {
		self.view.frame = CGRectMake(0.0, -55.0, self.view.frame.size.width, 138);
	}];
}



-(void)_goPan:(id)sender {
	//CGPoint transPt = [(UIPanGestureRecognizer*)sender translationInView:self.view];
	
	//NSLog(@"PULLED:[%f]", transPt.y);
	/*
	if (abs(transPt.x) < 10 && transPt.y > 30)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SEARCH_PULLED" object:nil];
	
	if (abs(transPt.x) < 10 && transPt.y < -30)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SEARCH_PUSHED" object:nil];
	*/
}

@end
