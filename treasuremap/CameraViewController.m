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

- (void)postNotificationPhotoSaved; 
- (void)useNotificationPhotoSaved:(NSNotification *)notification;


@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIPickerView *timerPickerView;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *timerButton;

@end

@implementation CameraViewController
@synthesize locationManager = _locationManager;
@synthesize imageView;

static const CGFloat kJPEGCompressionQuality = 0.7;
static const CGFloat kTextfieldLength = 280.0;
static NSString *kNotificationName = @"photoSavedNotification";

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _locationManager.distanceFilter = 100;
    }
    return _locationManager;
}

- (UIImageView *)imageView
{
    if (!imageView) imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return imageView;
}

- (IBAction)sendPressed:(id)sender {
    SharedDataManager *manager = [[SharedDataManager alloc] init];
    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, kJPEGCompressionQuality);
    
    CLLocation *location = self.locationManager.location;
    
    [manager saveMomentDataToServer:imageData text:self.textField.text location:location seconds:[self.timerButton.titleLabel.text integerValue]];
    [self postNotificationPhotoSaved];
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

-(void)hideButtons {
    self.cancelButton.hidden = YES;
    self.sendButton.hidden = YES;
    self.textField.hidden = YES;
    self.timerButton.hidden = YES;
}

-(void)showButtons {
    self.cancelButton.hidden = NO;
    self.sendButton.hidden = NO;
    self.timerButton.hidden = NO;
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
    return (newLength > kTextfieldLength) ? NO : YES;
}

#pragma mark UIPickerViewDelegate

- (IBAction)showTimerPicker:(id)sender {
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [self.actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 0, 0, 0);
    self.timerPickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    self.timerPickerView.showsSelectionIndicator = YES;
    self.timerPickerView.delegate = self;
    
    for (int i = 1; i <= 10; i++) {
        if ([self.timerButton.titleLabel.text integerValue] == i) {
            i -= 1;
            [self.timerPickerView selectRow:i inComponent:0 animated:NO];
            break;
        }
        
    }
    
    [self.actionSheet addSubview:self.timerPickerView];
    [self.actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [self.actionSheet setBounds:CGRectMake(0, 0, 320, 415)];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 10;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSInteger seconds = row + 1;
    return [NSString stringWithFormat:@"%d seconds", seconds];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger seconds = row + 1;
    [self.timerButton setTitle:[NSString stringWithFormat:@"%d",seconds] forState: UIControlStateNormal];
    [self dismissActionSheet];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    return sectionWidth;
}

-(void)dismissActionSheet {
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
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


-(void)openCamera {
    [self hideButtons];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
        self.imagePicker = [[UIImagePickerController alloc] init];
        
        [self.imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        self.imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        
        self.imagePicker.allowsEditing = NO;
        [self.imagePicker setDelegate:self];
        
        [self presentViewController: self.imagePicker animated: YES completion:nil];
    }
}

#pragma mark views
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!self.imageView.image) {
        [self openCamera];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated {
    self.textField.text = @"";
    self.imageView.image = nil;
    [self hideButtons];
    [self.locationManager stopUpdatingLocation];
    [super viewDidDisappear:(BOOL)animated];    
}

-(void)postNotificationPhotoSaved {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName object:nil];
}

-(void)useNotificationPhotoSaved:(NSNotification *)notification {
    NSLog(@"Photo saved!");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textField.delegate = self;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(useNotificationPhotoSaved:)
     name:kNotificationName
     object: nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
