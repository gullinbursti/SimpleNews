//
//  SNFollowerGridHeaderView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNFollowerGridHeaderView_iPhone.h"
#import "SNAppDelegate.h"

@interface SNFollowerGridHeaderView_iPhone()
-(void)_goNowPlaying;
-(void)_clearText;
@end

@implementation SNFollowerGridHeaderView_iPhone

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		_cursorImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 8.0, 44.0)] autorelease];
		_cursorImgView.image = [UIImage imageNamed:@"blinkingCursor.png"];
		[self addSubview:_cursorImgView];
		
		_txtField = [[[UITextField alloc] initWithFrame:CGRectMake(32, 15, 256, 20)] autorelease];
		[_txtField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_txtField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_txtField setAutocorrectionType:UITextAutocorrectionTypeNo];
		[_txtField setBackgroundColor:[UIColor clearColor]];
		[_txtField setReturnKeyType:UIReturnKeyDone];
		[_txtField addTarget:self action:@selector(onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_txtField.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
		_txtField.textColor = [UIColor whiteColor];
		_txtField.keyboardType = UIKeyboardTypeDefault;
		_txtField.delegate = self;
		_txtField.text = @"";
		[self addSubview:_txtField];
		
		_txtLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 15, 256, 20)];
		_txtLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
		_txtLabel.textColor = [UIColor whiteColor];
		_txtLabel.backgroundColor = [UIColor clearColor];
		_txtLabel.text = @"Search news video";
		[self addSubview:_txtLabel];
		
		_nowPlayingButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_nowPlayingButton.frame = CGRectMake(215.0, 4.0, 100.0, 44.0);
		[_nowPlayingButton setBackgroundImage:[[UIImage imageNamed:@"genericButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:22.0] forState:UIControlStateNormal];
		[_nowPlayingButton setBackgroundImage:[[UIImage imageNamed:@"genericButton_active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:22.0] forState:UIControlStateHighlighted];
		_nowPlayingButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		_nowPlayingButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[_nowPlayingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		_nowPlayingButton.titleLabel.shadowColor = [UIColor blackColor];
		_nowPlayingButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		[_nowPlayingButton setTitle:@"now playing" forState:UIControlStateNormal];
		[_nowPlayingButton addTarget:self action:@selector(_goNowPlaying) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_nowPlayingButton];
	}
	
	return (self);
}

-(void)dealloc {
	[_cursorImgView release];
	[_txtField release];
	[_txtLabel release];
	
	[super dealloc];
}

-(void)_clearText {
	_txtField.text = @"";
	_txtLabel.hidden = NO;
}


#pragma mark - Navigation
-(void)_goNowPlaying {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_NOW_PLAYING" object:nil];
}

#pragma mark - Handlers
-(void)onTxtDoneEditing:(id)sender {
	if ([_txtField.text length] == 0)
		_txtLabel.hidden = NO;
	
	else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SEARCH_ENTERED" object:_txtField.text];
		[self performSelector:@selector(_clearText) withObject:nil afterDelay:3.5];
	}
	
	[sender resignFirstResponder];
}


#pragma mark - TextField Delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([textField.text length] == 0)
		_txtLabel.hidden = YES;
	
	return (YES);
}


-(void)textFieldDidBeginEditing:(UITextField *)textField {
	_txtLabel.hidden = YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	if ([textField.text length] == 0) {
		_txtLabel.hidden = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SEARCH_CANCELED" object:nil];
	}
}



@end
