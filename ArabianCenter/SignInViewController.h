//
//  SignInViewController.h
//  ArabianCenter
//
//  Created by MacBookPro on 5/20/1438 AH.
//  Copyright © 1438 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>

@import FirebaseAuth;

#import "AppDelegate.h"

@interface SignInViewController : UIViewController {
    
    
}

@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;


- (IBAction)signInAction:(UIButton *)sender;
- (IBAction)changeLanguageAction:(UIButton *)sender;

@end
