//
//  LoginViewController.m
//  treasuremap
//
//  Created by Wesley Leung on 3/14/13.
//  Copyright (c) 2013 Wesley Leung. All rights reserved.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"

@interface LoginViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@end

@implementation LoginViewController


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![PFUser currentUser]) {
        [self presentLoginView];
    } else {
        if (![[PFUser currentUser] objectForKey:@"first_name"]) {
            [self setupNewUserAccount];
        }
    }
}

- (void)setupNewUserAccount {
    [[PF_FBRequest requestForMe] startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary<PF_FBGraphUser> *user = (NSDictionary<PF_FBGraphUser> *)result;
            PFUser *curUser = [PFUser currentUser];
            id username = (user.username) ? user.username : [NSNull null];
            id first_name = (user.first_name) ? user.first_name : [NSNull null];
            id last_name = (user.last_name) ? user.last_name : [NSNull null];
            id email = ([user objectForKey:@"email"]) ? [user objectForKey:@"email"] : [NSNull null];
            
            [curUser setObject:username forKey:@"username"];
            [curUser setObject:first_name forKey:@"first_name"];
            [curUser setObject:last_name forKey:@"last_name"];
            [curUser setObject:email forKey:@"email"];
            [curUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self setupViewForUser];
            }];
        }
    }];
}


- (void)setupViewForUser {
    PFUser *curUser = [PFUser currentUser];
    if (![curUser objectForKey:@"username"]) {
        return;
    }
//    //force seque
//    [self performSegueWithIdentifier: @"login" sender: self];
 
}

#pragma mark - User Login

- (void)presentLoginView {
    PFLogInViewController *loginVC = [[PFLogInViewController alloc] init];
    loginVC.delegate = self;
    loginVC.signUpController.delegate = self;
    loginVC.fields = PFLogInFieldsFacebook;
    [loginVC.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]]];
    
    [loginVC setTitle:@"MapChat"];
    [self.navigationController presentViewController:loginVC animated:YES completion:nil];
}

- (void)logoutButtonPressed{
    [PFUser logOut];
    [self presentLoginView];
}

#pragma mark PFLogInViewControllerDelegate Methods

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark PFSignUpViewControllerDelegate Methods

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
