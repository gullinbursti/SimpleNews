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

@implementation SNComposeEditorView_iPhone

#pragma mark - View Lifecycle
- (id)initWithFrame:(CGRect)frame withFriend:(NSDictionary *)fbFriend
{
	if ((self = [super initWithFrame:frame])) {
		_fbFriend = fbFriend;
		_cnt = 0;
		_isQuote = YES;
		
		_quoteList = [NSMutableArray new];
		_stickerList = [NSMutableArray new];
		
		NSLog(@"USER:[%@]", [_fbFriend objectForKey:@"id"]);
		
		_canvasView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 435.0)];
		_canvasView.clipsToBounds = YES;
		[self addSubview:_canvasView];
		
		EGOImageView *imgView = [[EGOImageView alloc] initWithFrame:CGRectMake(10.0, 50.0, 300.0, 300.0)];
		imgView.delegate = self;
		imgView.imageURL = [NSURL URLWithString:[_fbFriend objectForKey:@"lg_image"]];
		[_canvasView addSubview:imgView];
		
		_quoteToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_quoteToggleButton addTarget:self action:@selector(_goQuoteToggle) forControlEvents:UIControlEventTouchUpInside];
		_quoteToggleButton.frame = CGRectMake(10.0, 10.0, 100.0, 48.0);
		[_quoteToggleButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_quoteToggleButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_quoteToggleButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_quoteToggleButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_quoteToggleButton setTitle:@"Quote" forState:UIControlStateNormal];
		[self addSubview:_quoteToggleButton];
		
		_stickerToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_stickerToggleButton addTarget:self action:@selector(_goStickerToggle) forControlEvents:UIControlEventTouchUpInside];
		_stickerToggleButton.frame = CGRectMake(210.0, 10.0, 100.0, 48.0);
		[_stickerToggleButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_stickerToggleButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_stickerToggleButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_stickerToggleButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_stickerToggleButton setTitle:@"Sticker" forState:UIControlStateNormal];
		[self addSubview:_stickerToggleButton];
		
		_cycleButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_cycleButton addTarget:self action:@selector(_goCycle) forControlEvents:UIControlEventTouchUpInside];
		_cycleButton.frame = CGRectMake(10.0, 380.0, 100.0, 48.0);
		[_cycleButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_cycleButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_cycleButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_cycleButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_cycleButton setTitle:@"Next" forState:UIControlStateNormal];
		[self addSubview:_cycleButton];
		
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
		
		_quoteTxtView = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 150.0, 280.0, size.height + 20.0)];
		_quoteTxtView.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
		_quoteTxtView.textColor = [UIColor whiteColor];
		//_quoteTxtView.numberOfLines = 0;
		_quoteTxtView.backgroundColor = [UIColor clearColor];
		_quoteTxtView.delegate = self;
		_quoteTxtView.textAlignment = UITextAlignmentCenter;
		_quoteTxtView.keyboardType = UIKeyboardTypeDefault;
		_quoteTxtView.keyboardAppearance = UIKeyboardAppearanceDefault;
		[_quoteTxtView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_quoteTxtView setAutocorrectionType:UITextAutocorrectionTypeNo];
		[_quoteTxtView setReturnKeyType:UIReturnKeyDone];
		//_quoteTxtView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.67];
		//_quoteTxtView.shadowOffset = CGSizeMake(1.0, 1.0);
		_quoteTxtView.text = [_quoteList objectAtIndex:0];
		[_canvasView addSubview:_quoteTxtView];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goQuoteToggle {
	_isQuote = YES;
}

- (void)_goStickerToggle {
	_isQuote = NO;
}

- (void)_goCycle {
	_cnt++;
	
	if (_isQuote) {
		NSString *caption = [_quoteList objectAtIndex:_cnt % [_quoteList count]];
		
		CGSize size = [caption sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(280.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		_quoteTxtView.frame = CGRectMake(20.0, 150.0, 280.0, size.height + 20.0);
		_quoteTxtView.text = caption;
	}
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
	
//	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[userDict objectForKey:@"image"]]];
//	NSHTTPURLResponse *response;
//	
//	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error: nil];
//	if ([response respondsToSelector:@selector(allHeaderFields)]) {
//		NSDictionary *dictionary = [response allHeaderFields];
//		//NSLog(@"%@", [dictionary description]);
//	}

}

#pragma mark - TextView Delegates
- (void)textViewDidEndEditing:(UITextView *)textView {
	[textView resignFirstResponder];
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
	NSDictionary *parsedResult = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
	
	if (error != nil)
		NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
	
	else {
		NSLog(@"RESULT:[%@]", parsedResult);
		[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SUBMITTED" object:nil];
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
