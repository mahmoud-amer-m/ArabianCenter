//
//  couponCustomCellTableViewCell.h
//  ArabianCenter
//
//  Created by MacBookPro on 2/21/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>

@import FirebaseStorage;

@interface couponCustomCellTableViewCell : UITableViewCell {
    
}
@property (weak, nonatomic) IBOutlet UIImageView *couponImgView;
@property (weak, nonatomic) IBOutlet UILabel *offerTitle;
@property (weak, nonatomic) IBOutlet UILabel *offerStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponStatusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingImage;

-(void)getCouponImage:(NSString *)uid andOffer:(NSString *)offerID;

@end
