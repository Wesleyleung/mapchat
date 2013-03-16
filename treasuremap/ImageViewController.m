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
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count > 0) {
                for (PFObject *object in objects) {
                    PFFile *imageFile = [object objectForKey:@"imageFile"];
                    UIImage *image = [UIImage imageWithData:[imageFile getData]];
                    self.imageView.image = image;
                    self.label.text = [object objectForKey:@"imageText"];
                }
            }
            
         [self.spinner stopAnimating];
         
        }];
    }
}
- (IBAction)imageSwiped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self resetImage];
}

@end
