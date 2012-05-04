//
//  SNListItemViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "GANTracker.h"
#import "SNListItemViewCell_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNListItemViewCell_iPhone

@synthesize listVO = _listVO;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)init {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		_avatarImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(15.0, 15.0, 37.0, 37.0)];
		_avatarImgView.layer.cornerRadius = 8.0;
		_avatarImgView.clipsToBounds = YES;
		_avatarImgView.layer.borderColor = [[UIColor colorWithWhite:0.671 alpha:1.0] CGColor];
		_avatarImgView.layer.borderWidth = 1.0;
		[self addSubview:_avatarImgView];
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 16.0, 256.0, 20.0)];
		_nameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		_nameLabel.textColor = [UIColor blackColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_nameLabel];
		
		CGSize size = [@"created by " sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12] constrainedToSize:CGSizeMake(250.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *createdLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 34.0, size.width, size.height)];
		createdLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12];
		createdLabel.textColor = [UIColor colorWithWhite:0.639 alpha:1.0];
		createdLabel.backgroundColor = [UIColor clearColor];
		createdLabel.text = @"created by ";
		[self addSubview:createdLabel];
		
		_curatorsLabel = [[UILabel alloc] initWithFrame:CGRectMake(createdLabel.frame.origin.x + size.width, 34.0, 100.0, size.height)];
		_curatorsLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		_curatorsLabel.textColor = [SNAppDelegate snLinkColor];
		_curatorsLabel.lineBreakMode = UILineBreakModeTailTruncation;
		_curatorsLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_curatorsLabel];
		
		_followingButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_followingButton.frame = CGRectMake(235.0, 12.0, 44.0, 44.0);
		[_followingButton setBackgroundImage:[UIImage imageNamed:@"followButton_nonActive.png"] forState:UIControlStateNormal];
		[_followingButton setBackgroundImage:[UIImage imageNamed:@"followButton_Active.png"] forState:UIControlStateHighlighted];
		[self addSubview:_followingButton];
		
		UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 62.0, self.frame.size.width - 60.0, 1.0)];
		lineImgView.image = [UIImage imageNamed:@"dividerLine.png"];
		lineImgView.image = [lineImgView.image stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0];
		[self addSubview:lineImgView];
	}
	
	return (self);
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}

#pragma mark - Accessors
- (void)setListVO:(SNListVO *)listVO {
	_listVO = listVO;
	
	_avatarImgView.imageURL = [NSURL URLWithString:_listVO.thumbURL];
	_nameLabel.text = [NSString stringWithFormat:@"%@", _listVO.list_name];
	_curatorsLabel.text = _listVO.curatorHandles;
	
	if (_listVO.isSubscribed) {
		[_followingButton setBackgroundImage:[UIImage imageNamed:@"followButton_Selected.png"] forState:UIControlStateNormal];
		[_followingButton addTarget:self action:@selector(_goUnsubscribe) forControlEvents:UIControlEventTouchUpInside];
	
	} else {
		[_followingButton setBackgroundImage:[UIImage imageNamed:@"followButton_nonActive.png"] forState:UIControlStateNormal];
		[_followingButton addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
	}
}


#pragma mark - Navigation
-(void)_goSubscribe {
	if (![SNAppDelegate twitterHandle]) {
		//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		//[alert show];
		
	} else {
		ASIFormDataRequest *subscribeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]];
		[subscribeRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
		[subscribeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[subscribeRequest setPostValue:[NSString stringWithFormat:@"%d", _listVO.list_id] forKey:@"listID"];
		[subscribeRequest setDelegate:self];
		[subscribeRequest startAsynchronous];
		
		[_followingButton setBackgroundImage:[UIImage imageNamed:@"followButton_Selected.png"] forState:UIControlStateNormal];
		[_followingButton removeTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		[_followingButton addTarget:self action:@selector(_goUnsubscribe) forControlEvents:UIControlEventTouchUpInside];
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackEvent:@"Following Topic" action:_listVO.list_name label:nil value:-1 withError:&error])
			NSLog(@"error in trackEvent");
	}
}

-(void)_goUnsubscribe {
	if (![SNAppDelegate twitterHandle]) {
		//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		//[alert show];
		
	} else {
		ASIFormDataRequest *subscribeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]];
		[subscribeRequest setPostValue:[NSString stringWithFormat:@"%d", 4] forKey:@"action"];
		[subscribeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[subscribeRequest setPostValue:[NSString stringWithFormat:@"%d", _listVO.list_id] forKey:@"listID"];
		[subscribeRequest setDelegate:self];
		[subscribeRequest startAsynchronous];
		
		[_followingButton setBackgroundImage:[UIImage imageNamed:@"followButton_nonActive.png"] forState:UIControlStateNormal];
		[_followingButton removeTarget:self action:@selector(_goUnsubscribe) forControlEvents:UIControlEventTouchUpInside];
		[_followingButton addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackEvent:@"Unfollowed Topic" action:_listVO.list_name label:nil value:-1 withError:&error])
			NSLog(@"error in trackEvent");
	}
}

#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	//NSLog(@"SNListItemViewCell_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_SUBSCRIBED_LIST" object:nil];
}

-(void)requestFailed:(ASIHTTPRequest *)request {
}

@end
