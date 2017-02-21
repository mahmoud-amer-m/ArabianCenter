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
    internetReachability = [Reachability reachabilityForInternetConnection];

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
        [self showAlert:NSLocalizedString(@"real_device_title", @"real device needed") andMessage:NSLocalizedString(@"real_device_message", @"real device needed")];
    }
    //Status label text
    self.messageLabel.text = NSLocalizedString(@"status_label_loading_offer", @"loading current offer");
    //Set offer captured th by the user to false
    userAlreadyCaptured = NO;
    currentAvailableOffer = nil;
    userCapturedCoupon =nil;
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Call the method that git the current available offer
    if(!((long)internetReachability.currentReachabilityStatus == 0))
        [self getCurrentOffer];
    else
        [self showAlert:@"Connection Problem" andMessage:@"Please connect to internet"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get current available offer
-(void)getCurrentOffer
{
    [self.loadingView setHidden:NO];
    //Get the current offer (the offer that has status equals "1" and remaining coupons more than zero)
    [[[[ref child:@"Offers"] queryOrderedByChild:@"status"] queryEqualToValue:[NSNumber numberWithInt:1]] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // Get user value
        //Status label text
        self.messageLabel.text = @"";

        if((unsigned long)snapshot.childrenCount > 0){
            
            for(FIRDataSnapshot *offer in snapshot.children) {
                NSLog(@"loop - %@", offer.key);
                //Check if this offer has remaining coupons
                NSLog(@"num - %d - num %d", [(NSNumber *)offer.value[@"remaining"] intValue], [[NSNumber numberWithInt:0] intValue]);

                if(!([(NSNumber *)offer.value[@"remaining"] intValue] == [[NSNumber numberWithInt:0] intValue])){
                    NSLog(@"available offer key: %@", offer.key);
                    currentAvailableOffer = offer;
                    
                    break;
                }
            }
            //Call the function that update status message and will call get user coupons
            [self finishGetCurrentOfferWithStatus:currentAvailableOffer];
        }else{
            //Call the function that update status message
            [self finishGetCurrentOfferWithStatus:nil];
        }
        
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        //Call the function that update status message
        [self finishGetCurrentOfferWithStatus:nil];
        NSLog(@"error %@", error.localizedDescription);
    }];
    
}

/*
 After getting offers, we should check if there's an available offer now. And then tell the shopper whether there's or not
 Parameters: offer -- represents current available offer -- if nil, No available offers now
 */
-(void)finishGetCurrentOfferWithStatus:(FIRDataSnapshot *)offer
{
    if(offer){
        //Set current available offer
        
        //Status label text
        self.messageLabel.text = NSLocalizedString(@"status_label_loading_shopper_coupon", @"getting shopper coupons");
        //Call the function that will get current shopper coupons
        [self getShopperCoupons];
    }else{
        //Status label text
        self.messageLabel.text = NSLocalizedString(@"status_label_no_current_offers", @"getting shopper coupons");
        [self hideLoadingView];
    }
}

/* Hide loadingView */
-(void)hideLoadingView
{
    [self.loadingView setHidden:YES];
}

#pragma mark - Get User Coupons
-(void)getShopperCoupons
{
    //Get the current offer (the offer that has status equals "1")
    [[[[ref child:@"captured_coupons"] queryOrderedByChild:@"user_id"] queryEqualToValue:user.uid] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if((unsigned long)snapshot.childrenCount > 0){
            //Firebase returns an array of coupons, Loop through it
            for(FIRDataSnapshot *coupon in snapshot.children) {
                //Check if offer id of this coupon is equal to key of the current available offer
                if([currentAvailableOffer.key isEqualToString:coupon.value[@"offer_id"]]){
                    NSLog(@"User already has coupon for the current offer: %@ -- %@", currentAvailableOffer.key, coupon.value[@"offer_id"]);
                    userCapturedCoupon = coupon;
                    break;
                }
            }
            [self finishGetShopperCoupons:userCapturedCoupon];
        }else{
            [self finishGetShopperCoupons:nil];
        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        [self finishGetShopperCoupons:nil];
    }];
}

/*
 After getting shopper coupons, We should get the current offer coupon image and hide loading view
 Parameters: coupon -- represents shopper coupon of the current available offer -- if nil, shopper hasn't capture the current offer yet!
 */
