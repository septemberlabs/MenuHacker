//
//  ABBYYClient.h
//  MenuHacker
//
//  Created by Will Smith on 4/4/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "Constants.h"

@interface ABBYYClient : AFHTTPSessionManager <NSXMLParserDelegate>

+ (ABBYYClient *)sharedABBYYClient;
- (instancetype)initWithBaseURL:(NSURL *)url;

extern NSString * const baseURL;
extern NSString * const processImageURLPath;
+ (NSDictionary *)processImageURLParams;
extern NSString * const applicationID;
extern NSString * const password;

- (void)sendImageForProcessing:(UIImage *)imageToSend;

@end