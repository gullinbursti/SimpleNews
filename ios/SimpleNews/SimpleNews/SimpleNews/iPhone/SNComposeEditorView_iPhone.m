//
//  SNComposeEditorView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <AWSiOSSDK/S3/AmazonS3Client.h>

#import "SNComposeEditorView_iPhone.h"
#import "SNAppDelegate.h"
#import "SNStickerVO.h"
#import "SNFacebookCaller.h"

@implementation SNComposeEditorView_iPhone

#pragma mark - View Lifecycle
- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_quoteIndex = 0;
		_stickerIndex = 0;
		_isQuote = YES;
		
		_quoteList = [NSMutableArray new];
		_stickerList = [NSMutableArray new];
	}
	
	return (self);
}

- (id)initWithFrame:(CGRect)frame withImage:(UIImage *)img {
	if ((self = [self initWithFrame:frame])) {
		NSLog(@"IMAGE:[%@]", [_fbFriend objectForKey:@"id"]);
		
		CGSize size = img.size;
		
		CGSize ratioSize = CGSizeMake(320.0 / size.width, 435.0 / size.height);
		
		BOOL isWidthScaled = NO;
		if (ratioSize.width > ratioSize.height)
			isWidthScaled = YES;
		
		CGSize scaledSize;
		if (isWidthScaled)
			scaledSize = CGSizeMake(size.width * ratioSize.width, size.height * ratioSize.width);
		
		else
			scaledSize = CGSizeMake(size.width * ratioSize.height, size.height * ratioSize.height);
		
		
		CGPoint imgPt = CGPointZero;
		if (scaledSize.width > 320.0)
			imgPt = CGPointMake((scaledSize.width - 320.0) * -0.5, 0.0);
		
		else
			imgPt = CGPointMake((scaledSize.width - 320.0) * 0.5, 0.0);
		
		
		if (scaledSize.height > 435.0)
			imgPt = CGPointMake(imgPt.x, (scaledSize.height - 435.0) * -0.5);
		
		else
			imgPt = CGPointMake(imgPt.x, (scaledSize.height - 435.0) * 0.5);
		
		_canvasView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 435.0)];
		_canvasView.clipsToBounds = YES;
		[self addSubview:_canvasView];
		
		UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(imgPt.x, imgPt.y, scaledSize.width, scaledSize.height)];
		imgView.image = img;
		[_canvasView addSubview:imgView];
		
		_quoteIndex = 0;
		_stickerIndex = 0;
		_isQuote = YES;
		
		_quoteList = [NSMutableArray new];
		_stickerList = [NSMutableArray new];
		
		NSLog(@"USER:[%@]", [_fbFriend objectForKey:@"id"]);
		
		_quoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_quoteButton addTarget:self action:@selector(_goQuote) forControlEvents:UIControlEventTouchUpInside];
		_quoteButton.frame = CGRectMake(10.0, 10.0, 100.0, 48.0);
		[_quoteButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_quoteButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_quoteButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_quoteButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_quoteButton setTitle:@"Quote" forState:UIControlStateNormal];
		[self addSubview:_quoteButton];
		
		_stickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_stickerButton addTarget:self action:@selector(_goSticker) forControlEvents:UIControlEventTouchUpInside];
		_stickerButton.frame = CGRectMake(10.0, 60.0, 100.0, 48.0);
		[_stickerButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_stickerButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_stickerButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_stickerButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_stickerButton setTitle:@"Sticker" forState:UIControlStateNormal];
		[self addSubview:_stickerButton];
		
		UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[clearButton addTarget:self action:@selector(_goClear) forControlEvents:UIControlEventTouchUpInside];
		clearButton.frame = CGRectMake(10.0, 110.0, 100.0, 48.0);
		[clearButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[clearButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[clearButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		clearButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[clearButton setTitle:@"Clear" forState:UIControlStateNormal];
		[self addSubview:clearButton];
		
		
		UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
		submitButton.frame = CGRectMake(210.0, 380.0, 100.0, 48.0);
		[submitButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[submitButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[submitButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		submitButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[submitButton setTitle:@"Submit" forState:UIControlStateNormal];
		[self addSubview:submitButton];
		
		[_quoteList addObject:@"Euismod tincidunt ut laoreet dolore magna aliquam erat volutpat ut laoreet."];
		[_quoteList addObject:@"Et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis."];
		[_quoteList addObject:@"Accumsan dolore te feugait nulla facilisi nam liber tempor cum soluta nobis"];
		[_quoteList addObject:@"Elit sed diam nonummy nibh nostrud exerci tation ullamcorper?"];
		[_quoteList addObject:@"Eodem modo typi qui, nunc nobis videntur parum."];
		[_quoteList addObject:@"Consequat duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat vel!"];
		[_quoteList addObject:@"Litterarum formas humanitatis, per seacula quarta decima et quinta decima clari fiant sollemnes in."];
		[_quoteList addObject:@"Legunt saepius claritas est etiam processus dynamicus qui sequitur mutationem consuetudium."];
		
		CGSize txtSize = [[_quoteList objectAtIndex:0] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(280.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		
		
		_quoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 150.0, 280.0, txtSize.height)];
		_quoteLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
		_quoteLabel.textColor = [UIColor whiteColor];
		_quoteLabel.userInteractionEnabled = YES;
		_quoteLabel.numberOfLines = 0;
		_quoteLabel.backgroundColor = [UIColor clearColor];
		_quoteLabel.textAlignment = UITextAlignmentCenter;
		_quoteLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.67];
		_quoteLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		_quoteLabel.text = [_quoteList objectAtIndex:0];
		[_canvasView addSubview:_quoteLabel];
		
		_customQuoteView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 240.0)];
		_customQuoteView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.85];
		_customQuoteView.hidden = YES;
		[self addSubview:_customQuoteView];
		
		_quoteTxtView = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 200.0, 280.0, txtSize.height)];
		_quoteTxtView.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
		_quoteTxtView.textColor = [UIColor whiteColor];
		_quoteTxtView.userInteractionEnabled = YES;
		_quoteTxtView.backgroundColor = [UIColor clearColor];
		_quoteTxtView.delegate = self;
		_quoteTxtView.textAlignment = UITextAlignmentCenter;
		_quoteTxtView.keyboardType = UIKeyboardTypeDefault;
		_quoteTxtView.keyboardAppearance = UIKeyboardAppearanceAlert;
		[_quoteTxtView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_quoteTxtView setAutocorrectionType:UITextAutocorrectionTypeNo];
		[_quoteTxtView setReturnKeyType:UIReturnKeyDone];
		[_customQuoteView addSubview:_quoteTxtView];
		
		UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
		singleTapGestureRecognizer.numberOfTapsRequired = 1;
		[_quoteLabel addGestureRecognizer:singleTapGestureRecognizer];
		
		_stickerDataRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kComposerAPI]]];
		[_stickerDataRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[_stickerDataRequest setDelegate:self];
		[_stickerDataRequest startAsynchronous];
		
		UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(50.0, 400.0, 50.0, 10.0)];
		testView.backgroundColor = [UIColor greenColor];
		//[_canvasView addSubview:testView];
	}
	
	return (self);
}