-(void)finishGetShopperCoupons:(FIRDataSnapshot *)coupon
{
    [self hideLoadingView];
    if(coupon){
        AddedCouponID = coupon.key;
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
                couponImage = [UIImage imageWithData:data];
                self.couponImgView.image = couponImage;
            }
            [self.capturedCouponLoadingIndicator stopAnimating];
        }];
        //Status label text
        if([coupon.value[@"status"] intValue] == [[NSNumber numberWithInt:0] intValue])
            self.messageLabel.text = NSLocalizedString(@"status_label_coupon_ready_no_tweet", @"please tweet");
        else
            self.messageLabel.text = NSLocalizedString(@"status_label_coupon_ready_tweeted", @"tweeted");
    }else{
        userAlreadyCaptured = NO;
        self.captureBTN.enabled = YES;
        self.messageLabel.text = NSLocalizedString(@"status_label_coupon_not_captured", @"please capture");
        NSLog(@"no");
    }
}

/* Capture offer button press action */
- (IBAction)captureOfferAction:(UIButton *)sender {
    if(currentAvailableOffer){
        if(!userAlreadyCaptured){
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }else{
            [self showAlert:NSLocalizedString(@"alert_captured_before_title", @"already captured") andMessage:NSLocalizedString(@"alert_captured_before_message", @"already captured")];
        }
    }else{
        [self showAlert:NSLocalizedString(@"alert_no_offers_title", @"no offers") andMessage:NSLocalizedString(@"alert_no_offers_message", @"no offers")];
    }
    
    
}

/* Back button action */
- (IBAction)backAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/* Tweet button action */
- (IBAction)tweet:(UIButton *)sender
{
    //If user captured the current available offer
    if(userCapturedCoupon){
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *tweetSheet = [SLComposeViewController
                                                   composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:@"Great offer from The Arabian Center #The_Arabian_Center "];
            //If image, add to tweet
            if(couponImage)
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
                        //If tweeted successfully, call the function that updates database and show status to shopper
                        [self tweetSuccessful];
                        break;
                        
                    default:
                        break;
                }
            };
        }
    }else{
        [self showAlert:NSLocalizedString(@"alert_no_captured_coupons_title", @"message") andMessage:NSLocalizedString(@"alert_no_captured_coupons_message", @"title")];
    }
    
}

/* After tweeting, show status to shopper and update shopper coupon in database */
-(void)tweetSuccessful
{
    NSLog(@"AddedCouponID : %@ ", AddedCouponID);
    //Status message
    self.messageLabel.text = NSLocalizedString(@"status_label_coupon_ready_tweeted", @"tweeted");
    //Change coupon status to 1 (Means already shared on social media)
    [[[[ref child:@"captured_coupons"] child:AddedCouponID] child:@"status"] setValue:[NSNumber numberWithInt:1]];
}
#pragma mark - Update offer

/*
 Function that's called after uploading image
 It updates the offer remainig coupons count and status in database
 It adds user coupon to his coupons in database
 */
-(void) updateDatabase
{
    //Update the offer remaining coupons number -1
    NSLog(@"offer : %@", currentAvailableOffer.key);
    int remaining = [currentAvailableOffer.value[@"remaining"] intValue];
    
    //If last coupon, Change offer status to 0 (Expired)
    NSLog(@"captured_valid : %d", remaining);
    if(remaining == 1)
            [[[[ref child:@"Offers"] child:currentAvailableOffer.key] child:@"status"] setValue:[NSNumber numberWithInt:0]];
    
    //Decrement remaining coupons
    remaining --;
    NSNumber *numRemaining = [NSNumber numberWithInt:remaining];
    [[[[ref child:@"Offers"] child:currentAvailableOffer.key] child:@"remaining"] setValue:numRemaining];
    
    //Add new captured offer record
    //Create the coupon with status 0 (means still not shared on social media)
    AddedCouponID = [[ref child:@"captured_coupons"] childByAutoId].key;

    NSDictionary *capturedOffer = @{@"user_id": user.uid,
                                    @"status": [NSNumber numberWithInt:0],
                                    @"offer_id": currentAvailableOffer.key,
                                    @"location":[NSString stringWithFormat:@"%.8f,%.8f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude]};
    NSDictionary *childUpdates = @{[@"/captured_coupons/" stringByAppendingString:AddedCouponID]: capturedOffer};

    [ref updateChildValues:childUpdates];
    [self getShopperCoupons];
    //Status label text
    self.messageLabel.text = @"";
}

/*
 Function that upload captured coupon image to server
 Parameters: capturedImage - representes the image captured by the shopper
 */
-(void)saveImage:(UIImage *)capturedImage{
    if(capturedImage){
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
                                                           //Update database
                                                           [self updateDatabase];
                                                       }
                                                   }];
        
        [self showAlert:NSLocalizedString(@"alert_share_to_claim_title", @"share 2 claim") andMessage:NSLocalizedString(@"alert_share_to_claim_message", @"share 2 claim")];
    }
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
    
    //Status label text
    self.messageLabel.text = NSLocalizedString(@"status_label_coupon_just_captured", @"just_captured");
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
