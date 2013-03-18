//
//  ImageViewController.m
//  treasuremap
//
//  Created by Wesley Leung on 3/15/13.
//  Copyright (c) 2013 Wesley Leung. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) PFObject *object;

@property (nonatomic) NSInteger counter;
@property (weak, nonatomic) NSTimer *timer;

@end
@implementation ImageViewController


- (void)setPhoto:(PhotoMoment *)photoMoment
{
    _photoMoment = photoMoment;
}

- (void)resetImage
{
    if (self.imageView) {
        self.imageView.image = nil;
        [self.spinner startAnimating];
        PFQuery *query = [PFQuery queryWithClassName:@"moment"];
        [query whereKey:@"objectId" equalTo:self.photoMoment.objectID];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if(object) {
                PFFile *imageFile = [object objectForKey:@"imageFile"];
                
                dispatch_queue_t imageFetchQ = dispatch_queue_create("image data loader", NULL);
                dispatch_async(imageFetchQ, ^{
                    UIImage *image = [UIImage imageWithData:[imageFile getData]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (image) {
                            self.imageView.image = image;
                            self.label.text = [object objectForKey:@"imageText"];
                            self.object = object;
                            self.counter = ([object objectForKey:@"seconds"]) ? [[object objectForKey:@"seconds"] integerValue] : 5;
                            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                          target:self
                                                                        selector:@selector(updateTimer)
                                                                        userInfo:nil
                                                                         repeats:YES];
                        }
                        [self showLabels];
                        [self.spinner stopAnimating];
                    });
                    
                });
            } else {
                self.label.text = @"Photo not found!";
            }
        }];
    }
}

- (void)showLabels {
    self.timerLabel.hidden = NO;
    self.label.hidden = NO;
}

- (IBAction)imageSwiped:(id)sender {
    [self.timer invalidate];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark time control functions
- (void)updateTimer {
    self.counter -=1;
    if(self.counter >= 0) {
        self.timerLabel.text = [NSString stringWithFormat:@"%i", self.counter];
    }
    if (self.counter < 0) {
        [self timerExpired];
    }
}

- (void)timerExpired {
    [self.timer invalidate];
    [self.object deleteInBackground];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self resetImage];
}

@end
