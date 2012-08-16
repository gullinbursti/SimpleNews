//
//  SNComposeSourceView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.15.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNComposeSourceView_iPhone.h"

#import "SNAppDelegate.h"

@implementation SNComposeSourceView_iPhone

#pragma mark - View Lifecycle
- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		_cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_cameraButton addTarget:self action:@selector(_goCamera) forControlEvents:UIControlEventTouchUpInside];
		_cameraButton.frame = CGRectMake(110.0, 50.0, 100.0, 48.0);
		[_cameraButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_cameraButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_cameraButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_cameraButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_cameraButton setTitle:@"Camera" forState:UIControlStateNormal];
		[self addSubview:_cameraButton];
		
		_cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
		_cameraRollButton.frame = CGRectMake(110.0, 200.0, 100.0, 48.0);
		[_cameraRollButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_cameraRollButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_cameraRollButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_cameraRollButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_cameraRollButton setTitle:@"Camera Roll" forState:UIControlStateNormal];
		[self addSubview:_cameraRollButton];
		
		_fbFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_fbFriendsButton addTarget:self action:@selector(_goFBFriends) forControlEvents:UIControlEventTouchUpInside];
		_fbFriendsButton.frame = CGRectMake(110.0, 350.0, 100.0, 48.0);
		[_fbFriendsButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_fbFriendsButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_fbFriendsButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_fbFriendsButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_fbFriendsButton setTitle:@"FB Friends" forState:UIControlStateNormal];
		[self addSubview:_fbFriendsButton];	
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goCamera {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SOURCE_CAMERA" object:nil];
		
//		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//		imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
//		imagePicker.delegate = self;
//		imagePicker.allowsEditing = YES;
//		
//		[self presentModalViewController:imagePicker animated:YES];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Camera not aviable." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alertView show];
	}
}

- (void)_goCameraRoll {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SOURCE_CAMERAROLL" object:nil];

//		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//		imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
//		imagePicker.delegate = self;
//		imagePicker.allowsEditing = YES;
//		//imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
//		
//		[self presentModalViewController:imagePicker animated:YES];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Photo roll not available." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alertView show];
	}
}

- (void)_goFBFriends {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SOURCE_FRIENDS" object:nil];
}

#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//	
//	//[picker release];
//	NSLog(@"info:[%@]", info);
//	
//	//NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
//	[self dismissModalViewControllerAnimated:YES];
//	
//	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//	[dateFormat setDateFormat:@"yyyyMMddHHmmss"];
//	_chore.imgPath = [dateFormat stringFromDate:[NSDate date]];
//	[dateFormat release];
//	
//	if (_isCameraPic) {
//		UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//		//CGRect imageRect = CGRectMake(0.0, 0.0, 206.0, 174.0);
//		CGRect imageRect = CGRectMake(0.0, 0.0, 174.0, 206.0);
//		
//		NSLog(@"%f, %f", image.size.width, image.size.height);
//		
//		UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, [UIScreen mainScreen].scale);
//		[image drawInRect:imageRect];
//		UIImage *resizedImg = UIGraphicsGetImageFromCurrentImageContext();
//		UIGraphicsEndImageContext();
//		
//		UIImageWriteToSavedPhotosAlbum(resizedImg, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);		
//		_choreImgView.image = resizedImg;
//		
//		NSData *imageData = UIImagePNGRepresentation(resizedImg);
//		[[NSUserDefaults standardUserDefaults] setObject:imageData forKey:_chore.imgPath];
//		
//	} else {
//		UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//		NSLog(@"%f, %f", image.size.width, image.size.height);
//		
//		_choreImgView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
//		
//		NSData *imageData = UIImagePNGRepresentation(image); 
//		[[NSUserDefaults standardUserDefaults] setObject:imageData forKey:_chore.imgPath];
//	}
//	
//	[self _goNext];
//	
//	NSLog(@"IMG:[%@]", _chore.imgPath);
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
//	
//	if (_isCameraPic) {
//		if (error) {
//			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to save image to Photo Album." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//			[alert show];
//			[alert release];
//		}
//		
//		//else
//		//alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Image saved to Photo Album." delegate:nil cancelButtonTitle:@"Ok"  otherButtonTitles:nil];
//	}
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	//[self dismissModalViewControllerAnimated:YES];
}


@end
