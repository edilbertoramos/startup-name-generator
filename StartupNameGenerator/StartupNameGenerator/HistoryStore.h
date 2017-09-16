//
//  HistoryStore.h
//  StartupNameGenerator
//
//  Created by EDILBERTO DA SILVA RAMOS JUNIOR on 16/09/17.
//  Copyright © 2017 Agendor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "History+CoreDataClass.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "Keyword+CoreDataClass.h"

@interface HistoryStore : NSObject

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

+ (instancetype)sharedStore;

- (void)generateStartupNamesWithKeyword: (NSString *)word;
- (void)deleteAllHistory;
- (BOOL)saveChanges;

@end
