//
//  CameraViewController.m
//  treasuremap
//
//  Created by Wesley Leung on 3/6/13.
//  Copyright (c) 2013 Wesley Leung. All rights reserved.
//

#import "CameraViewController.h"


@interface CameraViewController ()


@property (weak, nonatomic) UILabel *photoNotes;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;


@end

@implementation CameraViewController

@synthesize imageView;


//- (IBAction)openCamera:(id)sender {
//    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        
//        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//        
//        imagePicker.delegate = self;
//        
//        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
//        
//        imagePicker.allowsEditing = NO;
//        [self presentViewController: imagePicker
//                           animated: YES completion:nil];
//        _newMedia = YES;
//        
//    }
//}

- (IBAction)photoTapped:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Password" message:@"Enter your password:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    UITextField *passwordTextField = [alertView textFieldAtIndex:0];
    [alertView show];
    
    
}

- (IBAction)openCameraRoll:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
    }
}


#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    finalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.imageView setImage:finalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    

//      NSString *mediaType = info[UIImagePickerControllerMediaType];
//    
//    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
//        UIImage *image = info[UIImagePickerControllerOriginalImage];
//        
//      
//        
//        [self.imageView setImage:image];
//        _imageView.image = image;
//        
//        [self performSegueWithIdentifier: @"Show Photo" sender: self];
//        
//
//        //if new, save to photo album;
////        if (_newMedia) {
////            UIImageWriteToSavedPhotosAlbum(image,
////                                           self,
////                                           @selector(image:finishedSavingWithError:contextInfo:),
////                                           nil);
////        }
//        //load the next view
//        
//    
//        
//        //
//    }

}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}


//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return self.imageView;
//}


-(void)openCamera {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            
//            imagePicker.delegate = self;
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
            
            imagePicker.allowsEditing = NO;
            [imagePicker setDelegate:self];
            [self presentViewController: imagePicker
                               animated: YES completion:nil];
            
        }
}


//prepare for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"Show Photo"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setPhoto:)]) {
            
            
            
            
            //            [segue.destinationViewController performSelector:@selector(setPhoto:) withObject:self.imageView.image];
            //                [segue.destinationViewController performSelector:@selector(setImageID:) withObject:photo.unique];
            //                [segue.destinationViewController setTitle:photo.title];
            
        }
    }
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!self.imageView.image) {
        [self openCamera];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:(BOOL)animated];    // Call the super class implementation.
    self.imageView.image = nil;
}

- (UIImageView *)imageView
{
    if (!imageView) imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return imageView;
}

- (void)viewDidLoad
{
    
//    PFObject *testObject = [PFObject objectWithClassName:@"Receip"];
//    [testObject setObject:@"bar" forKey:@"foo"];
//    [testObject save];
    
//    PFObject *geoCache = [PFObject objectWithClassName:@"treasure"];
//    [geoCache setObject:@"url for image " forKey:@"imageURL"];
//    [geoCache setObject:@"username for image " forKey:@"username"];
//    [geoCache setObject:@"latitude " forKey:@"locationlat"];
//    [geoCache setObject:@"longitude " forKey:@"locationlong"];
//    [geoCache setObject:@"foursquare location object " forKey:@"foursquareLocation"];
//    
//    
//    [geoCache setObject:@"" forKey:@""];
//    
//    
//    [geoCache save];
    
    
    [super viewDidLoad];
    
  
    
   
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
