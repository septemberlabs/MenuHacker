//
//  ABBYYClient.m
//  MenuHacker
//
//  Created by Will Smith on 4/4/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "ABBYYClient.h"

NSString * const baseURL = @"http://cloud.ocrsdk.com/";
NSString * const processImageURLPath = @"processImage/";
NSString * const applicationID = @"MenuHacker";
NSString * const password = @"ID1jzRnS2PYPM3UsK5NJgaY4";

@implementation ABBYYClient

+ (ABBYYClient *)sharedABBYYClient
{
    static ABBYYClient *_sharedABBYYClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedABBYYClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    });
    
    return _sharedABBYYClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFXMLParserResponseSerializer serializer];
        [self setAuthentication];
    }
    
    return self;
}

- (void)setAuthentication
{
    [self.requestSerializer setAuthorizationHeaderFieldWithUsername:applicationID password:password];
}

+ (NSDictionary *)processImageURLParams
{
    static NSDictionary *params;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        params = @{@"language": @"English",
                   @"profile": @"textExtraction",
                   @"imageSource": @"photo",
                   @"correctOrientation": @"true",
                   @"correctSkew": @"true",
                   @"readBarcodes": @"false",
                   @"exportFormat": @"txtUnstructured"};
    });
    return params;
}

- (void)sendImageForProcessing:(UIImage *)imageToSend
{
    NSLog(@"sendImageForProcessing called");

    NSData *pngRepresentation = UIImagePNGRepresentation(imageToSend);
    NSLog(@"pngRepresentation size: %d", [pngRepresentation length]);
    NSData *jpgRepresentation1 = UIImageJPEGRepresentation(imageToSend, 0.1);
    NSLog(@"jpgRepresentation1 size: %d", [jpgRepresentation1 length]);
    NSData *jpgRepresentation2 = UIImageJPEGRepresentation(imageToSend, 0.2);
    NSLog(@"jpgRepresentation2 size: %d", [jpgRepresentation2 length]);
    NSData *jpgRepresentation3 = UIImageJPEGRepresentation(imageToSend, 0.3);
    NSLog(@"jpgRepresentation3 size: %d", [jpgRepresentation3 length]);
    NSData *jpgRepresentation4 = UIImageJPEGRepresentation(imageToSend, 0.4);
    NSLog(@"jpgRepresentation4 size: %d", [jpgRepresentation4 length]);
    NSData *jpgRepresentation5 = UIImageJPEGRepresentation(imageToSend, 0.5);
    NSLog(@"jpgRepresentation5 size: %d", [jpgRepresentation5 length]);
    NSData *jpgRepresentation6 = UIImageJPEGRepresentation(imageToSend, 0.6);
    NSLog(@"jpgRepresentation6 size: %d", [jpgRepresentation6 length]);
    NSData *jpgRepresentation7 = UIImageJPEGRepresentation(imageToSend, 0.7);
    NSLog(@"jpgRepresentation7 size: %d", [jpgRepresentation7 length]);
    NSData *jpgRepresentation8 = UIImageJPEGRepresentation(imageToSend, 0.8);
    NSLog(@"jpgRepresentation8 size: %d", [jpgRepresentation8 length]);
    NSData *jpgRepresentation9 = UIImageJPEGRepresentation(imageToSend, 0.9);
    NSLog(@"jpgRepresentation9 size: %d", [jpgRepresentation9 length]);
    NSData *jpgRepresentation10 = UIImageJPEGRepresentation(imageToSend, 1.0);
    NSLog(@"jpgRepresentation10 size: %d", [jpgRepresentation10 length]);
    
    NSDictionary *params = [ABBYYClient processImageURLParams];
    NSLog(@"params: %@", [params description]);
    
    [self POST:processImageURLPath parameters:[ABBYYClient processImageURLParams]
    
                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                        [formData appendPartWithFileData:jpgRepresentation8 name:@"name.jpg" fileName:@"fileName.jpg" mimeType:@"image/jpg"];
                    }
     
                    success:^(NSURLSessionDataTask *task, id responseObject) {
                        NSLog(@"Success: %@ ***** %@ ***** %@", task.originalRequest, task.response, responseObject);
                        if ([responseObject isMemberOfClass:[NSXMLParser class]]) {
                            NSXMLParser *xmlParser = (NSXMLParser *)responseObject;
                            xmlParser.delegate = self;
                            [xmlParser parse];
                        }
                    }
     
                    failure:^(NSURLSessionDataTask *task, NSError *error) {
                        NSLog(@"Error: %@ ***** %@ ***** %@", task.originalRequest, task.response, error);
                   }];
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"didStartElement: %@", elementName);
    NSLog(@"attributes: %@", attributeDict);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSLog(@"didEndElement: %@", elementName);
}

@end
