//
//  CameraViewController.h
//  treasuremap
//
//  Created by Wesley Leung on 3/6/13.
//  Copyright (c) 2013 Wesley Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "Parse/Parse.h"

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImage *finalImage;
}


//- (IBAction)openCamera:(id)sender;
//- (IBAction)openCameraRoll:(id)sender;




@end
