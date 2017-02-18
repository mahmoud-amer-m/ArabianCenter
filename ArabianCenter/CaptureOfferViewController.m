//
//  CaptureOfferViewController.m
//  ArabianCenter
//
//  Created by MacBookPro on 5/20/1438 AH.
//  Copyright © 1438 Amer. All rights reserved.
//

#import "CaptureOfferViewController.h"

@interface CaptureOfferViewController ()

@end

@implementation CaptureOfferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //User Location Work
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    
    //Firebase Reference
    if(!ref)
        ref = [[FIRDatabase database] reference];
    
    //Logged in user
    user = [FIRAuth auth].currentUser;
    
    //If running from simulatr, Show warning
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self showAlert:@"Use your real device" andMessage:@"Use your real device, please"];
    }
    //Status label text
    self.messageLabel.text = @"Getting current offer";
    //Set offer captured th by the user to false
    userAlreadyCaptured = false;
    
    currentAvailableOffer = nil;
    
    [self getCurrentOffer];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getCurrentOffer
{
    //Get the current offer (the offer that has status equals "1" and remaining coupons more than zero)
    [[ref child:@"Offers"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // Get user value
        //Status label text
        self.messageLabel.text = @"";
        for(FIRDataSnapshot *offer in snapshot.children) {
            if(([offer.value[@"status"] intValue] == 1) && !([[offer.value[@"remaining"] stringValue] isEqualToString:@"0"])){
                NSLog(@"there's an available offer - %@ - %d - %@ - %@", offer.value[@"status"], [offer.value[@"remaining"] intValue], offer.value[@"remaining"], offer.key);
                currentAvailableOffer = offer;
                //Status label text
                self.messageLabel.text = @"Getting your captured coupons";
                [self getUserCoupons];
            }else{
                NSLog(@"No available offers");
                [self hideLoadingView];
            }
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"error %@", error.localizedDescription);
    }];
    
}
//Hide loadingView
-(void)hideLoadingView
{
    [self.loadingView setHidden:YES];
}
#pragma mark - Get User Coupons
-(void)getUserCoupons
{
    //Get the current offer (the offer that has status equals "1")
    [[ref child:@"captured_coupons"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSString *status = 0;
        
        for(FIRDataSnapshot *offer in snapshot.children) {

            if(([offer.value[@"user_id"] isEqualToString:[NSString stringWithFormat:@"%@",user.uid]]) && ([offer.value[@"offer_id"] isEqualToString:currentAvailableOffer.key])){
                //Shopper already captured a coupon for this offer before
                userAlreadyCaptured = YES;
                [self.capturedCouponLoadingIndicator startAnimating];
                //Show current offer coupon image of the logged in user
                // Points to the root reference
                
                FIRStorageReference *storageRef = [[FIRStorage storage] reference];
                // Points to "images"
                NSString *fileName = [NSString stringWithFormat:@"%@/%@.png",user.uid, currentAvailableOffer.key];
                
                FIRStorageReference *islandRef = [storageRef child:fileName];
                
                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                [islandRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData *data, NSError *error){
                    if (error != nil) {
                        NSLog(@"error while downloading image - %@", error.localizedDescription);
                    } else {
                        // Data for the image is returned
                        UIImage *couponImg = [UIImage imageWithData:data];
                        self.couponImgView.image = couponImg;
                    }
                    [self.capturedCouponLoadingIndicator stopAnimating];
                }];
                //User coupon Status
                status = offer.value[@"status"];
            }
        }
        //Status label text
        if(userAlreadyCaptured){
            if([status isEqualToString:@"0"])
                self.messageLabel.text = @"You have a coupon for the current offer, Tweet and claim";
            else
                self.messageLabel.text = @"You have a coupon for the current offer, Ready to claim";
        
        }else
            self.messageLabel.text = @"harry up, capture your copoun";
        //Hide loading View
        self.loadingView.hidden = YES;
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"error %@", error.localizedDescription);
        //Hide loading View
        self.loadingView.hidden = YES;
    }];
    
}

- (IBAction)captureOfferAction:(UIButton *)sender {
    if(currentAvailableOffer){
        if(!userAlreadyCaptured){
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }else{
            [self showAlert:@"Coupon captured before" andMessage:@"You captured this offer before"];
        }
    }else{
        [self showAlert:@"No Available Offers" andMessage:@"No available offers for now."];
    }
    
    
}

