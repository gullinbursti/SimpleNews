//
//  SNTwitterCaller.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.24.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>


@interface SNTwitterCaller : NSObject

+(SNTwitterCaller *) sharedInstance;
-(void)userTimeline;

@property (strong, nonatomic) ACAccountStore *accountStore; 
@property (strong, nonatomic) NSArray *accounts;
@property (strong, nonatomic) ACAccount *account;
@property (strong, nonatomic) id timeline;
@end
