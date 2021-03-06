//
//  SNArticleCommentsViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.15.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "GANTracker.h"

#import "SNArticleCommentsViewController_iPhone.h"
#import "SNArticleCommentView_iPhone.h"
#import "SNHeaderView_iPhone.h"
#import "SNCommentVO.h"
#import "SNAppDelegate.h"
#import "SNNavBackBtnView.h"
#import "SNNavLikeBtnView.h"

#define kItemHeight 51.0

@implementation SNArticleCommentsViewController_iPhone

-(id)initWithArticleVO:(SNArticleVO *)vo listID:(int)listID {
	if ((self = [super init])) {
		_vo = vo;
		_list_id = listID;
		_isLiked = NO;
		
		_commentViews = [NSMutableArray new];
		
		if (![SNAppDelegate twitterHandle]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
		}
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/lists/%d/%@/comments", _vo.list_id, _vo.title] withError:&error])
			NSLog(@"error in trackPageview");
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)dealloc {
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_plain.png"];
	[self.view addSubview:bgImgView];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.view.frame.size.width, self.view.frame.size.height - 48.0)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[_scrollView setBackgroundColor:[UIColor clearColor]];
	_scrollView.opaque = YES;
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.delegate = self;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = YES;
	_scrollView.alwaysBounceVertical = NO;
	[self.view addSubview:_scrollView];
	
	_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
	_refreshHeaderView.delegate = self;
	[_scrollView addSubview:_refreshHeaderView];
	[_refreshHeaderView refreshLastUpdatedDate];
	
	_bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 44.0, self.view.frame.size.width, 44.0)];
	[_bgView setBackgroundColor:[UIColor colorWithWhite:0.914 alpha:1.0]];
	[self.view addSubview:_bgView];
	
	UIImageView *inputBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 49.0)];
	inputBgImgView.image = [UIImage imageNamed:@"commentsInputField_BG.png"];
	inputBgImgView.userInteractionEnabled = YES;
	[_bgView addSubview:inputBgImgView];
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:@"Comments"];
	[self.view addSubview:headerView];
	
	SNNavBackBtnView *backBtnView = [[SNNavBackBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
	[[backBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backBtnView];
	
	SNNavLikeBtnView *likeBtnView = [[SNNavLikeBtnView alloc] initWithFrame:CGRectMake(276.0, 0.0, 44.0, 44.0)];
	[[likeBtnView btn] addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:likeBtnView];
	
	_commentTxtField = [[UITextField alloc] initWithFrame:CGRectMake(25.0, 18.0, 270.0, 16.0)];
	[_commentTxtField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_commentTxtField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_commentTxtField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[_commentTxtField setBackgroundColor:[UIColor clearColor]];
	[_commentTxtField setReturnKeyType:UIReturnKeyDone];
	[_commentTxtField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_commentTxtField.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	_commentTxtField.keyboardType = UIKeyboardTypeDefault;
	_commentTxtField.text = @"";
	_commentTxtField.delegate = self;
	[_bgView addSubview:_commentTxtField];
	
	_commentsLabel = [[UILabel alloc] initWithFrame:_commentTxtField.frame];
	_commentsLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	_commentsLabel.textColor = [UIColor blackColor];
	_commentsLabel.backgroundColor = [UIColor clearColor];
	_commentsLabel.text = @"Add Comment";
	[_bgView addSubview:_commentsLabel];
	
	_commentOffset = 0;
	for (SNCommentVO *vo in _vo.comments) {
		//NSLog(@"OFFSET:%d", offset);
		
		CGSize txtSize = [vo.content sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14] constrainedToSize:CGSizeMake(230.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		SNArticleCommentView_iPhone *commentView = [[SNArticleCommentView_iPhone alloc] initWithFrame:CGRectMake(0.0, _commentOffset, _scrollView.frame.size.width, kItemHeight + txtSize.height) commentVO:vo listID:_list_id];
		[_commentViews addObject:commentView];
		[_scrollView addSubview:commentView];
		
		if (vo.isLiked)
			_commentOffset += 30;
		
		_commentOffset += (kItemHeight + txtSize.height);
	}
	
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, _commentOffset);
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}


- (void)reloadTableViewDataSource {
	_reloading = YES;
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
//	_updateRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
//	[_updateRequest setPostValue:[NSString stringWithFormat:@"%d", 4] forKey:@"action"];
//	[_updateRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
//	[_updateRequest setPostValue:[dateFormat stringFromDate:((SNArticleVO *)[_articles objectAtIndex:0]).added] forKey:@"datetime"];
//	[_updateRequest setDelegate:self];
//	[_updateRequest startAsynchronous];
	
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.33];
}

- (void)doneLoadingTableViewData {
	_reloading = NO;
	
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
}


#pragma mark - Navigation
-(void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

//-(void)_goReport {
//	if ([MFMailComposeViewController canSendMail]) {
//		MFMailComposeViewController *mfViewController = [[MFMailComposeViewController alloc] init];
//		mfViewController.mailComposeDelegate = self;
//		[mfViewController setToRecipients:[NSArray arrayWithObject:@"abuse@getassembly.com"]];
//		[mfViewController setSubject:[NSString stringWithFormat:@"Report Abuse - %@", _vo.title]];
//		[mfViewController setMessageBody:@"There's inappropriate comments in this article." isHTML:NO];
//		
//		[self presentViewController:mfViewController animated:YES completion:nil];
//		
//	} else {
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status:" message:@"Your phone is not currently configured to send mail." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//		[alert show];
//	}
//}

-(void)_goLike {
	_isLiked = YES;
}

-(void)_goReadLater {
	
}

-(void)_goShare {
	
}

-(void)_onTxtDoneEditing:(id)sender {
	[sender resignFirstResponder];
	
	//_titleLabel.text = _titleInputTxtField.text;
	//_commentLabel.text = _commentInputTxtView.text;
	
	//_holderView.hidden = NO;
	//_txtInputView.hidden = YES;
}

#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}


// called on start of dragging (may require some time and or distance to move)
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}


// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


// called on finger up as we are moving
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
}

// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
}

// called when scroll view grinds to a halt
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}


