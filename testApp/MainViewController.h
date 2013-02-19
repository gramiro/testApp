//
//  MainViewController.h
//  testApp
//
//  Created by Ramiro Guerrero on 18/01/13.
//  Copyright (c) 2013 Ramiro Guerrero. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface MainViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UIImagePickerController *imagePickerController;
    UIImageView *imageView;
    UIActivityIndicatorView *spinner;
}

@property (strong, nonatomic) FBProfilePictureView *profilePicture;
@property (strong, nonatomic) UILabel *userName;
@property (strong, nonatomic) NSMutableDictionary *postParams;

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

@end
