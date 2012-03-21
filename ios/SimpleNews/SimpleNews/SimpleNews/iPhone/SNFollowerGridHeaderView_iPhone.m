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
-(void)_goArticles;
-(void)_clearText;
@end

@implementation SNFollowerGridHeaderView_iPhone

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		_cursorImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 10.0, 6.0, 34.0)] autorelease];
		_cursorImgView.image = [UIImage imageNamed:@"blinkingCursor.png"];
		[self addSubview:_cursorImgView];
		
		_txtField = [[[UITextField alloc] initWithFrame:CGRectMake(20.0, 18.0, 256.0, 20.0)] autorelease];
		[_txtField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_txtField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_txtField setAutocorrectionType:UITextAutocorrectionTypeNo];
		[_txtField setBackgroundColor:[UIColor clearColor]];
		[_txtField setReturnKeyType:UIReturnKeyDone];
		[_txtField addTarget:self action:@selector(onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_txtField.font = [[SNAppDelegate snAllerFontBold] fontWithSize:16];
		_txtField.textColor = [UIColor whiteColor];
		_txtField.keyboardType = UIKeyboardTypeDefault;
		_txtField.delegate = self;
		_txtField.text = @"";
		[self addSubview:_txtField];

		_txtLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 18.0, 256.0, 20.0)];
		_txtLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:16];
		_txtLabel.textColor = [UIColor whiteColor];
		_txtLabel.backgroundColor = [UIColor clearColor];
		_txtLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_txtLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_txtLabel.text = @"Search news";
		[self addSubview:_txtLabel];
		
		_backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_backButton.frame = CGRectMake(250.0, 12.0, 64.0, 34.0);
		[_backButton setBackgroundImage:[[UIImage imageNamed:@"backButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[_backButton setBackgroundImage:[[UIImage imageNamed:@"backButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		_backButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		_backButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		_backButton.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_backButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		[_backButton setTitle:@"Back" forState:UIControlStateNormal];
		[_backButton addTarget:self action:@selector(_goArticles) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_backButton];
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
-(void)_goArticles {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_NOW_PLAYING" object:nil];
}

#pragma mark - Handlers
-(void)onTxtDoneEditing:(id)sender {
	[sender resignFirstResponder];
	
	if ([_txtField.text length] == 0)
		_txtLabel.hidden = NO;
	
	else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SEARCH_ENTERED" object:_txtField.text];
		[self performSelector:@selector(_clearText) withObject:nil afterDelay:3.5];
	}
	
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
