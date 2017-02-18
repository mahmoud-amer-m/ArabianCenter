//
//  SignInViewController.m
//  ArabianCenter
//
//  Created by MacBookPro on 5/20/1438 AH.
//  Copyright © 1438 Amer. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //If there's logged in user, go home
    if ([FIRAuth auth].currentUser) {
        [self performSegueWithIdentifier:@"HomeSegue" sender:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)signInAction:(UIButton *)sender {
    //Validate TextFields
    if([self validateTextFields]){
        //Show loading indicator
        [self.loadingIndicator startAnimating];
        //Firebase Sign in
        [[FIRAuth auth] signInWithEmail:self.emailTF.text
                               password:self.passwordTF.text
                             completion:^(FIRUser *user, NSError *error) {
                                 if(user && !error){
                                     [self finishSignIn:YES];
                                 }else{
                                     [self finishSignIn:NO];
                                 }
                             }];
    }else{
        //Not valid inputs -- Show alert
        UIAlertController *myAlertView = [UIAlertController alertControllerWithTitle:@"Incorrect Data" message:@"Please, fill data properly" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"OK"
                                                             style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                 
                                                             }];
        [myAlertView addAction:doneAction];
        [self presentViewController:myAlertView animated:YES completion:nil];
    }
}

//Method called after firebase sign in, taking BOOL parameter indicates loggedIn status
-(void)finishSignIn:(BOOL)signedIn
{
    //Finish loading indicator
    [self.loadingIndicator stopAnimating];
    //If right sign in, Go home
    if(signedIn)
        [self performSegueWithIdentifier:@"HomeSegue" sender:nil];
    else{
        UIAlertController *myAlertView = [UIAlertController alertControllerWithTitle:@"Something Wrong" message:@"Something Wrong happened" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"OK"
                                                             style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                 
                                                             }];
        [myAlertView addAction:doneAction];
        [self presentViewController:myAlertView animated:YES completion:nil];
    }
        
}
-(BOOL)validateTextFields
{
    BOOL valid = FALSE;
    if(!([self.emailTF.text isEqualToString:@""]) && !([self.passwordTF.text isEqualToString:@""])){
        valid = TRUE;
    }
    return valid;
}
- (IBAction)changeLanguageAction:(UIButton *)sender {
    NSString *targetLanguage = @"";
    if([[[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0] isEqualToString:@"en"])
        targetLanguage = @"ar";
    else
        targetLanguage = @"en";
        
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:targetLanguage, nil] forKey:@"AppleLanguages"]; //switching to other locale
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"current Language: %@", [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0]);
    
}

#pragma mark - Textfields delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}
@end
