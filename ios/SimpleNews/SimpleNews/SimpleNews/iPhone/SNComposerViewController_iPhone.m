//
//  SNComposerViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.14.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <FBiOSSDK/FacebookSDK.h>
#import "EGOImageView.h"

#import "SNComposerViewController_iPhone.h"
#import "SNAppDelegate.h"

#import "SNHeaderView_iPhone.h"
#import "SNNavDoneBtnView.h"

@implementation SNComposerViewController_iPhone

- (id)initWithArticleVO:(SNArticleVO *)vo
{
	if ((self = [super init])) {
		_vo = vo;
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)loadView
{
	[super loadView];
	[self.view setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.85]];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_timeline.png"];
	//[self.view addSubview:bgImgView];
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:@"Composer"];
	[self.view addSubview:headerView];	
	
	SNNavDoneBtnView *doneBtnView = [[SNNavDoneBtnView alloc] initWithFrame:CGRectMake(256.0, 0.0, 64.0, 44.0)];
	[[doneBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:doneBtnView];
	
	_stickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_stickerButton addTarget:self action:@selector(_goSticker) forControlEvents:UIControlEventTouchUpInside];
	_stickerButton.frame = CGRectMake(30.0, 250.0, 100.0, 48.0);
	[_stickerButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
	[_stickerButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
	[_stickerButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	_stickerButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	[_stickerButton setTitle:@"Sticker" forState:UIControlStateNormal];
	[self.view addSubview:_stickerButton];
	
	_quoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_quoteButton addTarget:self action:@selector(_goQuote) forControlEvents:UIControlEventTouchUpInside];
	_quoteButton.frame = CGRectMake(190.0, 250.0, 100.0, 48.0);
	[_quoteButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
	[_quoteButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
	[_quoteButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	_quoteButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	[_quoteButton setTitle:@"Quote" forState:UIControlStateNormal];
	[self.view addSubview:_quoteButton];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Navigation
-(void)_goBack {
	[self dismissModalViewControllerAnimated:NO];
}

- (void)_goSticker {
	_isQuoteType = NO;
	
	[_stickerButton setHidden:YES];
	[_quoteButton setHidden:YES];
	
	_cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_cameraButton addTarget:self action:@selector(_goCamera) forControlEvents:UIControlEventTouchUpInside];
	_cameraButton.frame = CGRectMake(110.0, 50.0, 100.0, 48.0);
	[_cameraButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
	[_cameraButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
	[_cameraButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	_cameraButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	[_cameraButton setTitle:@"Camera" forState:UIControlStateNormal];
	[self.view addSubview:_cameraButton];
	
	_cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
	_cameraRollButton.frame = CGRectMake(110.0, 200.0, 100.0, 48.0);
	[_cameraRollButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
	[_cameraRollButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
	[_cameraRollButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	_cameraRollButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	[_cameraRollButton setTitle:@"Camera Roll" forState:UIControlStateNormal];
	[self.view addSubview:_cameraRollButton];
	
	_fbFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_fbFriendsButton addTarget:self action:@selector(_goFBFriends) forControlEvents:UIControlEventTouchUpInside];
	_fbFriendsButton.frame = CGRectMake(110.0, 350.0, 100.0, 48.0);
	[_fbFriendsButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
	[_fbFriendsButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
	[_fbFriendsButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	_fbFriendsButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	[_fbFriendsButton setTitle:@"FB Friends" forState:UIControlStateNormal];
	[self.view addSubview:_fbFriendsButton];
}

-(void)_goQuote {
	_isQuoteType = YES;
	
	[_stickerButton setHidden:YES];
	[_quoteButton setHidden:YES];
	
	_cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_cameraButton addTarget:self action:@selector(_goCamera) forControlEvents:UIControlEventTouchUpInside];
	_cameraButton.frame = CGRectMake(110.0, 140.0, 100.0, 48.0);
	[_cameraButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
	[_cameraButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
	[_cameraButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	_cameraButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	[_cameraButton setTitle:@"Camera" forState:UIControlStateNormal];
	[self.view addSubview:_cameraButton];
	
	_cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
	_cameraRollButton.frame = CGRectMake(110.0, 240.0, 100.0, 48.0);
	[_cameraRollButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
	[_cameraRollButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
	[_cameraRollButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	_cameraRollButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	[_cameraRollButton setTitle:@"Camera Roll" forState:UIControlStateNormal];
	[self.view addSubview:_cameraRollButton];
	
	_fbFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_fbFriendsButton addTarget:self action:@selector(_goFBFriends) forControlEvents:UIControlEventTouchUpInside];
	_fbFriendsButton.frame = CGRectMake(110.0, 340.0, 100.0, 48.0);
	[_fbFriendsButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
	[_fbFriendsButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
	[_fbFriendsButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	_fbFriendsButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	[_fbFriendsButton setTitle:@"FB Friends" forState:UIControlStateNormal];
	[self.view addSubview:_fbFriendsButton];
}


- (void)_goCamera {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		_isCameraPic = YES;
		
		//[_previewImageController.view removeFromSuperview];
		
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
		imagePicker.delegate = self;
		imagePicker.allowsEditing = YES;
		//imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
		
		[self presentModalViewController:imagePicker animated:YES];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Camera not aviable." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alertView show];
	}
}

- (void)_goCameraRoll {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		_isCameraPic = NO;
		
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
		imagePicker.delegate = self;
		imagePicker.allowsEditing = YES;
		//imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
		
		[self presentModalViewController:imagePicker animated:YES];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Photo roll not available." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alertView show];
	}
}

- (void)_goFBFriends {
	if (FBSession.activeSession.isOpen) {
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:@"2012-08-01T00%3A00%3A00%2B0000" forKey:@"since"];
		
		[FBRequest startWithGraphPath:@"me/home" parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
			_fbHomeFeed = (NSDictionary *)result;
			
			//NSLog(@"data\n%@", (NSArray *)[_fbHomeFeed objectForKey:@"data"]);
			
			[_cameraButton setHidden:YES];
			[_cameraRollButton setHidden:YES];
			[_fbFriendsButton setHidden:YES];
			
			NSMutableArray *photos = [NSMutableArray new];
			
			for (NSDictionary *entry in (NSArray *)[_fbHomeFeed objectForKey:@"data"]) {
				//NSLog(@"PHOTO:%@\n[%@]\n\n", [entry objectForKey:@"story"], [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", [[entry objectForKey:@"from"] objectForKey:@"id"]]);
				
				NSString *fromID = [[entry objectForKey:@"from"] objectForKey:@"id"];
				NSString *fromName = [[entry objectForKey:@"from"] objectForKey:@"name"];
				NSString *profileImgURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", fromID];
				
				BOOL isFound = NO;
				for (NSDictionary *test in photos) {
					if ([[test objectForKey:@"id"] isEqualToString:fromID])
						isFound = YES;
				}
				
				if (!isFound)
					[photos addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:fromID, fromName, profileImgURL, nil] forKeys:[NSArray arrayWithObjects:@"id", @"name", @"image", nil]]];
				
//				if ([[entry objectForKey:@"link"] rangeOfString:@"http://www.facebook.com/photo.php"].location != NSNotFound) {
//					NSString *photoURL = [[entry objectForKey:@"picture"] stringByReplacingOccurrencesOfString:@"_s.jpg" withString:@"_n.jpg"];
//					
//					if ([photoURL length] > 0) {
//						row = cnt / 3;
//						col = cnt % 3;
//						
//						
//						cnt++;
//						NSLog(@"PHOTO:%@\n[%@]\n\n", [entry objectForKey:@"story"], photoURL);
//						[photos addObject:entry];
//						
//						EGOImageView *imgView = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0 + (col * 85.0), 50.0 + (row * 65.0), 80.0, 60.0)];
//						[imgView setImageURL:[NSURL URLWithString:photoURL]];
//						
//						[self.view addSubview:imgView];
//					}
//				}
				
				int row = 0;
				int col = 0;
				int cnt = 0;
				for (NSDictionary *dict in photos) {
					row = cnt / 4;
					col = cnt % 4;
					
					EGOImageView *imgView = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0 + (col * 65.0), 50.0 + (row * 65.0), 60.0, 60.0)];
					[imgView setImageURL:[NSURL URLWithString:[dict objectForKey:@"image"]]];
					[imgView setDelegate:self];
					
					NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[dict objectForKey:@"image"]]];
					NSHTTPURLResponse *response;
					[NSURLConnection sendSynchronousRequest: request returningResponse: &response error: nil];
					if ([response respondsToSelector:@selector(allHeaderFields)]) {
						NSDictionary *dictionary = [response allHeaderFields];
						NSLog([dictionary description]);
					}
					
					[self.view addSubview:imgView];
					cnt++;
				}
			}
		}];
	}
}

#pragma mark - ImageViewDelegates
- (void)imageViewLoadedImage:(EGOImageView *)imageView {
	NSLog(@"%@", imageView.imageURL);
}

@end
