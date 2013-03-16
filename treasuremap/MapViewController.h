//
//  MapViewController.h
//  treasuremap
//
//  Created by Wesley Leung on 3/6/13.
//  Copyright (c) 2013 Wesley Leung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import "LoginViewController.h"

@interface MapViewController : LoginViewController <MKMapViewDelegate, CLLocationManagerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>



@end
