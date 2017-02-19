//
//  RegisterViewController.m
//  ArabianCenter
//
//  Created by MacBookPro on 5/20/1438 AH.
//  Copyright © 1438 Amer. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)registerAction:(UIButton *)sender {
    //Validate inputs
    if([self validateTextFields]){
        //Show loading indicator
        self.loadingView.hidden = NO;
        //Firebase registeration
        [[FIRAuth auth]
         createUserWithEmail:self.emailTF.text
         password:self.passwordTF.text
         completion:^(FIRUser *_Nullable user,
                      NSError *_Nullable error) {
             if(!error){
                 NSLog(@"user created : %@", user);
                 [self finishRegisteration:YES];
             }else{
                 NSLog(@"error: %@", error.localizedDescription);
                 [self finishRegisteration:NO];
             }
         }];
    }else{
        UIAlertController *myAlertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"sign_in_data_error_title", @"title") message:NSLocalizedString(@"sign_in_data_error_message", @"massage") preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"OK"
                                                             style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                 
                                                             }];
        [myAlertView addAction:doneAction];
        [self presentViewController:myAlertView animated:YES completion:nil];
    }
}

//Method called after firebase registeration, taking BOOL parameter indicates registeration response status
-(void)finishRegisteration:(BOOL)registered
{
    //End loading indicator
    self.loadingView.hidden = YES;
    //If registered, Go home
    if(registered){
        [self performSegueWithIdentifier:@"homeAfterRegister" sender:nil];
    }else{
        UIAlertController *myAlertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"sign_in_wrong_msg_title", @"title") message:NSLocalizedString(@"sign_in_wrong_msg_message", @"title") preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"OK"
                                                             style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                 
                                                             }];
        [myAlertView addAction:doneAction];
        [self presentViewController:myAlertView animated:YES completion:nil];
    }
}
//Method to validate inputs
-(BOOL)validateTextFields
{
    BOOL valid = FALSE;
    if(!([self.emailTF.text isEqualToString:@""]) && !([self.passwordTF.text isEqualToString:@""]) && !([self.confirmPassTF.text isEqualToString:@""])){
        if([self.passwordTF.text isEqualToString:self.confirmPassTF.text])
            valid = TRUE;
    }
    return valid;
}

- (IBAction)backAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Textfields delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}
@end
