//
//  SharedDataManager.m
//  treasuremap
//
//  Created by Wesley Leung on 3/14/13.
//  Copyright (c) 2013 Wesley Leung. All rights reserved.
//

#import "SharedDataManager.h"
#import <Parse/Parse.h>
#import "MapViewController.h"

@implementation SharedDataManager

- (IBAction)refresh:(id)sender {
    NSLog(@"Photo saved to Parse server!");
}

- (void)saveMomentDataToServer:(NSData *)imageData text:(NSString *)text
                     location:(CLLocation*)location
                        seconds: (NSInteger)seconds{
    
    PFFile *imageFile = [PFFile fileWithName:@"image.jpg" data:imageData];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            PFObject *photoMoment = [PFObject objectWithClassName:@"moment"];
            [photoMoment setObject:imageFile forKey:@"imageFile"];
            [photoMoment setObject:text forKey:@"imageText"];
            [photoMoment setObject:[NSNumber numberWithInteger:seconds] forKey:@"seconds"];
            PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude
                                                          longitude:location.coordinate.longitude];
         
            [photoMoment setObject:geoPoint forKey:@"location"];
   
            PFUser *user = [PFUser currentUser];
            
       
            [photoMoment setObject:user forKey:@"user"];
            [photoMoment setObject:[user objectForKey:@"username"] forKey:@"username"];
            [photoMoment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [self refresh:nil];
                }
                else{
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        } else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


//Uses NSUserdefaults to store basic set of moments IDs that the user has already fetched. This is meant to be a lightweight way to check whether a pin has already been placed on the map. It gets cleared when the user logs out. 
+ (void)storeMomentId:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *moments = [defaults objectForKey:@"momentIDs"];
    
    if(!moments) {
        moments = [NSDictionary dictionaryWithObject:@"YES" forKey:key];
    } else {
        NSMutableDictionary *tempMoments = [moments mutableCopy];
        [tempMoments setObject:@"YES" forKey:key];
        moments = [NSDictionary dictionaryWithDictionary:tempMoments];
    }
    [defaults setObject:moments forKey:@"momentIDs"];
    [defaults synchronize];
}


+ (BOOL)doesMomentIdExist:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *moments = [defaults objectForKey:@"momentIDs"];
    if(!moments) {
        return NO;
    } else if ([moments objectForKey:key]) {
        return YES;
    }
    return NO;
}

+ (void)clearMomentIds {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"momentIDs"];
    [defaults synchronize];
}

@end
