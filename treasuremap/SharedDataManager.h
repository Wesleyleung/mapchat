//
//  SharedDataManager.h
//  treasuremap
//
//  Created by Wesley Leung on 3/14/13.
//  Copyright (c) 2013 Wesley Leung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SharedDataManager : NSObject



- (void)saveMomentDataToServer:(NSData *)imageData
                          text:(NSString *)text
                        location: (CLLocation *) location;

@end
