//
//  HistoryStore.m
//  StartupNameGenerator
//
//  Created by EDILBERTO DA SILVA RAMOS JUNIOR on 16/09/17.
//  Copyright © 2017 Agendor. All rights reserved.
//

#import "HistoryStore.h"

@interface HistoryStore ()

@property (strong, nonatomic) NSDate *lastGenerationRunAt;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation HistoryStore

+ (instancetype)sharedStore {
    static HistoryStore *sharedStore = nil;
    
    if (!sharedStore) {
        AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
        
        sharedStore = [[self alloc] initPrivate];
        sharedStore.managedObjectContext = appDelegate.persistentContainer.viewContext;
    }
    return sharedStore;
}

- (instancetype)initPrivate {
    self = [super init];
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[HistoryStore sharedStore]"
                                 userInfo:nil];
}


#pragma mark - Generators
- (void)generateStartupNamesWithKeyword: (NSString *)word withDate: (NSDate *)date{
    if ( ![[KeywordStore sharedStore] wordValidation:word])
        return;
    
    self.lastGenerationRunAt = date;
    
    [self createHistoryWithStartupName:[[KeywordStore sharedStore] generateNameWithWordPrefix]];
    [self createHistoryWithStartupName:[[KeywordStore sharedStore] generateNameWithWordPrefix]];
    [self createHistoryWithStartupName:[[KeywordStore sharedStore] generateNameWithWordSuffix]];
    [self createHistoryWithStartupName:[[KeywordStore sharedStore] generateNameWithPartialSuffix]];
    [self createHistoryWithStartupName:[[KeywordStore sharedStore] generateNameWithPartialSuffix]];
    [self createHistoryWithStartupName:[[KeywordStore sharedStore] generateNameWithPartialSuffix]];
    [self createHistoryWithStartupName:[[KeywordStore sharedStore] generateNameWithMixedWords]];
    [self createHistoryWithStartupName:[[KeywordStore sharedStore] generateNameWithMixedWords]];
    [self createHistoryWithStartupName:[[KeywordStore sharedStore] generateNameWithMixedWords]];
    [self createHistoryWithStartupName:[[KeywordStore sharedStore] generateCrazyName]];
    
    NSError *error = nil;
    if ( ![self.managedObjectContext save:&error] )
        NSLog(@"Erro ao salvar históricos. ERROR %@", error.debugDescription);
    
}


#pragma mark - Persistence methods
- (void)createHistoryWithStartupName:(NSString *)startupName {
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    History *history = [NSEntityDescription insertNewObjectForEntityForName:@"History"
                                                     inManagedObjectContext:context];
    history.id = [[[NSUUID alloc] init] UUIDString];
    history.startupName = startupName;
    history.createdAt = self.lastGenerationRunAt;
    history.isFavorite = NO;
}

- (void)deleteAllHistoryExceptFavorite {
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    NSFetchRequest *fetchRequest = [History fetchRequest];
    NSError *error = nil;
    NSArray *historyList = [context executeFetchRequest:fetchRequest error:&error];
    
    if ( error )
        NSLog(@"Erro ao obter históricos");
    
    for (History *history in historyList) {
        if (!history.isFavorite)
        [context deleteObject:history];
    }
}

- (void)saveChanges {
    NSError *error;
    
    if ([self.managedObjectContext hasChanges]) {
        BOOL successful = [self.managedObjectContext save:&error];
        
        if (!successful) {
            NSLog(@"Error saving: %@", [error localizedDescription]);
        }
    }
}


@end