- (id)initWithFrame:(CGRect)frame withFriend:(NSDictionary *)fbFriend
{
	if ((self = [self initWithFrame:frame])) {
		_fbFriend = fbFriend;
		
		NSLog(@"USER:[%@]", [_fbFriend objectForKey:@"id"]);
		
		_canvasView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 435.0)];
		_canvasView.clipsToBounds = YES;
		[self addSubview:_canvasView];
		
		EGOImageView *imgView = [[EGOImageView alloc] initWithFrame:CGRectMake(10.0, 50.0, 300.0, 300.0)];
		imgView.delegate = self;
		imgView.imageURL = [NSURL URLWithString:[_fbFriend objectForKey:@"lg_image"]];
		[_canvasView addSubview:imgView];
		
		_quoteIndex = 0;
		_stickerIndex = 0;
		_isQuote = YES;
		
		_quoteList = [NSMutableArray new];
		_stickerList = [NSMutableArray new];
		
		NSLog(@"USER:[%@]", [_fbFriend objectForKey:@"id"]);
		
		_quoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_quoteButton addTarget:self action:@selector(_goQuote) forControlEvents:UIControlEventTouchUpInside];
		_quoteButton.frame = CGRectMake(10.0, 10.0, 100.0, 48.0);
		[_quoteButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_quoteButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_quoteButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_quoteButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_quoteButton setTitle:@"Quote" forState:UIControlStateNormal];
		[self addSubview:_quoteButton];
		
		_stickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_stickerButton addTarget:self action:@selector(_goSticker) forControlEvents:UIControlEventTouchUpInside];
		_stickerButton.frame = CGRectMake(10.0, 60.0, 100.0, 48.0);
		[_stickerButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_stickerButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_stickerButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_stickerButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_stickerButton setTitle:@"Sticker" forState:UIControlStateNormal];
		[self addSubview:_stickerButton];
		
		UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[clearButton addTarget:self action:@selector(_goClear) forControlEvents:UIControlEventTouchUpInside];
		clearButton.frame = CGRectMake(10.0, 110.0, 100.0, 48.0);
		[clearButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[clearButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[clearButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		clearButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[clearButton setTitle:@"Clear" forState:UIControlStateNormal];
		[self addSubview:clearButton];

		
		UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
		submitButton.frame = CGRectMake(210.0, 380.0, 100.0, 48.0);
		[submitButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[submitButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[submitButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		submitButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[submitButton setTitle:@"Submit" forState:UIControlStateNormal];
		[self addSubview:submitButton];
		
		[_quoteList addObject:@"Euismod tincidunt ut laoreet dolore magna aliquam erat volutpat ut laoreet."];
		[_quoteList addObject:@"Et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis."];
		[_quoteList addObject:@"Accumsan dolore te feugait nulla facilisi nam liber tempor cum soluta nobis"];
		[_quoteList addObject:@"Elit sed diam nonummy nibh nostrud exerci tation ullamcorper?"];
		[_quoteList addObject:@"Eodem modo typi qui, nunc nobis videntur parum."];
		[_quoteList addObject:@"Consequat duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat vel!"];
		[_quoteList addObject:@"Litterarum formas humanitatis, per seacula quarta decima et quinta decima clari fiant sollemnes in."];
		[_quoteList addObject:@"Legunt saepius claritas est etiam processus dynamicus qui sequitur mutationem consuetudium."];
		
		CGSize size = [[_quoteList objectAtIndex:0] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(280.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		
		
		_quoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 150.0, 280.0, size.height)];
		_quoteLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
		_quoteLabel.textColor = [UIColor whiteColor];
		_quoteLabel.userInteractionEnabled = YES;
		_quoteLabel.numberOfLines = 0;
		_quoteLabel.backgroundColor = [UIColor clearColor];
		_quoteLabel.textAlignment = UITextAlignmentCenter;
		_quoteLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.67];
		_quoteLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		_quoteLabel.text = [_quoteList objectAtIndex:0];
		[_canvasView addSubview:_quoteLabel];
		
		_customQuoteView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 240.0)];
		_customQuoteView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.85];
		_customQuoteView.hidden = YES;
		[self addSubview:_customQuoteView];
		
		_quoteTxtView = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 200.0, 280.0, size.height)];
		_quoteTxtView.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
		_quoteTxtView.textColor = [UIColor whiteColor];
		_quoteTxtView.userInteractionEnabled = YES;
		_quoteTxtView.backgroundColor = [UIColor clearColor];
		_quoteTxtView.delegate = self;
		_quoteTxtView.textAlignment = UITextAlignmentCenter;
		_quoteTxtView.keyboardType = UIKeyboardTypeDefault;
		_quoteTxtView.keyboardAppearance = UIKeyboardAppearanceAlert;
		[_quoteTxtView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_quoteTxtView setAutocorrectionType:UITextAutocorrectionTypeNo];
		[_quoteTxtView setReturnKeyType:UIReturnKeyDone];
		[_customQuoteView addSubview:_quoteTxtView];
		
		UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
		singleTapGestureRecognizer.numberOfTapsRequired = 1;
		[_quoteLabel addGestureRecognizer:singleTapGestureRecognizer];
		
		_stickerDataRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kComposerAPI]]];
		[_stickerDataRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[_stickerDataRequest setDelegate:self];
		[_stickerDataRequest startAsynchronous];
		
		UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(50.0, 400.0, 50.0, 10.0)];
		testView.backgroundColor = [UIColor greenColor];
		//[_canvasView addSubview:testView];
	}
	
	return (self);
}

