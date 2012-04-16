//
//  SNArticleCommentsViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.15.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleCommentsViewController_iPhone.h"
#import "SNArticleCommentViewCell_iPhone.h"
#import "SNReactionVO.h"
#import "SNAppDelegate.h"

@implementation SNArticleCommentsViewController_iPhone

-(id)initWithArticleVO:(SNArticleVO *)vo listID:(int)listID {
	if ((self = [super init])) {
		_vo = vo;
		_list_id = listID;
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
	
	[self.view setBackgroundColor:[UIColor colorWithWhite:0.941 alpha:1.0]];
	
	UIButton *backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	backButton.frame = CGRectMake(4.0, 4.0, 44.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(64.0, 12.0, 192.0, 24)] autorelease];
	titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:18];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.text = _vo.title;
	[self.view addSubview:titleLabel];
	
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 53.0, self.view.frame.size.width, self.view.frame.size.height - 107.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 98.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.allowsSelection = NO;
	_tableView.pagingEnabled = NO;
	_tableView.opaque = NO;
	_tableView.scrollsToTop = NO;
	_tableView.showsHorizontalScrollIndicator = NO;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.alwaysBounceVertical = NO;
	[self.view addSubview:_tableView];
	
	_inputBgImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 54.0, self.view.frame.size.width, 54.0)] autorelease];
	_inputBgImgView.image = [UIImage imageNamed:@"inputFieldBG.png"];
	_inputBgImgView.userInteractionEnabled = YES;
	[self.view addSubview:_inputBgImgView];
	
	_commentTxtField = [[[UITextField alloc] initWithFrame:CGRectMake(23.0, 21.0, 270.0, 16.0)] autorelease];
	[_commentTxtField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_commentTxtField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_commentTxtField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[_commentTxtField setBackgroundColor:[UIColor clearColor]];
	[_commentTxtField setReturnKeyType:UIReturnKeyDone];
	[_commentTxtField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_commentTxtField.font = [[SNAppDelegate snAllerFontBold] fontWithSize:12];
	_commentTxtField.keyboardType = UIKeyboardTypeDefault;
	_commentTxtField.text = @"";
	_commentTxtField.delegate = self;
	[_inputBgImgView addSubview:_commentTxtField];
	
	_commentsLabel = [[UILabel alloc] initWithFrame:_commentTxtField.frame];
	_commentsLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:12];
	_commentsLabel.textColor = [UIColor blackColor];
	_commentsLabel.backgroundColor = [UIColor clearColor];
	_commentsLabel.text = @"Comment";
	[_inputBgImgView addSubview:_commentsLabel];
	
	UIImageView *overlayImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
	[self.view addSubview:overlayImgView];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}

#pragma mark - Navigation
-(void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)_onTxtDoneEditing:(id)sender {
	[sender resignFirstResponder];
	
	//_titleLabel.text = _titleInputTxtField.text;
	//_commentLabel.text = _commentInputTxtView.text;
	
	//_holderView.hidden = NO;
	//_txtInputView.hidden = YES;
}


#pragma mark - TableView DataSource Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"numberOfRowsInSection:[%d]", [_vo.reactions count]);
	return ([_vo.reactions count]);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNArticleCommentViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNArticleCommentViewCell_iPhone cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[[SNArticleCommentViewCell_iPhone alloc] init] autorelease];
	
	cell.reactionVO = (SNReactionVO *)[_vo.reactions objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	[cell setUserInteractionEnabled:NO];
	
	return cell;	
}


#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (98.0);
}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	return (nil);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	_commentsLabel.hidden = YES;
	
	if (![SNAppDelegate twitterHandle])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^(void){
		//_scrollView.contentOffset = CGPointMake(0.0, _scrollView.contentSize.height - 250.0);
		_inputBgImgView.frame = CGRectMake(_inputBgImgView.frame.origin.x, _inputBgImgView.frame.origin.y - 215.0, _inputBgImgView.frame.size.width, _inputBgImgView.frame.size.height);
	} completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	if ([textField.text length] > 0) {
		_commentSubmitRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
		[_commentSubmitRequest setPostValue:[NSString stringWithFormat:@"%d", 9] forKey:@"action"];
		[_commentSubmitRequest setPostValue:[SNAppDelegate twitterHandle] forKey:@"handle"];
		[_commentSubmitRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
		[_commentSubmitRequest setPostValue:[NSString stringWithFormat:@"%d", _list_id] forKey:@"listID"];
		[_commentSubmitRequest setPostValue:textField.text forKey:@"content"];
		
		[_commentSubmitRequest setTimeOutSeconds:30];
		[_commentSubmitRequest setDelegate:self];
		[_commentSubmitRequest startAsynchronous];
		
		NSLog(@"USER:%d, ARTICLE:%d, LIST:%d, CONTENT:%@", 1, _vo.article_id, _list_id, textField.text);
		
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
									 @"0", @"reaction_id",
									 [SNAppDelegate twitterAvatar], @"thumb_url", 
									 [SNAppDelegate twitterHandle], @"handle", 
									 [[SNAppDelegate profileForUser] objectForKey:@"name"], @"name", 
									 [NSString stringWithFormat:@"https://twitter.com/#!/%@", [SNAppDelegate twitterHandle]], @"user_url", 
									 @"http://shelby.tv", @"reaction_url", 
									 textField.text, @"content", nil];
		SNReactionVO *vo = [SNReactionVO reactionWithDictionary:dict];
		[_vo.reactions addObject:vo];
		
		[_tableView reloadData];
		
		textField.text = @"";
	}
	
	_commentsLabel.hidden = NO;
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^(void){
		_inputBgImgView.frame = CGRectMake(_inputBgImgView.frame.origin.x, _inputBgImgView.frame.origin.y + 215.0, _inputBgImgView.frame.size.width, _inputBgImgView.frame.size.height);
	} completion:nil];
}

@end
