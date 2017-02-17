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
    if ([FIRAuth auth].currentUser) {
        NSLog(@"logged User : %@", [FIRAuth auth].currentUser);
        //        FIRUser *user = [FIRAuth auth].currentUser;
        //        NSLog(@"email %@", user.providerData);
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
    [self.loadingIndicator startAnimating];
    [[FIRAuth auth] signInWithEmail:self.emailTF.text
                           password:self.passwordTF.text
                         completion:^(FIRUser *user, NSError *error) {
                             NSLog(@"User : %@", user);
                             NSLog(@"email %@", user.providerID);
                             NSLog(@"error : %@", error);
                             if(user && !error){
                                 [self finishSignIn:YES];
                             }else{
                                 [self finishSignIn:NO];
                             }
                         }];
    
}
-(void)finishSignIn:(BOOL)signedIn
{
    [self.loadingIndicator stopAnimating];
    if(signedIn)
        [self performSegueWithIdentifier:@"HomeSegue" sender:nil];
    
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
    
    // Reload our root view controller
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSString *storyboardName = @"Main"; // Your storyboard name
    UIStoryboard *storybaord = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    delegate.window.rootViewController = [storybaord instantiateInitialViewController];
}
@end
