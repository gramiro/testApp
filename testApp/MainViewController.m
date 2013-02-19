//
//  MainViewController.m
//  testApp
//
//  Created by Ramiro Guerrero on 18/01/13.
//  Copyright (c) 2013 Ramiro Guerrero. All rights reserved.
//

#import "MainViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"



@interface MainViewController () <CLLocationManagerDelegate, FBPlacePickerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIButton *publishOnFacebook;
@property (strong, nonatomic) FBPlacePickerViewController *placePickerController;
@property (strong, nonatomic) NSObject<FBGraphPlace>* selectedPlace;
@property (strong, nonatomic) UIButton *takeAPic;
@end

@implementation MainViewController
@synthesize userName;
@synthesize profilePicture;
@synthesize postParams;
@synthesize locationManager = _locationManager;
@synthesize publishOnFacebook = _publishOnFacebook;
@synthesize placePickerController = _placePickerController;
@synthesize selectedPlace = _selectedPlace;
@synthesize takeAPic = _takeAPic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc{
    _locationManager.delegate = nil;
    _placePickerController.delegate = nil;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    // We don't want to be notified of small changes in location,
    // preferring to use our last cached results, if any.
    self.locationManager.distanceFilter = 50;
    [self.locationManager startUpdatingLocation];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Logout"
                                              style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(logoutButtonWasPressed:)];
    
    userName = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 100, 10, 200, 30)];
    userName.backgroundColor = [UIColor clearColor];
    userName.textAlignment = NSTextAlignmentCenter;
    userName.textColor = [UIColor whiteColor];
    
    [self.view addSubview:userName];
    
    profilePicture = [[FBProfilePictureView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 25, 50, 50, 50)];
    
    [self.view addSubview:profilePicture];
    
    self.takeAPic = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.takeAPic setTitle:@"Take a Photo" forState:UIControlStateNormal];
    self.takeAPic.frame = CGRectMake(self.view.bounds.size.width/2 - 100, 120, 200, 50);
    [self.takeAPic addTarget:self action:@selector(takeAPicture) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.takeAPic];
    
    self.publishOnFacebook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.publishOnFacebook setTitle:@"Publish your photo" forState:UIControlStateNormal];
    self.publishOnFacebook.frame = CGRectMake(self.view.bounds.size.width/2 - 100, 170, 200, 50);
    [self.publishOnFacebook addTarget:self action:@selector(publish:) forControlEvents:UIControlEventTouchUpInside];
    self.publishOnFacebook.enabled = NO;
    [self.view addSubview:self.publishOnFacebook];

    
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
       
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 75, 250, 150, 150)];
    imageView.hidden = YES;
    
    [self.view addSubview:imageView];
    
   
    spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(13, 180, 30, 30)];
    spinner.hidden = YES;
    
    [self.view addSubview:spinner];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:SessionStateChangedNotification
     object:nil];
    
	// Do any additional setup after loading the view.
}

- (void)publishStory
{
    [FBRequestConnection
     startWithGraphPath:@"me/photos"
     parameters:self.postParams
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection,
                         id result,
                         NSError *error) {
         NSString *alertText;
         if (error) {
             alertText = [NSString stringWithFormat:
                          @"error: domain = %@, code = %d",
                          error.domain, error.code];
         } else {
             alertText = [NSString stringWithFormat:
                          @"Posted action, id: %@",
                          [result objectForKey:@"id"]];
             imageView.hidden = YES;
             imageView.image = nil;
         }
         
         [spinner stopAnimating];
         self.publishOnFacebook.enabled = YES;
         self.takeAPic.enabled = YES;
         // Show the result in an alert
         [[[UIAlertView alloc] initWithTitle:@"Result"
                                     message:alertText
                                    delegate:self
                           cancelButtonTitle:@"OK!"
                           otherButtonTitles:nil]
          show];
     }];
}



-(void)takeAPicture{

    [self.navigationController presentViewController:imagePickerController animated:NO completion:nil];
    
    
}

-(void)publish:(id)sender{
    
    if (!self.placePickerController) {
        self.placePickerController = [[FBPlacePickerViewController alloc]
                                      initWithNibName:nil bundle:nil];
        self.placePickerController.title = @"Select a place";
        self.placePickerController.delegate = self;

    }
    self.placePickerController.locationCoordinate =
    self.locationManager.location.coordinate;
    self.placePickerController.radiusInMeters = 1000;
    self.placePickerController.resultsLimit = 50;
    self.placePickerController.searchText = @"";
    
    [self.placePickerController loadData];
    [self.navigationController pushViewController:self.placePickerController
                                         animated:true];
    
 
}
- (void)placePickerViewControllerSelectionDidChange:
(FBPlacePickerViewController *)placePicker
{
    self.selectedPlace = placePicker.selection;
    [postParams setObject:self.selectedPlace.id forKey:@"place"];

    if ([FBSession.activeSession.permissions
         indexOfObject:@"publish_actions"] == NSNotFound) {
        // No permissions found in session, ask for it
        [FBSession.activeSession
         reauthorizeWithPublishPermissions:
         [NSArray arrayWithObject:@"publish_actions"]
         defaultAudience:FBSessionDefaultAudienceFriends
         completionHandler:^(FBSession *session, NSError *error) {
             if (!error) {
                 // If permissions granted, publish the story
                 [self publishStory];
             }
         }];
    } else {
        // If permissions present, publish the story
        [self publishStory]; }
  //  [self updateSelections];
    if (self.selectedPlace.count > 0) {
        [self.navigationController popViewControllerAnimated:true];
        spinner.hidden = NO;
        [spinner startAnimating];
        self.publishOnFacebook.enabled = NO;
        self.takeAPic.enabled = NO;

    }
}
-(void) viewWillAppear:(BOOL)animated{
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sessionStateChanged:(NSNotification*)notification {
    [self populateUserDetails];
}

-(void)logoutButtonWasPressed:(id)sender {
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (void)populateUserDetails
{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 self.userName.text = user.name;
                 self.profilePicture.profileID = user.id;
             }
         }];
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (!oldLocation ||
        (oldLocation.coordinate.latitude != newLocation.coordinate.latitude &&
         oldLocation.coordinate.longitude != newLocation.coordinate.longitude)) {
            
            // To-do, add code for triggering view controller update
            NSLog(@"Got location: %f, %f",
                  newLocation.coordinate.latitude,
                  newLocation.coordinate.longitude);
        }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}


- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    
   
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    imagePickerController.view.hidden = YES;
    imageView.image = image;
    imageView.hidden = NO;
    
    [self.view bringSubviewToFront:imageView];
    
    self.publishOnFacebook.enabled = YES;
    
    postParams =
    [[NSMutableDictionary alloc] initWithObjectsAndKeys:
     nil];
    
    [postParams setObject:UIImagePNGRepresentation(imageView.image) forKey:@"source"];
    
    

}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
        
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

@end
