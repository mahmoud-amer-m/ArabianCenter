//
//  RegisterViewController.h
//  ArabianCenter
//
//  Created by MacBookPro on 5/20/1438 AH.
//  Copyright © 1438 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>

@import FirebaseDatabase;
@import FirebaseAuth;

@interface RegisterViewController : UIViewController {
    
}
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassTF;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

- (IBAction)registerAction:(UIButton *)sender;
- (IBAction)backAction:(UIButton *)sender;
@end
