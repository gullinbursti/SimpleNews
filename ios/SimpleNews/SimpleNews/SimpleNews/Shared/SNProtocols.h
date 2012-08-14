//
//  SNProtocols.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.10.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBiOSSDK/FacebookSDK.h>


@protocol SNOGArticle<FBGraphObject>
@property (retain, nonatomic) NSString* graphID;
@property (retain, nonatomic) NSString* url;
@end

@protocol SNOGShareArticleAction<FBOpenGraphAction>
@property (retain, nonatomic) id<SNOGArticle> article;
@end
