//
//  SharedDataManager.m
//  treasuremap
//
//  Created by Wesley Leung on 3/14/13.
//  Copyright (c) 2013 Wesley Leung. All rights reserved.
//

#import "SharedDataManager.h"
#import <Parse/Parse.h>

@implementation SharedDataManager

- (IBAction)refresh:(id)sender {
    NSLog(@"Photo saved to Parse!");
}

-(void)saveMomentDataToServer:(NSData *)imageData text:(NSString *)text
                     location:(CLLocation*)location {
    
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {

            
            //    PFObject *testObject = [PFObject objectWithClassName:@"Receip"];
            //    [testObject setObject:@"bar" forKey:@"foo"];
            //    [testObject save];
            
            
            // Create a PFObject around a PFFile and associate it with the current user
            PFObject *photoMoment = [PFObject objectWithClassName:@"moment"];
            [photoMoment setObject:imageFile forKey:@"imageFile"];
            [photoMoment setObject:text forKey:@"imageText"];
            
            PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude
                                                          longitude:location.coordinate.longitude];
            
            [photoMoment setObject:geoPoint forKey:@"location"];
            // Set the access control list to current user for security purposes
            photoMoment.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
            PFUser *user = [PFUser currentUser];
            
       
            [photoMoment setObject:user forKey:@"user"];
            [photoMoment setObject:[user objectForKey:@"username"] forKey:@"username"];
            
            [photoMoment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [self refresh:nil];
                }
                else{
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        } else{
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    
    
}

@end
