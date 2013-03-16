//
//  PhotoMoment.m
//  treasuremap
//
//  Created by Wesley Leung on 3/15/13.
//  Copyright (c) 2013 Wesley Leung. All rights reserved.
//

#import "PhotoMoment.h"

@implementation PhotoMoment

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize objectID;


//- (CLLocationCoordinate2D)coordinate {
//    CLLocationCoordinate2D coordinate;
//    coordinate.latitude = [self.latitude doubleValue];
//    coordinate.longitude = [self.longitude doubleValue];
//    return coordinate;
//}

- (id)initWithParseObject: (PFObject*)object {
    self = [super init];
    if(self !=nil) {
        objectID = object.objectId;
        title = [object objectForKey:@"username"];
        subtitle = [object objectForKey:@"imageText"];
        PFGeoPoint *geoPoint = [object objectForKey:@"location"];
        coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
//        photographer = [object objectForKey:@""];
        
    }
    return self;
}



@end
