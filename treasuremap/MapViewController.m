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
#import "SharedDataManager.h"


@interface MapViewController ()


@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (weak, nonatomic) IBOutlet UILabel *photoSavedNotification;
@property (strong, nonatomic) SharedDataManager *manager;
@property (strong, nonatomic) PhotoMoment *pinToRemove;
@end

@implementation MapViewController


@synthesize mapView = _mapView;

-(SharedDataManager *)manager {
    if(!_manager) {
        _manager = [[SharedDataManager alloc] init];
    }
    return _manager;
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    MKUserTrackingBarButtonItem *orientButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    
    UIBarButtonItem *checkinButton = [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStyleBordered target:self action:@selector(checkInButtonPressed:)];
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
        [_mapView setDelegate:self];
        self.mapView.showsUserLocation = YES;
    }
    
    if(self.pinToRemove) {
        [self.mapView removeAnnotation:self.pinToRemove];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    self.mapView.showsUserLocation = NO;
}

- (void)logoutButtonPressed:(id)sender {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [SharedDataManager clearMomentIds];
    [super logoutButtonPressed];
}

- (void)checkInButtonPressed:(id)sender {
    [self goToUserLocation:self.mapView.userLocation];
    CGFloat kilometers = 1.0;
    PFQuery *query = [PFQuery queryWithClassName:@"moment"];    
    [query whereKey:@"location"
        nearGeoPoint:[PFGeoPoint geoPointWithLatitude:self.mapView.userLocation.coordinate.latitude
                                            longitude:self.self.mapView.userLocation.coordinate.longitude] withinKilometers:kilometers];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count > 0) {
            for (PFObject *object in objects) {
                if(![SharedDataManager doesMomentIdExist:object.objectId]) {
                    //check if in cache. If not, add pin.
                    [SharedDataManager storeMomentId:object.objectId];
                    PhotoMoment *pin = [[PhotoMoment alloc] initWithParseObject:object];
                    [self.mapView addAnnotation:pin];
                    
                }
               
                
            }
        }
    
    }];
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


//-(void)photoLoadInProgress {
//    self.photoSavedNotification.hidden = YES;
//}

+(void)photoLoadFinished {
//    [NSTimer scheduledTimerWithTimeInterval:2.0
//                                     target:self
//                                   selector:@selector(hideLabel:)
//                                   userInfo:nil
//                                    repeats:NO];
}

- (void)hideLabel {
    self.photoSavedNotification.hidden = YES;
}

#pragma mark MKMapViewDelegate methods
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    //set current location to blue dot
    if (annotation == mapView.userLocation){
        return nil; 
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


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [self performSegueWithIdentifier:@"setPhoto:" sender:view];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"setPhoto:"]) {
        if ([sender isKindOfClass:[MKAnnotationView class]]) {
            MKAnnotationView *view = sender;
            if ([view.annotation isKindOfClass:[PhotoMoment class]]) {
                PhotoMoment *photo = view.annotation;
                self.pinToRemove = photo;
                if ([segue.destinationViewController respondsToSelector:@selector(setPhoto:)]) {
                    [segue.destinationViewController performSelector:@selector(setPhoto:) withObject:photo];
                }
            }
        }
    }
}


@end
