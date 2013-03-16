//
//  MapViewController.m
//  treasuremap
//
//  Created by Wesley Leung on 3/6/13.
//  Copyright (c) 2013 Wesley Leung. All rights reserved.
//

#import "MapViewController.h"
#import "LoginViewController.h"
#import "PhotoMoment.h"


@interface MapViewController () 

//@property (strong, nonatomic) CLLocationManager *locationManager;
//@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation MapViewController


//@synthesize locationManager = _locationManager;
//@synthesize currentLocation = _currentLocation;
@synthesize mapView = _mapView;


//- (CLLocationManager *)locationManager {
//    if (!_locationManager) {
//        _locationManager = [[CLLocationManager alloc] init];
//        _locationManager.delegate = self;
//        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//        _locationManager.distanceFilter = 100;
//    }
//    return _locationManager;
//}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    MKUserTrackingBarButtonItem *orientButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    
    UIBarButtonItem *checkinButton = [[UIBarButtonItem alloc] initWithTitle:@"Check In" style:UIBarButtonItemStyleBordered target:self action:@selector(checkInButtonPressed:)];
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonPressed:)];
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.toolbar setBackgroundImage:transparentImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [self.toolbar setItems:@[orientButton, checkinButton, logoutButton] animated: NO];
        
    if([CLLocationManager locationServicesEnabled]) {
//        [self.locationManager startUpdatingLocation];
        [_mapView setDelegate:self];
        self.mapView.showsUserLocation = YES;
//        [self goToUserLocation:self.mapView.userLocation];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    self.mapView.showsUserLocation = NO;
//    [self.locationManager stopUpdatingLocation];
}

- (void)logoutButtonPressed:(id)sender {
    [super logoutButtonPressed];
    
//    [PFUser logOut];
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)checkInButtonPressed:(id)sender {
    [self goToUserLocation:self.mapView.userLocation];
    CGFloat kilometers = 1.0;
    PFQuery *query = [PFQuery queryWithClassName:@"moment"];
    [query setLimit:20];     
    [query whereKey:@"location"
        nearGeoPoint:[PFGeoPoint geoPointWithLatitude:self.mapView.userLocation.coordinate.latitude
                                            longitude:self.self.mapView.userLocation.coordinate.longitude] withinKilometers:kilometers];


    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count > 0) {
            for (PFObject *object in objects) {
                PhotoMoment *pin = [[PhotoMoment alloc] initWithParseObject:object];
                //check if in cache. If not, add pin.
                [self.mapView addAnnotation:pin];
                
            }
        }
    
    }];
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
//    _currentLocation = newLocation;
//    [_mapView setCenterCoordinate:newLocation.coordinate animated:YES];
//    if (isNavigating) {
//        [self updateDistanceDisplay];
//    } else {
//        [self.locationManager stopUpdatingLocation];
//        [self.locationManager performSelector:@selector(startUpdatingLocation) withObject:nil afterDelay:10];
//    }
}


- (void)goToUserLocation:(MKUserLocation *)userLocation
{
    if (!userLocation)
        return;
    MKCoordinateRegion region;
    region.center = userLocation.location.coordinate;
    region.span = MKCoordinateSpanMake(0.01, 0.01);
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
//    [self goToUserLocation:userLocation];

}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation == mapView.userLocation){
        return nil; //default to blue dot
    }
    static NSString *reuseId = @"MapViewController";
    MKPinAnnotationView *view = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if(!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        view.canShowCallout = YES;
        view.animatesDrop = YES;
        view.pinColor = MKPinAnnotationColorGreen;
        
        if ([mapView.delegate respondsToSelector:@selector(mapView:annotationView:
            calloutAccessoryControlTapped:)]) {
            view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        view.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    if([view.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)(view.leftCalloutAccessoryView);
        imageView.image = nil;
    }
    return view;
}


// sent to the mapView's delegate (us) when any {left,right}CalloutAccessoryView
//   that is a UIControl is tapped on
// in this case, we manually segue using the setPhoto: segue
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [self performSegueWithIdentifier:@"setPhoto:" sender:view];
}


// prepares a view controller segued to via the setPhoto: segue
//   by calling setPhoto: with the photo associated with sender
//   (sender must be an MKAnnotationView whose annotation is a Photo)
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"setPhoto:"]) {
        if ([sender isKindOfClass:[MKAnnotationView class]]) {
            MKAnnotationView *aView = sender;
            if ([aView.annotation isKindOfClass:[PhotoMoment class]]) {
                PhotoMoment *photo = aView.annotation;
                if ([segue.destinationViewController respondsToSelector:@selector(setPhoto:)]) {
                    [segue.destinationViewController performSelector:@selector(setPhoto:) withObject:photo];
                }
            }
        }
    }
}


@end
