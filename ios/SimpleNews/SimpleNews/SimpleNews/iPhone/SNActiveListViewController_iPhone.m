//
//  SNActiveListViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SNActiveListViewController_iPhone.h"
#import "SNVideoItemVO.h"

#import "EGOImageView.h"
#import "SNAppDelegate.h"


@interface SNActiveListViewController_iPhone()
-(void)_itemTapped:(NSNotification *)notification;
-(void)_videoDuration:(NSNotification *)notification;
-(void)_videoTime:(NSNotification *)notification;
-(void)_videoEnded:(NSNotification *)notification;
@end

@implementation SNActiveListViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_itemTapped:) name:@"ITEM_TAPPED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoDuration:) name:@"VIDEO_DURATION" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoTime:) name:@"VIDEO_TIME" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoEnded:) name:@"VIDEO_ENDED" object:nil];
		
		_isPaused = YES;
		_isSrubbing = NO;
		_duration = -1.0;
		
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
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	_currImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 55.0, self.view.frame.size.width, 83.0)];
	_currImgView.imageURL = [NSURL URLWithString:@"http://dev.gullinbursti.cc/projs/simplenews/app/images/newsPost-02.jpg"];
	
	_nextImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 138.0, self.view.frame.size.width, 83.0)];
	_nextImgView.imageURL = [NSURL URLWithString:@"http://dev.gullinbursti.cc/projs/simplenews/app/images/newsPost-02.jpg"];
	
	[self.view addSubview:_currImgView];
	[self.view addSubview:_nextImgView];
	
	// YT
	//NSString *videoID = @"NGC_EzojK6E";
	//NSString *htmlString = [NSString stringWithFormat:@"<html><head><meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 320\"/></head><body style=\"background:#000; margin-top:0px; margin-left:0px\"><div id=\"player\"></div><script>var tag = document.createElement('script');tag.src = 'http://www.youtube.com/player_api';var firstScriptTag = document.getElementsByTagName('script')[0];firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);var player;function onYouTubePlayerAPIReady() {player = new YT.Player('player', {width: '320', height: '83', videoId: '%@', playerVars: {'autoplay': 1, 'controls': 0}, events: {'onReady': onPlayerReady,'onStateChange': onPlayerStateChange}});}function onPlayerReady(event) {event.target.playVideo();}var isPaused = false;function onPlayerStateChange(event) {switch (event.data) {case YT.PlayerState.PLAYING:if (!isPaused) {isPaused = true;setTimeout(stopVideo, 100);}break;case YT.PlayerState.ENDED:break;}} function stopVideo(){player.stopVideo();}</script></body></html>", videoID];
	
	// VIDEO TAG -- DEFAULT
	//NSString *htmlString = @"<html><head><meta name=\"viewport\" content=\"initial-scale = 1.0, user-scalable = no, width = 320\"/></head><body style=\"background:#000; margin-top:0px; margin-left:0px\"><video id=\"vidPlayer\" width=\"320\" height=\"83\" autoplay=\"autoplay\" webkit-playsinline><source src=\"http://dev.gullinbursti.cc/projs/simplenews/app/videos/ffvi_intro.mp4\" type=\"video/mp4\" />Your browser does not support the video tag.</video></body></html>";
	
	// VIDEO TAG -- CONTROL BTNS
	//NSString *htmlString = @"<html><body><div style=\"text-align:center\"><button onclick=\"playPause()\">Play/Pause</button><button onclick=\"makeBig()\">Big</button><button onclick=\"makeSmall()\">Small</button><button onclick=\"makeNormal()\">Normal</button><br /><video id=\"video1\" webkit-playsinline><source src=\"http://dev.gullinbursti.cc/projs/simplenews/app/videos/ffvi_intro.mp4\" type=\"video/mp4\" />Your browser does not support HTML5 video.</video></div><script type=\"text/javascript\">var myVideo=document.getElementById('video1'); function playPause() {if (myVideo.paused) myVideo.play(); else myVideo.pause();} function makeBig(){myVideo.height=(myVideo.videoHeight*2);} function makeSmall(){myVideo.height=(myVideo.videoHeight/2);} function makeNormal(){myVideo.height=(myVideo.videoHeight);}</script></body></html>";
	
	// VIDEO TAG -- AUTOSTART
	//NSString *videoURL = @"http://dev.gullinbursti.cc/projs/simplenews/app/videos/ffvi_intro.mp4";
	//NSString *htmlString = [NSString stringWithFormat:@"<html><head><meta name=\"viewport\" content=\"initial-scale = 1.0, user-scalable = no, width = 320\"/></head><body style=\"background-color:black;\"><div style=\"text-align:center;\"><video id=\"video1\" webkit-playsinline onloadedmetadata=\"onMetadata()\" onended=\"onPlaybackEnded()\"><source src=\"%@\" type=\"video/mp4\" onerror=\"onError()\" />Your browser does not support HTML5 video.</video></div><script type=\"text/javascript\">var video_obj=document.getElementById('video1'); video_obj.addEventListener(\"timeupdate\", function(){sendValue('time', video_obj.currentTime);}, false); function onMetadata(){sendValue('duration', video_obj.duration);} function onPlaybackEnded(){sendValue('state', \"ENDED\");} function onError(){sendValue('state', \"ERROR\");} function rr(){if(video_obj.currentTime>0)video_obj.currentTime -= 0.5;} function ff(){if(video_obj.currentTime<video_obj.duration)video_obj.currentTime += 0.5;} function playPause() {if (video_obj.paused) video_obj.play(); else video_obj.pause();} function sendValue(key, val) {location.href = 'result://keyval/' + key + '/' + val;}</script></body></html>", videoURL];
	
	//NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://dev.gullinbursti.cc/projs/simplenews/app/videos/ffvi_intro.mp4"]];
	
	_playPauseButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_playPauseButton.frame = CGRectMake(144.0, 100.0, 32.0, 32.0);
	[_playPauseButton setBackgroundColor:[UIColor purpleColor]];
	[_playPauseButton addTarget:self action:@selector(_goPlayPause) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_playPauseButton];
	
	UIView *bgHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 55.0, self.view.frame.size.width, 40.0)] autorelease];
	[bgHeaderView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
	[self.view addSubview:bgHeaderView];
	
	_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0, 4.0, 300.0, 18.0)];
	_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14.0];
	_titleLabel.backgroundColor = [UIColor clearColor];
	_titleLabel.textColor = [UIColor whiteColor];
	_titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
	_titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	_titleLabel.text = @"";
	[bgHeaderView addSubview:_titleLabel];
	
	_progressBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, 55.0, self.view.frame.size.width, 4.0)];
	[_progressBar setBackgroundColor:[UIColor greenColor]];
	_progressBar.clipsToBounds = YES;
	[self.view addSubview:_progressBar];
	
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_goPan:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[panRecognizer setDelegate:self];
	[self.view addGestureRecognizer:panRecognizer];
}



