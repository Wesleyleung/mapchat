//
//  CameraViewController.m
//  treasuremap
//
//  Created by Wesley Leung on 3/6/13.
//  Copyright (c) 2013 Wesley Leung. All rights reserved.
//

#import "CameraViewController.h"
#import "SharedDataManager.h"
#import <QuartzCore/QuartzCore.h>


@interface CameraViewController ()


@property (weak, nonatomic) UILabel *photoNotes;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;


@end

@implementation CameraViewController
@synthesize locationManager = _locationManager;

static const CGFloat kJPEGCompressionQuality = 0.7;



@synthesize imageView;


- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _locationManager.distanceFilter = 100;
    }
    return _locationManager;
}


- (IBAction)sendPressed:(id)sender {
    SharedDataManager *manager = [[SharedDataManager alloc] init];
    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, kJPEGCompressionQuality);
    
    CLLocation *location = self.locationManager.location;
    [manager saveMomentDataToServer:imageData text:self.textField.text location:location];

    [self dismissViewControllerAnimated:YES completion:nil];
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
}

- (IBAction)cancelPressed:(id)sender {
    self.imageView.image = nil;
    self.textField.hidden = YES;

    self.textField.text = @"";
    [self openCamera];
}

- (IBAction)photoTapped:(id)sender {
    self.textField.hidden = NO;
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
        [[self view] endEditing:YES];
    } else {
        [self.textField becomeFirstResponder];
    }
}

- (IBAction)textFieldTapped:(id)sender {
    
}


#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if(textField.text.length == 0) {
        textField.hidden = YES;
    }
}

//should cut length of true string
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    CGFloat curWidth = [textField.text sizeWithFont:[UIFont fontWithName:@"Helvetica-Light" size:25.0]].width;
    CGFloat newWidth = [string sizeWithFont:[UIFont fontWithName:@"Helvetica-Light" size:25.0]].width;

    
    
    CGFloat newLength = curWidth + newWidth;

    
    return (newLength > 280.0) ? NO : YES;
}


-(void)hideButtons {
    self.cancelButton.hidden = YES;
    self.sendButton.hidden = YES;
    self.textField.hidden = YES;
}

-(void)showButtons {
    self.cancelButton.hidden = NO;
    self.sendButton.hidden = NO;
}

#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [self.imageView setImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
    [self showButtons];
    [self dismissViewControllerAnimated:YES completion:nil];
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


-(void)openCamera {
    [self hideButtons];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
            
        imagePicker.allowsEditing = NO;
        [imagePicker setDelegate:self];
        [self presentViewController: imagePicker
                               animated: YES completion:nil];
        }
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!self.imageView.image) {
        [self openCamera];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:(BOOL)animated];    // Call the super class implementation.
    self.textField.text = @"";
    self.imageView.image = nil;
    [self.locationManager stopUpdatingLocation];
}

- (UIImageView *)imageView
{
    if (!imageView) imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return imageView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textField.delegate = self;
//    [self.locationManager startUpdatingLocation];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
