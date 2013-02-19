//
//  LoginViewController.m
//  testApp
//
//  Created by Ramiro Guerrero on 18/01/13.
//  Copyright (c) 2013 Ramiro Guerrero. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loginButton setTitle:@"Login with Facebook" forState:UIControlStateNormal];
    loginButton.frame = CGRectMake(self.view.bounds.size.width/2 - 125, 150, 250, 40);
    [loginButton addTarget:self action:@selector(performLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:loginButton];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 100, 50, 200, 40)];
    title.text = @"Post a photo on your wall!";
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:title];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)performLogin:(id)sender{
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate openSession];
}

- (void)loginFailed
{
    
}

@end