- (void)handleSingleTap:(UIGestureRecognizer *)tap {
	_quoteLabel.hidden = YES;
	
	_quoteTxtView.frame = CGRectMake(20.0, 20.0, _quoteLabel.frame.size.width, _quoteLabel.frame.size.height);
	_quoteTxtView.text = _quoteLabel.text;
	_customQuoteView.hidden = NO;
	
	[_quoteTxtView becomeFirstResponder];
}


#pragma mark - Navigation
- (void)_goQuote {
	_quoteIndex++;
	_isQuote = YES;
	
	NSString *caption = [_quoteList objectAtIndex:_quoteIndex % [_quoteList count]];
	CGSize size = [caption sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(280.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	_quoteLabel.frame = CGRectMake(20.0, 150.0, 280.0, size.height);
	_quoteLabel.text = caption;
}

- (void)_goSticker {
	_stickerIndex++;
	_isQuote = NO;
	
	SNStickerVO *vo = [_stickerList objectAtIndex:_stickerIndex % [_stickerList count]];
	
	CGPoint pos = _stickerImgView.frame.origin;
	
	if (pos.x == 0.0 && pos.y == 0.0)
		pos = CGPointMake(100.0, 100.0);
	
	[_stickerImgView removeFromSuperview];
	_stickerImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(pos.x, pos.y, 85.0, 85.0)];
	_stickerImgView.userInteractionEnabled = YES;
	_stickerImgView.imageURL = [NSURL URLWithString:vo.url];
	[_canvasView addSubview:_stickerImgView];
}

- (void)_goClear {
	_quoteIndex = 0;
	_stickerIndex = 0;
	
	_quoteLabel.text = @"";
	[_stickerImgView removeFromSuperview];
}


-(void)_goSubmit {
	CGSize size = [_canvasView bounds].size;
	UIGraphicsBeginImageContext(size);
	[[_canvasView layer] renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	NSData *imageData = UIImageJPEGRepresentation(newImage, 1.0);
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:@"AKIAJVS6Y36AQCMRWLQQ" withSecretKey:@"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"];
	
	@try {
		
		if (!_progressHUD) {
			_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
			_progressHUD.mode = MBProgressHUDModeIndeterminate;
			_progressHUD.taskInProgress = YES;
			_progressHUD.graceTime = 5.0;
		}
		
		
		//NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		//[formatter setDateFormat:@"yyyyMMdd_HHmmss"];
		//[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
		//NSString *filename = [NSString stringWithFormat:@"%@.jpg", [formatter stringFromDate:[NSDate date]]];
		
		NSString *filename = [NSString stringWithFormat:@"%@.jpg", [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
		NSLog(@"https://assembly-ugc.s3.amazonaws.com/%@", filename);
		
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"assembly-ugc"]];
		S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:filename inBucket:@"assembly-ugc"];
		por.contentType = @"image/jpeg";
		por.data = imageData;
		[s3 putObject:por];
		
		ASIFormDataRequest *composeSubmitRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kComposerAPI]]];
		[composeSubmitRequest setPostValue:[NSString stringWithFormat:@"%d", 0] forKey:@"action"];
		[composeSubmitRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[composeSubmitRequest setPostValue:[NSString stringWithFormat:@"https://assembly-ugc.s3.amazonaws.com/%@", filename] forKey:@"imgURL"];
		[composeSubmitRequest setDelegate:self];
		[composeSubmitRequest startAsynchronous];
	}
	
	@catch (AmazonClientException *exception) {
		[[[UIAlertView alloc] initWithTitle:@"Upload Error" message:exception.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
	
	//UIImageWriteToSavedPhotosAlbum(newImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);	
	//[self addSubview:[[UIImageView alloc] initWithImage:newImage]];
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	if (error) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to save image to Photo Album." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
	}
}


#pragma mark - ImageView Delegates
- (void)imageViewLoadedImage:(EGOImageView *)imageView {
	CGSize size = imageView.image.size;
	
	if ([imageView isEqual:_stickerImgView]) {
		imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.image.size.width, imageView.image.size.height);
	} else {
	
		CGSize ratioSize = CGSizeMake(320.0 / size.width, 435.0 / size.height);
		
		BOOL isWidthScaled = NO;
		if (ratioSize.width > ratioSize.height)
			isWidthScaled = YES;
		
		CGSize scaledSize;
		if (isWidthScaled)
			scaledSize = CGSizeMake(size.width * ratioSize.width, size.height * ratioSize.width);
		
		else
			scaledSize = CGSizeMake(size.width * ratioSize.height, size.height * ratioSize.height);
		
		
		CGPoint imgPt = CGPointZero;
		if (scaledSize.width > 320.0)
			imgPt = CGPointMake((scaledSize.width - 320.0) * -0.5, 0.0);
		
		else
			imgPt = CGPointMake((scaledSize.width - 320.0) * 0.5, 0.0);

		
		if (scaledSize.height > 435.0)
			imgPt = CGPointMake(imgPt.x, (scaledSize.height - 435.0) * -0.5);
		
		else
			imgPt = CGPointMake(imgPt.x, (scaledSize.height - 435.0) * 0.5);
		
		imageView.frame = CGRectMake(imgPt.x, imgPt.y, scaledSize.width, scaledSize.height);
	}
	
//	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[userDict objectForKey:@"image"]]];
//	NSHTTPURLResponse *response;
//	
//	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error: nil];
//	if ([response respondsToSelector:@selector(allHeaderFields)]) {
//		NSDictionary *dictionary = [response allHeaderFields];
//		//NSLog(@"%@", [dictionary description]);
//	}

}

