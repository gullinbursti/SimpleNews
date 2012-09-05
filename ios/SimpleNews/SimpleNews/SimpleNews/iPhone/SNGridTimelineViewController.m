//
//  SNGridTimelineViewController.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 09.03.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNGridTimelineViewController.h"

@implementation SNGridTimelineViewController

- (id)init {
	if ((self = [super init])) {
		
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

@end
