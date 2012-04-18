//
//  SNArticleDetailsViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.17.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleDetailsViewController_iPhone.h"

#import "SNAppDelegate.h"
#import "SNHeaderView_iPhone.h"
#import "SNArticleVideoPlayerView_iPhone.h"

@implementation SNArticleDetailsViewController_iPhone

-(id)initWithArticleVO:(SNArticleVO *)vo {
	if ((self = [super init])) {
		_vo = vo;
		_isOptions = NO;
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	[self.view setBackgroundColor:[UIColor whiteColor]];
	
	_articleOptionsView = [[SNArticleOptionsView_iPhone alloc] init];
	[self.view addSubview:_articleOptionsView];
	
	SNHeaderView_iPhone *headView = [[[SNHeaderView_iPhone alloc] initWithTitle:_vo.title] autorelease];
	[self.view addSubview:headView];
	
	UIButton *backButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
	backButton.frame = CGRectMake(4.0, 4.0, 44.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	_viewOptionsButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
	_viewOptionsButton.frame = CGRectMake(262.0, -6.0, 64.0, 64.0);
	[_viewOptionsButton setBackgroundImage:[UIImage imageNamed:@"fontButton_nonActive.png"] forState:UIControlStateNormal];
	[_viewOptionsButton setBackgroundImage:[UIImage imageNamed:@"fontButton_Active.png"] forState:UIControlStateHighlighted];
	[_viewOptionsButton addTarget:self action:@selector(_goOptions) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_viewOptionsButton];
	
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 54.0, self.view.frame.size.width, self.view.frame.size.height - 54.0)];
	[self.view addSubview:_holderView];
	
	
	CGSize size;
	int offset = 22;
	
	size = [_vo.title sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(274.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(22.0, offset, 274.0, size.height)] autorelease];
	titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:16];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = _vo.title;
	titleLabel.numberOfLines = 0;
	[_holderView addSubview:titleLabel];
	offset += size.height + 22;
	
	size = [_vo.articleSource sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14] constrainedToSize:CGSizeMake(274.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	UILabel *sourceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(22.0, offset, 274.0, size.height)] autorelease];
	sourceLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
	sourceLabel.textColor = [UIColor blackColor];
	sourceLabel.backgroundColor = [UIColor clearColor];
	sourceLabel.text = _vo.articleSource;
	[_holderView addSubview:sourceLabel];
	offset += size.height + 22;
	
	if (_vo.type_id > 4) {
		_videoPlayerView = [[SNArticleVideoPlayerView_iPhone alloc] initWithFrame:CGRectMake(22.0, offset, 274.0, 180.0) articleVO:_vo];
		[_holderView addSubview:_videoPlayerView];		
		offset += _videoPlayerView.frame.size.height + 22;
	}
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	NSString *dateString = [dateFormatter stringFromDate:_vo.added];
	[dateFormatter release];
	
	UILabel *dateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(22.0, offset, 100.0, 16.0)] autorelease];
	dateLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	dateLabel.textColor = [UIColor blackColor];
	dateLabel.backgroundColor = [UIColor clearColor];
	dateLabel.text = dateString;
	[_holderView addSubview:dateLabel];
	offset += 22 + 16;
	
	size = [_vo.content sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(274.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	UILabel *contentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(22.0, offset, 274.0, size.height)] autorelease];
	contentLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
	contentLabel.textColor = [UIColor blackColor];
	contentLabel.backgroundColor = [UIColor clearColor];
	contentLabel.text = _vo.content;
	contentLabel.numberOfLines = 0;
	[_holderView addSubview:contentLabel];
	offset += size.height + 22;
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
-(void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)_goOptions {
	_isOptions = !_isOptions;
	
	if (_isOptions) {
		[_viewOptionsButton setBackgroundImage:[UIImage imageNamed:@"fontButton_Selected.png"] forState:UIControlStateNormal];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_articleOptionsView.frame = CGRectMake(_articleOptionsView.frame.origin.x, 54.0, _articleOptionsView.frame.size.width, _articleOptionsView.frame.size.height);
			_holderView.frame = CGRectMake(0.0, _holderView.frame.origin.y + _articleOptionsView.frame.size.height, _holderView.frame.size.width, _holderView.frame.size.height);
		}];
		
	} else {
		[_viewOptionsButton setBackgroundImage:[UIImage imageNamed:@"fontButton_nonActive.png"] forState:UIControlStateNormal];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_articleOptionsView.frame = CGRectMake(_articleOptionsView.frame.origin.x, -26.0, _articleOptionsView.frame.size.width, _articleOptionsView.frame.size.height);
			_holderView.frame = CGRectMake(0.0, _holderView.frame.origin.y - _articleOptionsView.frame.size.height, _holderView.frame.size.width, _holderView.frame.size.height);
		}];
	}
}

@end