-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}


-(void)_goPlayPause {
	_isPaused = !_isPaused;
	
	if (_isPaused)
		[_playPauseButton setBackgroundColor:[UIColor redColor]];
	
	else
		[_playPauseButton setBackgroundColor:[UIColor purpleColor]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_VIDEO_PLAYBACK" object:nil];
}

#pragma mark - Notification handlers
-(void)_videoDuration:(NSNotification *)notification {
	_duration = [[notification object] floatValue];
}

-(void)_videoTime:(NSNotification *)notification {
	_currTime = [[notification object] floatValue];
	float percent = _currTime / _duration;
	
	_progressBar.frame = CGRectMake(0.0, 55.0, self.view.frame.size.width * percent, 40.0);
}

-(void)_videoEnded:(NSNotification *)notification {	
	_progressBar.frame = CGRectMake(0.0, 55.0, 0.0, 4.0);
}

-(void)_itemTapped:(NSNotification *)notification {
	SNVideoItemVO *vo = (SNVideoItemVO *)[notification object];
	
	_nextImgView.imageURL = [NSURL URLWithString:vo.image_url];
	_titleLabel.text = vo.video_title;
	
	[UIView animateWithDuration:0.33 delay:0.25 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
		CGRect currImgFrame = _currImgView.frame;
		currImgFrame.origin.y -= currImgFrame.size.height;
		_currImgView.frame = currImgFrame;
		
		CGRect nextImgFrame = _nextImgView.frame;
		nextImgFrame.origin.y -= nextImgFrame.size.height;
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


#pragma mark- Interaction handlers
-(void)_goPan:(id)sender {
	CGPoint transPt = [(UIPanGestureRecognizer*)sender translationInView:self.view];

	if([(UIPanGestureRecognizer *)sender state] == UIGestureRecognizerStateBegan) {
		_playPauseButton.hidden = YES;
		_isPaused = YES;
		_isSrubbing = YES;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"START_VIDEO_SCRUB" object:nil];
		
		float offset = 0.0;
		
		// left
		if (transPt.x < 0.0 && abs(transPt.y) < 10) {
			offset = -64.0;
			_scrubTimer = [NSTimer scheduledTimerWithTimeInterval:0.125 target:self selector:@selector(_ff) userInfo:nil repeats:YES];
		}
		
		// right
		if (transPt.x > 0.0 && abs(transPt.y) < 10) {
			offset = 64.0;
			_scrubTimer = [NSTimer scheduledTimerWithTimeInterval:0.125 target:self selector:@selector(_rr) userInfo:nil repeats:YES];	
		}
		
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_currImgView.frame = CGRectMake(offset, _currImgView.frame.origin.y, _currImgView.frame.size.width, _currImgView.frame.size.height);
		}];
		
		[[NSRunLoop mainRunLoop] addTimer:_scrubTimer forMode:NSDefaultRunLoopMode];
	}
	
	
	
	if([(UIPanGestureRecognizer *)sender state] == UIGestureRecognizerStateEnded) {
		_playPauseButton.hidden = NO;
		_isPaused = NO;
		_isSrubbing = NO;
		
		[_scrubTimer invalidate];
		_scrubTimer = nil;
		
		[UIView animateWithDuration:0.125 animations:^(void) {
			_currImgView.frame = CGRectMake(0.0, _currImgView.frame.origin.y, _currImgView.frame.size.width, _currImgView.frame.size.height);
		}];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"STOP_VIDEO_SCRUB" object:nil];
	}
}


-(void)_ff {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FF_VIDEO_TIME" object:nil];
}

-(void)_rr {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RR_VIDEO_TIME" object:nil];
}


@end
