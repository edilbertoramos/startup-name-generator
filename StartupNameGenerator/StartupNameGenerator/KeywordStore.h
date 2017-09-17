//
//  KeywordStore.h
//  StartupNameGenerator
//
//  Created by EDILBERTO DA SILVA RAMOS JUNIOR on 17/09/17.
//  Copyright © 2017 Agendor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "Keyword+CoreDataClass.h"

@interface KeywordStore : NSObject


+ (instancetype)sharedStore;

- (BOOL)wordValidation: (NSString *)word;

- (nonnull NSString *)generateNameWithWordPrefix;
- (nonnull NSString *)generateNameWithWordSuffix;
- (nonnull NSString *)generateNameWithPartialSuffix;
- (nonnull NSString *)generateNameWithMixedWords;
- (nonnull NSString *)generateCrazyName;


@end
