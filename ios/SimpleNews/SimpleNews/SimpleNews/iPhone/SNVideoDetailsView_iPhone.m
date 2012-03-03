//
//  SNVideoDetailsView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoDetailsView_iPhone.h"

#import "SNAppDelegate.h"
#import "UIImage+StackBlur.h"

@interface SNVideoDetailsView_iPhone()
-(void)_videoDuration:(NSNotification *)notification;
-(void)_videoEnded:(NSNotification *)notification;
-(void)_changeVideo:(NSNotification *)notification;
@end

@implementation SNVideoDetailsView_iPhone

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoDuration:) name:@"VIDEO_DURATION" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoEnded:) name:@"VIDEO_ENDED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changeVideo:) name:@"CHANGE_VIDEO" object:nil];
		
		[self setBackgroundColor:[UIColor blackColor]];
		self.clipsToBounds = YES;
		
		_isPaused = YES;
		_isScrubbing = YES;
		
		_imageHolderView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)] autorelease];
		_imageHolderView.clipsToBounds = YES;
		[self addSubview:_imageHolderView];
		
		//_imageView = [[EGOImageView alloc] initWithFrame:CGRectMake(-368.0, -288.0, 704.0, 1056.0)];
		_imageView = [[EGOImageView alloc] initWithFrame:CGRectMake(-150.0, 0.0, 480.0, 360.0)];
		_imageView.alpha = 0.15;
		_imageView.transform = CGAffineTransformMakeScale(2.2, 2.2);
		_imageView.image = [_imageView.image stackBlur:8];
		_imageView.clipsToBounds = YES;
		[_imageHolderView addSubview:_imageView];
		
		_playPauseButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_playPauseButton.frame = _imageHolderView.frame;
		[_playPauseButton addTarget:self action:@selector(_goPlayPause) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_playPauseButton];
		
		_backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_backButton.frame = CGRectMake(0.0, 0.0, 35.0, 35.0);
		[_backButton setBackgroundImage:[UIImage imageNamed:@"closeButton.png"] forState:UIControlStateNormal];
		[_backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_backButton];
		
		
		_channelImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(27.0, 200.0, 44.0, 44.0)];
		[self addSubview:_channelImageView];
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(27.0, 270.0, self.frame.size.width - 35.0, 70.0)];
		_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:18.0];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.numberOfLines = 0;
		_titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_titleLabel.text = @"";
		[self addSubview:_titleLabel];
		
		UIImageView *hdImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(284.0, 440.0, 24.0, 24.0)] autorelease];
		hdImgView.image = [UIImage imageNamed:@"hd.png"];
		[self addSubview:hdImgView];
		
		/*
		UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_goPan:)];
		[panRecognizer setMinimumNumberOfTouches:1];
		[panRecognizer setMaximumNumberOfTouches:1];
		[panRecognizer setDelegate:self];
		[self addGestureRecognizer:panRecognizer];
		*/
	}
	
	return (self);
}

-(void)changeVideo:(SNVideoItemVO *)vo {
	_vo = vo;
	CGSize textSize = [_vo.video_title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:18] constrainedToSize:CGSizeMake(self.frame.size.width - 35.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	_titleLabel.frame = CGRectMake(27.0, 265.0, textSize.width, textSize.height);
	_titleLabel.text = _vo.video_title;
	_channelImageView.imageURL = [NSURL URLWithString:_vo.image_url];
}


#pragma mark - Navigation handlers
-(void)_goBack {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DETAILS_RETURN" object:nil];
	_imageView.image = nil;
}

-(void)_goPlayPause {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_VIDEO_PLAYBACK" object:nil];
}

#pragma mark- Interaction handlers
-(void)_goPan:(id)sender {
	CGPoint transPt = [(UIPanGestureRecognizer*)sender translationInView:_imageHolderView];
	NSLog(@"PANNING:(%f, %d)", transPt.x, abs(transPt.y));
	
	if([(UIPanGestureRecognizer *)sender state] == UIGestureRecognizerStateBegan) {
		_isPaused = YES;
		_isScrubbing = YES;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"START_VIDEO_SCRUB" object:nil];
		
		float offset = 0.0;
		
		// left
		if (transPt.x < 0.0 && abs(transPt.y) < 32) {
			offset = -64.0;
			_scrubTimer = [NSTimer scheduledTimerWithTimeInterval:0.125 target:self selector:@selector(_ff) userInfo:nil repeats:YES];
			[[NSRunLoop mainRunLoop] addTimer:_scrubTimer forMode:NSDefaultRunLoopMode];
		}
		
		// right
		if (transPt.x > 0.0 && abs(transPt.y) < 32) {
			offset = 64.0;
			_scrubTimer = [NSTimer scheduledTimerWithTimeInterval:0.125 target:self selector:@selector(_rr) userInfo:nil repeats:YES];	
			[[NSRunLoop mainRunLoop] addTimer:_scrubTimer forMode:NSDefaultRunLoopMode];
		}
		
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_imageHolderView.frame = CGRectMake(offset, _imageHolderView.frame.origin.y, _imageHolderView.frame.size.width, _imageHolderView.frame.size.height);
		}];
	}
	
	
	
	if([(UIPanGestureRecognizer *)sender state] == UIGestureRecognizerStateEnded) {
		_isPaused = NO;
		_isScrubbing = NO;
		
		[_scrubTimer invalidate];
		_scrubTimer = nil;
		
		[UIView animateWithDuration:0.125 animations:^(void) {
			_imageHolderView.frame = CGRectMake(0.0, _imageHolderView.frame.origin.y, _imageHolderView.frame.size.width, _imageHolderView.frame.size.height);
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




#pragma mark - Notification handlers
-(void)_videoDuration:(NSNotification *)notification {
}

-(void)_videoEnded:(NSNotification *)notification {
	[self _goBack];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NEXT_VIDEO" object:nil];
}

-(void)_changeVideo:(NSNotification *)notification {
	_imageView.imageURL = [NSURL URLWithString:_vo.image_url];
}

@end
