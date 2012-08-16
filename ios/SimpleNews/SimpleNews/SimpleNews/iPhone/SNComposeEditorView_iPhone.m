//
//  SNComposeEditorView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

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
		
		EGOImageView *imgView = [[EGOImageView alloc] initWithFrame:CGRectMake(10.0, 50.0, 300.0, 300.0)];
		imgView.delegate = self;
		imgView.imageURL = [NSURL URLWithString:[_fbFriend objectForKey:@"lg_image"]];
		[self addSubview:imgView];
		
		_cycleButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_cycleButton addTarget:self action:@selector(_goCycle) forControlEvents:UIControlEventTouchUpInside];
		_cycleButton.frame = CGRectMake(110.0, 380.0, 100.0, 48.0);
		[_cycleButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_cycleButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_cycleButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_cycleButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_cycleButton setTitle:cycleCaption forState:UIControlStateNormal];
		[self addSubview:_cycleButton];
		
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
			_quoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 150.0, 280.0, 20.0)];
			_quoteLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
			_quoteLabel.textColor = [UIColor whiteColor];
			_quoteLabel.numberOfLines = 0;
			_quoteLabel.backgroundColor = [UIColor clearColor];
			_quoteLabel.textAlignment = UITextAlignmentCenter;
			_quoteLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.67];
			_quoteLabel.shadowOffset = CGSizeMake(1.0, 1.0);
			_quoteLabel.text = [_quoteList objectAtIndex:0];
			[self addSubview:_quoteLabel];
		}
	}
	
	return (self);
}

- (void)_goCycle {
	_cnt++;
	
	if (_type == 0) {
		
	} else {
		NSString *caption = [_quoteList objectAtIndex:_cnt % [_quoteList count]];
		CGSize size = [caption sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(280.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		_quoteLabel.frame = CGRectMake(20.0, 150.0, 280.0, size.height);
		_quoteLabel.text = caption;
	}
	
}


#pragma mark - ImageView Delegates
- (void)imageViewLoadedImage:(EGOImageView *)imageView {
	CGSize size = imageView.image.size;
	
	CGSize diffSize = CGSizeMake(320.0 - size.width, 430.0 - size.height);
	//CGSize ratioSize = CG
	
	imageView.frame = CGRectMake(0.0, 60.0, size.width * 2.0, size.height * 2.0);
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

@end
