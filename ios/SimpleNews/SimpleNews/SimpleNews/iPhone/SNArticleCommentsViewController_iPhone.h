//
//  SNArticleCommentsViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.15.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "SNArticleVO.h"

@interface SNArticleCommentsViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ASIHTTPRequestDelegate>{
	SNArticleVO *_vo;
	ASIFormDataRequest *_commentSubmitRequest;
	
	UITableView *_tableView;
	UIImageView *_commentsBGImgView;
	UITextField *_commentTxtField;
	UILabel *_commentsLabel;
	UIImageView *_inputBgImgView;
	
	int _list_id;
}

-(id)initWithArticleVO:(SNArticleVO *)vo listID:(int)listID;

@end