#pragma mark - Touch controls
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	NSLog(@"BEGAN %@", [touch view]);
	
	CGPoint touchPoint = [touch locationInView:self];
	if ([touch view] == _stickerImgView) {
		_diffPt = CGPointMake(_stickerImgView.center.x - touchPoint.x, _stickerImgView.center.y - touchPoint.y);
	}
	
	if ([touch view] == _quoteLabel) {
		_diffPt = CGPointMake(_quoteLabel.center.x - touchPoint.x, _quoteLabel.center.y - touchPoint.y);
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView:self];
	CGPoint adjPt = CGPointMake(location.x + _diffPt.x, location.y + _diffPt.y);
	
	NSLog(@"MOVED %@", [touch view]);
	
	if ([touch view] == _stickerImgView) {
		_stickerImgView.center = adjPt;		
		return;
	}
	
	if ([touch view] == _quoteLabel) {
		_quoteLabel.center = CGPointMake(_quoteLabel.center.x, adjPt.y);		
		return;
	}
}

#pragma mark - TextView Delegates
- (void)textViewDidEndEditing:(UITextView *)textView {
	[textView resignFirstResponder];
	
	_quoteLabel.hidden = NO;
	_quoteLabel.text = textView.text;
	_customQuoteView.hidden = YES;
}

