//
//  SNProfileStatsView.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.24.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIFormDataRequest.h"

@interface SNProfileStatsView : UIView <ASIHTTPRequestDelegate> {
	UILabel *_likesLabel;
	UILabel *_commentsLabel;
	UILabel *_sharesLabel;
}

@end
