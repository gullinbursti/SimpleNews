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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_searchPulled:) name:@"SEARCH_PULLED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_searchPushed:) name:@"SEARCH_PUSHED" object:nil];
		
		[self setBackgroundColor:[UIColor redColor]];
		
		_txtField = [[[UITextField alloc] initWithFrame:CGRectMake(32, 10, 256, 16)] autorelease];
		[_txtField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_txtField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_txtField setAutocorrectionType:UITextAutocorrectionTypeNo];
		[_txtField setBackgroundColor:[UIColor whiteColor]];
		[_txtField setReturnKeyType:UIReturnKeyDone];
		[_txtField addTarget:self action:@selector(onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_txtField.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12];
		_txtField.keyboardType = UIKeyboardTypeDefault;
		_txtField.delegate = self;
		_txtField.text = @"";
		[self addSubview:_txtField];
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
	[sender resignFirstResponder];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SEARCH_ENTERED" object:nil];
}


#pragma mark - Notifications
-(void)_searchPulled:(NSNotification *)notifcation {
	[_txtField becomeFirstResponder];
}

-(void)_searchPushed:(NSNotification *)notification {
	[_txtField resignFirstResponder];
}


#pragma mark - TextField Delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return (YES);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {	
	[textField resignFirstResponder];
}

@end