- (void)textViewDidChange:(UITextView *)textView {
	CGSize size = [textView.text sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(280.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	textView.frame = CGRectMake(20.0, 150.0, 280.0, size.height + 20.0);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if ([text isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
		
		return (NO);
	}
	
	else
		return (YES);
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNComposeEditorView_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	NSError *error = nil;
	if (error != nil)
		NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
	
	else {
		
		if ([request isEqual:_stickerDataRequest]) {
			NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			_stickerList = [NSMutableArray new];
			
			NSMutableArray *list = [NSMutableArray array];
			for (NSDictionary *serverList in parsedLists) {
				 SNStickerVO *vo = [SNStickerVO stickerWithDictionary:serverList];
				
				if (vo != nil)
					[list addObject:vo];
			}
			
			_stickerList = [list copy];
			
			
		} else {
			NSDictionary *parsedArticle = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			NSLog(@"ARTICLE:[%@]", parsedArticle);
			
			SNArticleVO *vo = [SNArticleVO articleWithDictionary:parsedArticle];
			[SNFacebookCaller postToTimeline:vo];
			[SNFacebookCaller postToFriendTimeline:[_fbFriend objectForKey:@"id"] article:vo];
			
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SUBMITTED" object:nil];
			
			if (_progressHUD != nil) {
				_progressHUD.taskInProgress = NO;
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