- (IBAction)backAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tweet:(UIButton *)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Great offer from The Arabian Center #The_Arabian_Center "];
        [tweetSheet addImage:couponImage];
        [self presentViewController:tweetSheet animated:YES completion:nil];
        //Tweet completion handler to update coupon status in database
        tweetSheet.completionHandler = ^(SLComposeViewControllerResult result)
        {
            switch (result)
            {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"tweet cancelled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"tweet completed");
                    
                    [self tweetSuccessful];
                    break;
                    
                default:
                    break;
            }
        };
    }
}

-(void)tweetSuccessful
{
    NSLog(@"%@ ", AddedCouponID);
    //Status message
    self.messageLabel.text = @"You have a coupon for the current offer, Ready to claim";
    //Change coupon status to 1 (Means already shared on social media)
    [[[[ref child:@"captured_coupons"] child:AddedCouponID] child:@"status"] setValue:@"1"];
}
#pragma mark - Update offer


-(void) updateDatabase
{
    //Update the offer remaining number -1
    NSLog(@"offer : %@", currentAvailableOffer.key);
    int remaining = [currentAvailableOffer.value[@"remaining"] intValue];
    
    //If last coupon, Change offer status to 0 (Expired)
    NSLog(@"captured_valid : %d", remaining);
    if(remaining == 1)
            [[[[ref child:@"Offers"] child:currentAvailableOffer.key] child:@"status"] setValue:@"0"];
    
    remaining --;
    NSNumber *numRemaining = [NSNumber numberWithInt:remaining];
    [[[[ref child:@"Offers"] child:currentAvailableOffer.key] child:@"remaining"] setValue:numRemaining];
    
    //Add new captured offer record
    //Create the coupon with status 0 (means still not shared on social media)
    NSString *key = [[ref child:@"captured_coupons"] childByAutoId].key;
    NSDictionary *capturedOffer = @{@"user_id": user.uid,
                                    @"status": @"0",
                                    @"offer_id": currentAvailableOffer.key,
                                    @"location":[NSString stringWithFormat:@"%.8f,%.8f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude]};
    NSDictionary *childUpdates = @{[@"/captured_coupons/" stringByAppendingString:key]: capturedOffer};
    AddedCouponID = key;
    [ref updateChildValues:childUpdates];
    [self getUserCoupons];
    //Status label text
    self.messageLabel.text = @"";
}

-(void)saveImage:(UIImage *)capturedImage{
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [storage reference];
    NSData *imageData = UIImageJPEGRepresentation(capturedImage, 1.0);
    
    // Create a reference to the file you want to upload
    FIRStorageReference *riversRef = [storageRef child:[NSString stringWithFormat:@"%@/%@.png", user.uid,currentAvailableOffer.key]];
    
    
    // Upload the file to the path "images/rivers.jpg"
    FIRStorageUploadTask *uploadTask = [riversRef putData:imageData
                                                 metadata:nil
                                               completion:^(FIRStorageMetadata *metadata,
                                                            NSError *error) {
                                                   if (error != nil) {
                                                       NSLog(@"Error, Upload failed");
                                                   } else {
                                                       NSLog(@"uploaded : %@", metadata.contentType);
                                                   }
                                               }];
    
    [self showAlert:@"Share To Claim" andMessage:@"Please tweet the coupon to claim your offer"];
}
#pragma mark - Camera Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    //Show coupon image
    couponImage = info[UIImagePickerControllerEditedImage];
    self.couponImgView.image = couponImage;
    //Save coupon image
    [self saveImage:couponImage];
    //Dismiss camera picker controller
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    //Show loading View
    self.loadingView.hidden = NO;
    
    //Update database
    [self updateDatabase];
    
    //Status label text
    self.messageLabel.text = @"Coupon is here, Please wait!";
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    currentLocation = newLocation;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)showAlert:(NSString *)title andMessage:(NSString *)message{
    if(!([title isEqualToString:@""]) && !([message isEqualToString:@""])){
        UIAlertController *myAlertView = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"OK"
                                                             style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                 
                                                             }];
        [myAlertView addAction:doneAction];
        [self presentViewController:myAlertView animated:YES completion:nil];
    }
    
}

@end
