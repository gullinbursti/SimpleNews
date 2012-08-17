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
- (id)initWithFrame:(CGRect)frame withFriend:(NSDictionary *)fbFriend withType:(int)type
{
	if ((self = [super initWithFrame:frame])) {
		_fbFriend = fbFriend;
		_type = type;
		_cnt = 0;
		
		_quoteList = [NSMutableArray new];
		_stickerList = [NSMutableArray new];
		
		NSLog(@"USER:[%@]", [_fbFriend objectForKey:@"id"]);
		
		NSString *cycleCaption = (_type == 0) ? @"Next Sticker" : @"Next Quote";
		
		_canvasView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.frame.size.height)];
		[self addSubview:_canvasView];
		
		EGOImageView *imgView = [[EGOImageView alloc] initWithFrame:CGRectMake(10.0, 50.0, 300.0, 300.0)];
		imgView.delegate = self;
		imgView.imageURL = [NSURL URLWithString:[_fbFriend objectForKey:@"lg_image"]];
		[_canvasView addSubview:imgView];
		
		_cycleButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_cycleButton addTarget:self action:@selector(_goCycle) forControlEvents:UIControlEventTouchUpInside];
		_cycleButton.frame = CGRectMake(10.0, 380.0, 100.0, 48.0);
		[_cycleButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_cycleButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_cycleButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_cycleButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_cycleButton setTitle:cycleCaption forState:UIControlStateNormal];
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
		
		if (_type == 0) {
		
		} else {
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
			/*
			_quoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 150.0, 280.0, size.height)];
			_quoteLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
			_quoteLabel.textColor = [UIColor whiteColor];
			_quoteLabel.numberOfLines = 0;
			_quoteLabel.backgroundColor = [UIColor clearColor];
			_quoteLabel.textAlignment = UITextAlignmentCenter;
			_quoteLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.67];
			_quoteLabel.shadowOffset = CGSizeMake(1.0, 1.0);
			_quoteLabel.text = [_quoteList objectAtIndex:0];
			[_canvasView addSubview:_quoteLabel];
			 */
		}
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goCycle {
	_cnt++;
	
	if (_type == 0) {
		
	} else {
		NSString *caption = [_quoteList objectAtIndex:_cnt % [_quoteList count]];
		CGSize size = [caption sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(280.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		_quoteLabel.frame = CGRectMake(20.0, 150.0, 280.0, size.height);
		_quoteLabel.text = caption;
		
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
	
	// Convert the image to JPEG data.
	NSData *imageData = UIImageJPEGRepresentation(newImage, 1.0);
	
	// Initial the S3 Client.
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:@"AKIAJVS6Y36AQCMRWLQQ" withSecretKey:@"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"];
	
	@try {
		
		//NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		//[formatter setDateFormat:@"yyyyMMdd_HHmmss"];
		//[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
		//NSString *filename = [NSString stringWithFormat:@"%@.jpg", [formatter stringFromDate:[NSDate date]]];
		
		NSString *filename = [NSString stringWithFormat:@"%@.jpg", [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
		NSLog(@"https://assembly-ugc.s3.amazonaws.com/%@", filename);
		
		// Create the picture bucket.
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"assembly-ugc"]];
		
		// Upload image data.  Remember to set the content type.
		S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:filename inBucket:@"assembly-ugc"];
		por.contentType = @"image/jpeg";
		por.data = imageData;
		
		// Put the image data into the specified s3 bucket and object.
		[s3 putObject:por];
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
	
	NSLog(@"SCALED SIZE(%f, %f)", scaledSize.width, scaledSize.height);
	NSLog(@"SCALED POS(%f, %f)", imgPt.x, imgPt.y);
	
	imageView.frame = CGRectMake(imgPt.x, imgPt.y, scaledSize.width, scaledSize.height);
	//imageView.frame = CGRectMake(160.0 - (size.width * 0.5), 25.0 + (240.0 - (size.height * 0.5)), size.width, size.height);
	
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
//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
//- (void)textViewDidBeginEditing:(UITextView *)textView;
//- (BOOL)textViewShouldEndEditing:(UITextView *)textView;

- (void)textViewDidEndEditing:(UITextView *)textView {
	[textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if ([text isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
		
		return (NO);
	}
	
	else
		return (YES);
}
//- (void)textViewDidChange:(UITextView *)textView;
//
//- (void)textViewDidChangeSelection:(UITextView *)textView;

@end
