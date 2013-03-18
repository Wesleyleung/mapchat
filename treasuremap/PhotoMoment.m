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
@synthesize timer;


- (id)initWithParseObject: (PFObject*)object {
    self = [super init];
    if(self !=nil) {
        objectID = object.objectId;
        title = [object objectForKey:@"username"];
        subtitle = [object objectForKey:@"imageText"];
        timer = [object objectForKey:@"imageText"];
        PFGeoPoint *geoPoint = [object objectForKey:@"location"];
        coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    }
    return self;
}



@end