#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
	return _reloading; // should return if data source model is reloading
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
	return [NSDate date]; // should return date data source was last change	
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	_commentsLabel.hidden = YES;
	
	if (![SNAppDelegate twitterHandle])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^(void){
		//_scrollView.contentOffset = CGPointMake(0.0, _scrollView.contentSize.height - 250.0);
		_bgView.frame = CGRectMake(_bgView.frame.origin.x, _bgView.frame.origin.y - 215.0, _bgView.frame.size.width, _bgView.frame.size.height);
	} completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	if ([textField.text length] > 0) {
		NSString *isLiked = @"N";
		if (_isLiked)
			isLiked = @"Y";
		
		_commentSubmitRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
		[_commentSubmitRequest setPostValue:[NSString stringWithFormat:@"%d", 9] forKey:@"action"];
		[_commentSubmitRequest setPostValue:[SNAppDelegate twitterHandle] forKey:@"handle"];
		[_commentSubmitRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
		[_commentSubmitRequest setPostValue:[NSString stringWithFormat:@"%d", _list_id] forKey:@"listID"];
		[_commentSubmitRequest setPostValue:isLiked forKey:@"liked"];
		[_commentSubmitRequest setPostValue:textField.text forKey:@"content"];
		[_commentSubmitRequest setDelegate:self];
		[_commentSubmitRequest startAsynchronous];
		
		NSLog(@"USER:%d, ARTICLE:%d, LIST:%d, CONTENT:%@", 1, _vo.article_id, _list_id, textField.text);
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		//[dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
		NSString *added = [dateFormatter stringFromDate:[NSDate date]];
		
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
									 @"0", @"comment_id",
									 [SNAppDelegate twitterAvatar], @"thumb_url", 
									 [SNAppDelegate twitterHandle], @"handle", 
									 [[SNAppDelegate profileForUser] objectForKey:@"name"], @"name", 
									 [NSString stringWithFormat:@"https://twitter.com/#!/%@", [SNAppDelegate twitterHandle]], @"user_url", 
									 @"", @"comment_url", 
									 added, @"added",  
									 textField.text, @"content", 
									 isLiked, @"liked", nil];
		SNCommentVO *vo = [SNCommentVO commentWithDictionary:dict];
		[_vo.comments insertObject:vo atIndex:0];
		
		CGSize commentSize = [textField.text sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14] constrainedToSize:CGSizeMake(256.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		for (SNArticleCommentView_iPhone *commentView in _commentViews) {
			[UIView animateWithDuration:0.25 animations:^(void) {
				commentView.frame = CGRectMake(commentView.frame.origin.x, commentView.frame.origin.y + kItemHeight + commentSize.height, commentView.frame.size.width, commentView.frame.size.height);
			
			} completion:nil];
		}
		
		SNArticleCommentView_iPhone *commentView = [[SNArticleCommentView_iPhone alloc] initWithFrame:CGRectMake(0.0, 0.0, _scrollView.frame.size.width, kItemHeight + commentSize.height) commentVO:vo listID:_list_id];
		[_commentViews insertObject:commentView atIndex:0];
		[_scrollView addSubview:commentView];		
		
		_commentOffset += (kItemHeight + commentSize.height);
		
		textField.text = @"";
		_isLiked = NO;
		
		CGSize size = _scrollView.contentSize;
		size.height += (kItemHeight + commentSize.height);
		_scrollView.contentSize = size;
	}
	
	_commentsLabel.hidden = NO;
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^(void){
		_bgView.frame = CGRectMake(_bgView.frame.origin.x, _bgView.frame.origin.y + 215.0, _bgView.frame.size.width, _bgView.frame.size.height);
	} completion:nil];
}


#pragma mark - MailComposeViewController Delegates
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status:" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
	
	switch (result) {
		case MFMailComposeResultCancelled:
			alert.message = @"Message Canceled";
			break;
			
		case MFMailComposeResultSaved:
			alert.message = @"Message Saved";
			[alert show];
			break;
			
		case MFMailComposeResultSent:
			alert.message = @"Message Sent";
			break;
			
		case MFMailComposeResultFailed:
			alert.message = @"Message Failed";
			[alert show];
			break;
			
		default:
			alert.message = @"Message Not Sent";
			[alert show];
			break;
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}


@end
