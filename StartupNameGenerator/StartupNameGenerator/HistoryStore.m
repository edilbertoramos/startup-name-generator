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

static NSString *DATA_MODEL_ENTITY_NAME = @"History";


#pragma mark - Instancetype
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


#pragma mark - Generators Manager
- (BOOL)generateStartupNamesWithKeyword: (NSString *)word
                               withDate: (NSDate *)date
                andNotContainsInHistory: (NSFetchedResultsController *)history {
    if ( ![[KeywordStore sharedStore] wordValidation:word])
        return NO;
    
    self.lastGenerationRunAt = date;
    
    NSInteger countNameGerated = 0;
    NSInteger countAttemptsNameGerated = 0;
    
    while (countNameGerated < 10) {
        
        NSString *startupName = [self generatedName];
        
        if([self verifyStartupNameContains:startupName inHistory:history]){
           
            [self createHistoryWithStartupName:startupName];
            
            NSError *error = nil;
            if ( ![self.managedObjectContext save:&error] )
                NSLog(@"Erro ao salvar históricos. ERROR %@", error.debugDescription);

            countNameGerated++;
        }
        countAttemptsNameGerated++;
        if (countAttemptsNameGerated > 400) {
            return NO;
        }
    }
    return YES;
}


- (NSString *)generatedName
{
    NSString *startupName = nil;

    switch ([self randomWithMax:5]) {
        case 1:
            startupName = [[KeywordStore sharedStore] generateNameWithWordPrefix];
            break;
        case 2:
            startupName = [[KeywordStore sharedStore] generateNameWithWordSuffix];
            break;
        case 3:
            startupName = [[KeywordStore sharedStore] generateNameWithPartialSuffix];
            break;
        case 4:
            startupName = [[KeywordStore sharedStore] generateNameWithMixedWords];
            break;
        default:
            startupName = [[KeywordStore sharedStore] generateCrazyName];
            break;
    }
    
    return startupName;
    
}


- (BOOL)verifyStartupNameContains:(NSString *)name inHistory: (NSFetchedResultsController *)history
{
    for (id object in history.fetchedObjects)
    {
        History *objectHistory = object;

        if ([objectHistory.startupName isEqualToString:name])
        {
            return NO;
        }
    }
    if (name.length > 2)
        return YES;
    return NO;
}
- (NSUInteger)randomWithMax:(NSUInteger)max {
    return (NSUInteger) arc4random_uniform((uint32_t) max);
}



#pragma mark - Persistence methods
- (void)createHistoryWithStartupName:(NSString *)startupName {
    
    History *history = [NSEntityDescription insertNewObjectForEntityForName:DATA_MODEL_ENTITY_NAME
                                                     inManagedObjectContext:self.managedObjectContext];
    history.id = [[[NSUUID alloc] init] UUIDString];
    history.startupName = startupName;
    history.createdAt = self.lastGenerationRunAt;
    history.isFavorite = NO;
    
    NSLog(@"Cretae: %@", history.startupName);

}

- (void)deleteAllHistoryExceptFavorite {
    NSFetchRequest *fetchRequest = [History fetchRequest];
    NSError *error = nil;
    NSArray *historyList = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ( error )
        NSLog(@"Erro ao obter históricos");
    
    for (History *history in historyList) {
        if (!history.isFavorite)
        [self.managedObjectContext deleteObject:history];
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
