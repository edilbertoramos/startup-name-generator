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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)favoriteAction:(id)sender {
    self.history.isFavorite = !self.history.isFavorite;
    [[HistoryStore sharedStore] saveChanges];
}

- (void)setValuesWithHistory:(History *)historys andIndex:(NSInteger)row
{
    self.labelName.text = [NSString stringWithFormat:@"%@ %@",  self.history.startupName, self.history.createdAt.description] ;
    //self.labelName.text = self.history.startupName;
    [self setImageFavorite:self.history.isFavorite];
    NSLog(@"%ld",(long)self.history.isFavorite);
}

- (void)setImageFavorite:(Boolean)isFavorite
{
    UIImage *image = [UIImage imageNamed:[self imageNamed:isFavorite]];
    image = [self imageWithColor:[UIColor orangeColor] andImage: image];
                      
    [self.buttomFavorite setImage:image forState:UIControlStateNormal];
}

- (NSString *)imageNamed: (Boolean)isFavorite
{
    if (isFavorite)
        return @"favorite_on";
        return @"favorite_off";
}

- (UIImage *)imageWithColor:(UIColor *)color1 andImage:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color1 setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
