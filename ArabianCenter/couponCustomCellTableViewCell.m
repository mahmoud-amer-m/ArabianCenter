//
//  couponCustomCellTableViewCell.m
//  ArabianCenter
//
//  Created by MacBookPro on 2/21/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "couponCustomCellTableViewCell.h"

@implementation couponCustomCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)getCouponImage:(NSString *)uid andOffer:(NSString *)offerID{
    //Show current offer coupon image of the logged in user
    // Points to the root reference
    [self.loadingImage startAnimating];
    FIRStorageReference *storageRef = [[FIRStorage storage] reference];
    // Points to "images"
    NSString *fileName = [NSString stringWithFormat:@"%@/%@.png",uid, offerID];
    
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
        [self.loadingImage stopAnimating];
    }];
}

#pragma mark - Photo Request
-(void)getPhotoWithPath:(NSString *)photoPath{
    @autoreleasepool {
        
    }
}
-(void)finishGetPhoto:(NSData *)photoData{
    if(photoData){
        UIImage *image = [UIImage imageWithData:photoData];
        self.couponImgView.image = image;
    }else{
        //TODO - Set Default Image Here
    }
}

@end
