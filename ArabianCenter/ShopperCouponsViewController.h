//
//  ShopperCouponsViewController.h
//  ArabianCenter
//
//  Created by MacBookPro on 2/21/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
@import FirebaseDatabase;
@import FirebaseAuth;

#import "couponCustomCellTableViewCell.h"

@interface ShopperCouponsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    FIRUser *user;
    FIRDatabaseReference *ref;
    
    NSMutableArray *userCoupons;
    
    IBOutlet couponCustomCellTableViewCell *resultCell;
}
@property (weak, nonatomic) IBOutlet UITableView *couponsTableView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

- (IBAction)backAction:(UIButton *)sender;
@end
