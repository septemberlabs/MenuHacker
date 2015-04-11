//
//  ABBYYClient.m
//  MenuHacker
//
//  Created by Will Smith on 4/4/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

/* TODO: What are best practices with respect to dictionary values. Should I check for nil using objectForKey before every usage? */

/*****
 
 * Save photo to phone.
 * Parse output into a tableview.
 * Allow selection of a saved photo.
 * UI to navigate around.
 * Display UI to indicate status to user.
 * Allow user to cancel operation.
 * Save passed look-ups (generated word lists and source photo).
 * Add finger photo cropping.
 
 *****/

#import "ABBYYClient.h"

#pragma mark - Constants
NSString * const baseURL = @"http://cloud.ocrsdk.com/";
NSString * const processImageURLPath = @"processImage/";
NSString * const getTaskStatusURLPath = @"getTaskStatus/";
NSString * const applicationID = @"MenuHacker";
NSString * const password = @"ID1jzRnS2PYPM3UsK5NJgaY4";

@interface ABBYYClient ()
@property (nonatomic, strong) NSMutableDictionary *task;
@end

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

- (NSDictionary *)task {
    if (!_task) {
        _task = [[NSMutableDictionary alloc] init];
    }
    return _task;
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

    //NSData *jpgRepresentation8 = UIImageJPEGRepresentation(imageToSend, 0.8);
    //NSLog(@"jpgRepresentation8 size: %lu", (unsigned long)[jpgRepresentation8 length]);
    
    NSDictionary *params = [ABBYYClient processImageURLParams];
    //NSLog(@"params: %@", [params description]);
    
    [self POST:processImageURLPath parameters:[ABBYYClient processImageURLParams]
    
                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                        [formData appendPartWithFileData:jpgRepresentation3 name:@"name.jpg" fileName:@"fileName.jpg" mimeType:@"image/jpg"];
                    }
     
                    success:^(NSURLSessionDataTask *task, id responseObject) {
                        //NSLog(@"Success: %@ ***** %@ ***** %@", task.originalRequest, task.response, responseObject);
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

// we're looking for the tag element and use its attributes to load the self.task instance variable (a dictionary).
// reference for the XML format: http://ocrsdk.com/documentation/specifications/status-codes/
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"task"]) {
        if ([attributeDict objectForKey:@"id"]) [self.task setObject:[attributeDict objectForKey:@"id"] forKey:@"id"];
        if ([attributeDict objectForKey:@"status"]) [self.task setObject:[attributeDict objectForKey:@"status"] forKey:@"status"];
        if ([attributeDict objectForKey:@"error"]) [self.task setObject:[attributeDict objectForKey:@"error"] forKey:@"error"];
        if ([attributeDict objectForKey:@"estimatedProcessingTime"]) [self.task setObject:[attributeDict objectForKey:@"estimatedProcessingTime"] forKey:@"estimatedProcessingTime"];
        if ([attributeDict objectForKey:@"resultUrl"]) [self.task setObject:[attributeDict objectForKey:@"resultUrl"] forKey:@"resultUrl"];
        if ([attributeDict objectForKey:@"description"]) [self.task setObject:[attributeDict objectForKey:@"description"] forKey:@"description"];
    }
}

// once the XML response has been fully parsed, act upon the state of the task as extracted from the elements and attributes.
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSString *status = [self.task valueForKey:@"status"];
    
    // if the task is complete
    if ([status isEqualToString:@"Completed"]) {
        NSLog(@"task complete: %@", [self.task valueForKey:@"resultUrl"]);
    }
    // if the task is in process, start the timer to check the status again once the time interval has elapsed
    else if ([status isEqualToString:@"Submitted"] || [status isEqualToString:@"Queued"] || [status isEqualToString:@"InProgress"]) {
        NSLog(@"task status: %@", status);
        [NSTimer scheduledTimerWithTimeInterval:3.0
                                         target:self
                                       selector:@selector(checkImageProcessingStatus:)
                                       userInfo:nil
                                        repeats:NO];
    }
    // any other case
    else {
        NSLog(@"task status: %@", status);
    }
}

- (void)checkImageProcessingStatus:(NSTimer *)timer
{
    NSDictionary *parameters = @{@"taskId": [self.task objectForKey:@"id"]};
    
    [self GET:getTaskStatusURLPath parameters:parameters
     
       success:^(NSURLSessionDataTask *task, id responseObject) {
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

@end