//
//  PhotoMoment.h
//  treasuremap
//
//  Created by Wesley Leung on 3/15/13.
//  Copyright (c) 2013 Wesley Leung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface PhotoMoment : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}
//
//@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
//@property (nonatomic, readonly) NSString *photographer;
//@property (nonatomic, readonly) NSString *subtitle;
@property (nonatomic, readonly) NSNumber *latitude;
@property (nonatomic, readonly) NSNumber *longitude;
@property (nonatomic, readonly) NSString *objectID;



- (id)initWithParseObject: (PFObject*)object;

@end
