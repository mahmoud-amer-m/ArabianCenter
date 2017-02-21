//
//  ShopperCouponsViewController.m
//  ArabianCenter
//
//  Created by MacBookPro on 2/21/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "ShopperCouponsViewController.h"

@interface ShopperCouponsViewController ()

@end

@implementation ShopperCouponsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Firebase Reference
    if(!ref)
        ref = [[FIRDatabase database] reference];
    
    //Logged in user
    user = [FIRAuth auth].currentUser;
    
    if(!userCoupons)
        userCoupons = [[NSMutableArray alloc] init];
    
    [self getUserCoupons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Get User Coupons
-(void)getUserCoupons
{
    //Get the current offer (the offer that has status equals "1")
    [[[[ref child:@"captured_coupons"] queryOrderedByChild:@"user_id"] queryEqualToValue:user.uid] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"-- %@", snapshot.children);
        if((unsigned long)snapshot.childrenCount > 0){
            for(FIRDataSnapshot *offer in snapshot.children) {
                [userCoupons addObject:offer];
            }
            NSLog(@"-- %@", userCoupons);
            [self.couponsTableView reloadData];
        }
        [self.loadingView setHidden:YES];
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"error %@", error.localizedDescription);
        [self.loadingView setHidden:YES];
    }];
}

#pragma mark - TableView
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 79;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userCoupons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CouponsTableCellIdentifier = @"CouponsTableCell";
    
    couponCustomCellTableViewCell *cell = (couponCustomCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CouponsTableCellIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"couponCustomCellTableViewCell" owner:self options:nil];
        cell = resultCell;
    }
    FIRDataSnapshot *offer = [userCoupons objectAtIndex:indexPath.row];
    cell.offerTitle.text = offer.value[@"offer_id"];
    cell.couponStatusLabel.text = offer.value[@"status"];
    int status = [offer.value[@"status"] intValue];
    switch (status) {
        case 0:
            cell.couponStatusLabel.text = NSLocalizedString(@"waiting_tweer_status", @"ready to claim");
            break;
        case 1:
            cell.couponStatusLabel.text = NSLocalizedString(@"ready_to_claim_status", @"ready to claim");
            break;
        default:
            cell.couponStatusLabel.text = NSLocalizedString(@"waiting_tweer_status", @"ready to claim");
            break;
    }
    [cell getCouponImage:user.uid andOffer:offer.value[@"offer_id"]];
//    cell.textLabel.text = [recipes objectAtIndex:indexPath.row];
    return cell;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
