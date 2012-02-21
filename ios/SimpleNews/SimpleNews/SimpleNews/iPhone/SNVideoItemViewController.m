//
//  SNVideoItemViewController.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoItemViewController.h"

#import "SNAppDelegate.h"

@implementation SNVideoItemViewController

-(id)initWithVO:(SNVideoItemVO *)vo {
	if ((self = [super init])) {
		_vo = vo;
	}
	
	return (self);
}

-(void)dealloc {
	_imageView = nil;
	_titleLabel = nil;
	
	[super dealloc];
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	_imageView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 150.0)];
	_imageView.imageURL = [NSURL URLWithString:_vo.image_url];
	_imageView.alpha = 0.5;
	_imageView.clipsToBounds = YES;
	[self.view addSubview:_imageView];
	
	_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 105, self.view.frame.size.width, 30)];
	_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:24.0];
	_titleLabel.backgroundColor = [UIColor clearColor];
	_titleLabel.textColor = [UIColor whiteColor];
	_titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	_titleLabel.text = _vo.video_title;
	[self.view addSubview:_titleLabel];
	
	_infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 130, self.view.frame.size.width, 24)];
	_infoLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:18.0];
	_infoLabel.backgroundColor = [UIColor clearColor];
	_infoLabel.textColor = [UIColor whiteColor];
	_infoLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	_infoLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	_infoLabel.text = _vo.video_info;
	[self.view addSubview:_infoLabel];
	
	UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 149.0, self.view.frame.size.width, 1.0)] autorelease];
	[lineView setBackgroundColor:[UIColor whiteColor]];
	
	[self.view addSubview:lineView];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}

@end
