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
#import "SNTwitterUserVO.h"
#import "SNTwitterAvatarView.h"
#import "SNAppDelegate.h"
#import "SNNavBackBtnView.h"
#import "SNNavShareBtnView.h"

#define kItemHeight 28.0

@implementation SNArticleCommentsViewController_iPhone

-(id)initWithArticleVO:(SNArticleVO *)vo {
	if ((self = [super init])) {
		_vo = vo;
		_isLiked = NO;
		
		_commentViews = [NSMutableArray new];
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/%@/%@/comments", _vo.topicTitle, _vo.title] withError:&error])
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
	bgImgView.image = [UIImage imageNamed:@"commentsBackground.png"];
	[self.view addSubview:bgImgView];
	
	_commentOffset = 0;
	for (SNCommentVO *vo in _vo.comments) {
		CGSize txtSize = [vo.content sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11] constrainedToSize:CGSizeMake(230.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		_commentOffset += ((kItemHeight + txtSize.height) - 10.0);
	}
	
	UIImageView *likesImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 44.0, 320.0, 54.0)];
	likesImgView.image = [UIImage imageNamed:@"commentsLikeHeaderBG.png"];
	[self.view addSubview:likesImgView];
	
	int offset = 37;
	for (SNTwitterUserVO *tuVO in _vo.userLikes) {
		SNTwitterAvatarView *avatarView = [[SNTwitterAvatarView alloc] initWithPosition:CGPointMake(offset, 55.0) imageURL:tuVO.avatarURL];
		[self.view addSubview:avatarView];
		offset += 31.0;
	}
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 98.0, self.view.frame.size.width, 333.0)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[_scrollView setBackgroundColor:[UIColor clearColor]];
	_scrollView.opaque = YES;
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.delegate = self;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.alwaysBounceVertical = NO;
	//_scrollView.contentInset = UIEdgeInsetsMake(5.0, 0.0, -5.0, 0.0);
	[self.view addSubview:_scrollView];
	
	_scrollBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, _scrollView.frame.size.width, _commentOffset)];
	UIImage *img = [UIImage imageNamed:@"profileBackground.png"];
	_scrollBgView.image = [img stretchableImageWithLeftCapWidth:0.0 topCapHeight:10.0];
	//[_scrollView addSubview:_scrollBgView];
	
	
	_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
	_refreshHeaderView.delegate = self;
	//[_scrollView addSubview:_refreshHeaderView];
	//[_refreshHeaderView refreshLastUpdatedDate];
	
	_bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 44.0, self.view.frame.size.width, 44.0)];
	[self.view addSubview:_bgView];
	
	UIImageView *inputBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
	inputBgImgView.image = [UIImage imageNamed:@"comentsFooterBG.png"];
	inputBgImgView.userInteractionEnabled = YES;
	[_bgView addSubview:inputBgImgView];
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:@"Comments"];
	[self.view addSubview:headerView];
	
	SNNavBackBtnView *backBtnView = [[SNNavBackBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 64.0, 44.0)];
	[[backBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backBtnView];
	
	SNNavShareBtnView *shareBtnView = [[SNNavShareBtnView alloc] initWithFrame:CGRectMake(273.0, 0.0, 44.0, 44.0)];
	[[shareBtnView btn] addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:shareBtnView];
	
//	_likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	_likeButton.frame = CGRectMake(2.0, 2.0, 44.0, 44.0);
//	[_likeButton setBackgroundImage:[UIImage imageNamed:@"commentHeart_nonActive.png"] forState:UIControlStateNormal];
//	[_likeButton setBackgroundImage:[UIImage imageNamed:@"commentHeart_Active.png"] forState:UIControlStateHighlighted];
//	[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
//	[_bgView addSubview:_likeButton];
	
	
	_commentTxtField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 15.0, 270.0, 16.0)];
	[_commentTxtField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_commentTxtField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_commentTxtField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[_commentTxtField setBackgroundColor:[UIColor clearColor]];
	[_commentTxtField setReturnKeyType:UIReturnKeyDone];
	[_commentTxtField setTextColor:[UIColor whiteColor]];
	[_commentTxtField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_commentTxtField.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	_commentTxtField.keyboardType = UIKeyboardTypeDefault;
	_commentTxtField.text = @"";
	_commentTxtField.delegate = self;
	[_bgView addSubview:_commentTxtField];
	
	_commentsLabel = [[UILabel alloc] initWithFrame:_commentTxtField.frame];
	_commentsLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	_commentsLabel.textColor = [UIColor whiteColor];
	_commentsLabel.backgroundColor = [UIColor clearColor];
	_commentsLabel.text = @"Write a comment…";
	[_bgView addSubview:_commentsLabel];
	
	_commentOffset = 0;
	for (SNCommentVO *vo in _vo.comments) {
		//NSLog(@"OFFSET:%d", offset);
		
		CGSize txtSize = [vo.content sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14] constrainedToSize:CGSizeMake(230.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		SNArticleCommentView_iPhone *commentView = [[SNArticleCommentView_iPhone alloc] initWithFrame:CGRectMake(0.0, _commentOffset, _scrollView.frame.size.width, kItemHeight + txtSize.height) commentVO:vo];
		[_commentViews addObject:commentView];
		[_scrollView addSubview:commentView];
		
		_commentOffset += ((kItemHeight + txtSize.height) + 8.0);
	}
	
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, _commentOffset);
}

-(void)viewDidLoad {
	[super viewDidLoad];
	
	[_commentTxtField becomeFirstResponder];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
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

-(void)_goShare {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHEET" object:_vo];
}

-(void)_goLike {
	_isLiked = !_isLiked;
}

- (void)_goSend {
	if ([_commentTxtField.text length] > 0)
		[self textFieldDidEndEditing:_commentTxtField];
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
	NSLog(@"%d", [textField.text length]);
	
	if ([textField.text length] > 0) {
		NSString *isLiked = @"N";
		if (_isLiked)
			isLiked = @"Y";
		
		_commentSubmitRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"]]];
		[_commentSubmitRequest setPostValue:[NSString stringWithFormat:@"%d", 9] forKey:@"action"];
		[_commentSubmitRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[_commentSubmitRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
		[_commentSubmitRequest setPostValue:textField.text forKey:@"content"];
		[_commentSubmitRequest setPostValue:isLiked forKey:@"liked"];
		[_commentSubmitRequest setDelegate:self];
		[_commentSubmitRequest startAsynchronous];
		
		NSLog(@"USER:%@, ARTICLE:%d, CONTENT:%@", [[SNAppDelegate profileForUser] objectForKey:@"id"], _vo.article_id, textField.text);
				
		textField.text = @"";
		_isLiked = NO;
	
		_commentsLabel.hidden = NO;
	}
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^(void){
		_bgView.frame = CGRectMake(_bgView.frame.origin.x, _bgView.frame.origin.y + 215.0, _bgView.frame.size.width, _bgView.frame.size.height);
	} completion:nil];
	
	_commentsLabel.hidden = NO;
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNArticleCommentsViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	NSError *error = nil;
	NSDictionary *parsedComment = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
	if (error != nil)
		NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
	
	SNCommentVO *vo = [SNCommentVO commentWithDictionary:parsedComment];
	[_vo.comments insertObject:vo atIndex:0];
	
	
	CGSize commentSize = [vo.content sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14] constrainedToSize:CGSizeMake(256.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	for (SNArticleCommentView_iPhone *commentView in _commentViews) {
		//		[UIView animateWithDuration:0.25 animations:^(void) {
			CGSize size = _scrollView.contentSize;
			size.height += (kItemHeight + commentSize.height);
			
			_scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, 387.0);
			commentView.frame = CGRectMake(commentView.frame.origin.x, commentView.frame.origin.y + (kItemHeight + commentSize.height), commentView.frame.size.width, commentView.frame.size.height);
		//		}];
	}
	
	SNArticleCommentView_iPhone *commentView = [[SNArticleCommentView_iPhone alloc] initWithFrame:CGRectMake(0.0, 0.0, _scrollView.frame.size.width, kItemHeight + commentSize.height) commentVO:vo];
	[_commentViews insertObject:commentView atIndex:0];
	[_scrollView addSubview:commentView];		
	
	_commentOffset += (kItemHeight + commentSize.height);
	_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, _commentOffset);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"COMMENT_ADDED" object:_vo];
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}


@end
