//
//  StartupNameTableViewCell.m
//  StartupNameGenerator
//
//  Created by EDILBERTO DA SILVA RAMOS JUNIOR on 16/09/17.
//  Copyright © 2017 Agendor. All rights reserved.
//

#import "StartupNameTableViewCell.h"
#import "HistoryStore.h"

@implementation StartupNameTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.labelName.text = self.history.startupName;
    [self setImageFavorite:self.history.isFavorite];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)favoriteAction:(id)sender {
    
    printf("\n\n");
    NSLog(@"\n%d", self.history.isFavorite);
    NSLog(@"\n%@", self.history.startupName.description);
    self.history.isFavorite = !self.history.isFavorite;
    
    [[HistoryStore sharedStore] saveChanges];


}

- (void)setValuesWithHistory:(History *)historys andIndex:(NSInteger)row
{
    self.labelName.text = self.history.startupName;
    [self setImageFavorite:self.history.isFavorite];
    

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
