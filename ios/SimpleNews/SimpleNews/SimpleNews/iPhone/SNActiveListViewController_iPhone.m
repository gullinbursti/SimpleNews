//
//  SNActiveListViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNActiveListViewController_iPhone.h"
#import "SNVideoItemVO.h"

#import "EGOImageView.h"

@implementation SNActiveListViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_itemTapped:) name:@"ITEM_TAPPED" object:nil];
		
		_items = [[NSMutableArray alloc] init];
		self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 75);
		self.view.clipsToBounds = YES;
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)dealloc {
	[super dealloc];
}


#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	self.view.alpha = 0.67;
	
	for (int i=0; i<3; i++) {
		EGOImageView *imgView = [[[EGOImageView alloc] initWithFrame:CGRectMake(0.0, i * 75, self.view.frame.size.width, 75.0)] autorelease];
		
		if (i == 0)
			[imgView setBackgroundColor:[UIColor greenColor]];
		
		else if (i == 1)
			[imgView setBackgroundColor:[UIColor redColor]];
		
		else
			[imgView setBackgroundColor:[UIColor blueColor]];
		
		[_items addObject:imgView];
		[self.view addSubview:imgView];
	}
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}



#pragma mark - Notification handlers
-(void)_itemTapped:(NSNotification *)notification {
	SNVideoItemVO *vo = (SNVideoItemVO *)[notification object];
	
	EGOImageView *imgView = (EGOImageView *)[_items objectAtIndex:0];
	imgView.imageURL = [NSURL URLWithString:vo.image_url];
}


@end
