//
//  BusinessCell.m
//  Yelp
//
//  Created by Austin Oh on 1/28/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "BusinessCell.h"
#import "UIImageView+AFNetworking.h"

@interface BusinessCell ()

@property (weak, nonatomic) IBOutlet UIImageView *thumImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImageView;
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@end

@implementation BusinessCell

- (void)awakeFromNib {
    // Initialization code
    
    self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
    self.thumImageView.layer.cornerRadius = 3;
    self.thumImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBusiness:(Business *)business {
    _business = business;

    [self.thumImageView setImageWithURL:[NSURL URLWithString:self.business.imageUrl]];
    self.nameLabel.text = self.business.businessName;
    [self.ratingImageView setImageWithURL:[NSURL URLWithString:self.business.ratingImageUrl]];
    self.reviewLabel.text = [NSString stringWithFormat:@"%ld Reviews", self.business.numReviews];
    self.addressLabel.text = self.business.address;
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", self.business.distance];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
     self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
}

@end
