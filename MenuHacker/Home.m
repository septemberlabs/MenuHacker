//
//  Home.m
//  MenuHacker
//
//  Created by Will Smith on 4/3/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "Home.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "ABBYYClient.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface Home ()
@end

@implementation Home

/*
 
 TODO: If taking pictures or movies is essential to your app, specify that by configuring the UIRequiredDeviceCapabilities key in your app’s Info.plist property list file. See UIRequiredDeviceCapabilities in Information Property List Key Reference for the various camera characteristics you can specify as required.
 
 If capturing media is incidental to your app—that is, if your app remains useful even if the device doesn’t have a camera—then your code should follow an alternate path when running on a device without a camera.
 
 */


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)launchCamera:(id)sender {
    [self startCameraControllerFromViewController:self usingDelegate:self];
}

- (BOOL) startCameraControllerFromViewController:(UIViewController*)controller usingDelegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate
{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil)) {

        /** TODO: better communication here, for example tell the user the camera is unavailable **/
        return NO;
    }

    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];

    // other possibilities here include the user's photo library or Cameral Roll
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;

    // We're just allowing photos, no videos.
    cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    
    // Hides the controls for moving & scaling pictures, or for trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentViewController:cameraUI animated:YES completion:^(void){ NSLog(@"camera opened"); }];

    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^(void){ NSLog(@"didFinishPickingMediaWithInfo"); }];
    NSLog(@"image picker dump: %@", [info description]);
    
    // if the UIImagePickerControllerEditedImage key exists, we use that image in case the user made edits. (this key will exist if the edit controls were visible whether or not the user actually made any edits.)
    if ([info objectForKey:@"UIImagePickerControllerEditedImage"]) {
        if ([info[@"UIImagePickerControllerEditedImage"] isMemberOfClass:[UIImage class]]) {
            UIImage *photo = (UIImage *)info[@"UIImagePickerControllerEditedImage"];
            [[ABBYYClient sharedABBYYClient] sendImageForProcessing:photo];
        }
    }
    // otherwise we use the original image
    else {
        if ([info[@"UIImagePickerControllerOriginalImage"] isMemberOfClass:[UIImage class]]) {
            UIImage *photo = (UIImage *)info[@"UIImagePickerControllerOriginalImage"];
            [[ABBYYClient sharedABBYYClient] sendImageForProcessing:photo];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^(void){ NSLog(@"imagePickerControllerDidCancel"); }];
}

@end
