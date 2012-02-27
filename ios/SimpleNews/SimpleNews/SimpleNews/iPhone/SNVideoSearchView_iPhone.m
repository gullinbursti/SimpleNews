//
//  SNVideoSearchView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.22.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoSearchView_iPhone.h"

#import "SNAppDelegate.h"

@implementation SNVideoSearchView_iPhone

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self setBackgroundColor:[UIColor blackColor]];
		
		_cursorImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 5, 5, 43)] autorelease];
		_cursorImgView.image = [UIImage imageNamed:@"cursorBlink.png"];
		//[self addSubview:_cursorImgView];
		
		_txtField = [[[UITextField alloc] initWithFrame:CGRectMake(32, 15, 256, 20)] autorelease];
		[_txtField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_txtField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_txtField setAutocorrectionType:UITextAutocorrectionTypeNo];
		[_txtField setBackgroundColor:[UIColor blackColor]];
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
	}
	
	return (self);
}


-(void)showMe {
	[_txtField becomeFirstResponder];
}

-(void)hideMe {
	[_txtField resignFirstResponder];
}


#pragma mark - Handlers
-(void)onTxtDoneEditing:(id)sender {
	if ([_txtField.text length] == 0)
		_txtLabel.hidden = NO;
	
	[sender resignFirstResponder];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SEARCH_ENTERED" object:nil];
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
	if ([textField.text length] == 0)
		_txtLabel.hidden = NO;
	
	[textField resignFirstResponder];
}

@end
