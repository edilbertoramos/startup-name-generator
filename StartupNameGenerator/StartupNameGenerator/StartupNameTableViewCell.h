//
//  StartupNameTableViewCell.h
//  StartupNameGenerator
//
//  Created by EDILBERTO DA SILVA RAMOS JUNIOR on 16/09/17.
//  Copyright © 2017 Agendor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "History+CoreDataClass.h"

@interface StartupNameTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UIButton *buttomFavorite;

- (void)setValuesWithHistory:(History *)history;

@end
