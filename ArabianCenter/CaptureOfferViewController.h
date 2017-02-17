//
//  CaptureOfferViewController.h
//  ArabianCenter
//
//  Created by MacBookPro on 5/20/1438 AH.
//  Copyright © 1438 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Social/Social.h>

@import FirebaseStorage;
@import Firebase;
@import FirebaseDatabase;

@interface CaptureOfferViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate> {
    FIRUser *user;
    FIRDatabaseReference *ref;
    
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    
    UIImage *couponImage;
    
    FIRDataSnapshot *currentAvailableOffer;
    BOOL userAlreadyCaptured;
    
    NSString *AddedCouponID;
}

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIImageView *couponImgView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *capturedCouponLoadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *captureBTN;

- (IBAction)captureOfferAction:(UIButton *)sender;
- (IBAction)backAction:(UIButton *)sender;
- (IBAction)tweet:(UIButton *)sender;
@end
