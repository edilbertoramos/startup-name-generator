//
//  StartupNameTableViewCell.m
//  StartupNameGenerator
//
//  Created by EDILBERTO DA SILVA RAMOS JUNIOR on 16/09/17.
//  Copyright © 2017 Agendor. All rights reserved.
//

#import "StartupNameTableViewCell.h"

@implementation StartupNameTableViewCell

static History *history = nil;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)favoriteAction:(id)sender {
    
}

- (void)setValuesWithHistory:(History *)history
{
    self.labelName.text = history.startupName;
    [self setImageFavorite:history.isFavorite];
}

- (void)setImageFavorite:(Boolean)isTrue
{
    [self.buttomFavorite setImage:[UIImage imageNamed:[self name:isTrue]] forState:UIControlStateNormal];
}

- (NSString *)name: (Boolean)isTrue
{
    if (isTrue)
        return @"favorite_on";
        return @"favorite_off";
}
@end
