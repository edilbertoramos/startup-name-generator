//
//  HistoryStore.m
//  StartupNameGenerator
//
//  Created by EDILBERTO DA SILVA RAMOS JUNIOR on 16/09/17.
//  Copyright © 2017 Agendor. All rights reserved.
//

#import "HistoryStore.h"

typedef enum {
    WordPrefix = 1,
    WordSuffix,
    PartialSuffix
} KeywordType;

@interface HistoryStore ()

@property (strong, nonatomic) NSArray *words;
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

- (BOOL)hasAnyWord {
    return self.words && self.words.count > 0;
}

- (BOOL)hasOnlyOneWord {
    return self.words && self.words.count == 1;
}

#pragma mark - Generators
- (void)generateStartupNamesWithKeyword: (NSString *)word {
    self.words = [word componentsSeparatedByString:@" "];
    if ( ![self hasAnyWord] )
        return;
    
    self.lastGenerationRunAt = [NSDate date];
    
    [self createHistoryWithStartupName:[self generateNameWithWordPrefix]];
    [self createHistoryWithStartupName:[self generateNameWithWordPrefix]];
    [self createHistoryWithStartupName:[self generateNameWithWordSuffix]];
    [self createHistoryWithStartupName:[self generateNameWithPartialSuffix]];
    [self createHistoryWithStartupName:[self generateNameWithPartialSuffix]];
    [self createHistoryWithStartupName:[self generateNameWithPartialSuffix]];
    [self createHistoryWithStartupName:[self generateNameWithMixedWords]];
    [self createHistoryWithStartupName:[self generateNameWithMixedWords]];
    [self createHistoryWithStartupName:[self generateNameWithMixedWords]];
    [self createHistoryWithStartupName:[self generateCrazyName]];
    
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    NSError *error = nil;
    if ( ![context save:&error] )
        NSLog(@"Erro ao salvar históricos. ERROR %@", error.debugDescription);
    
}

- (nonnull NSString *)generateNameWithWordPrefix {
    NSString *word = [self randomWord];
    NSString *prefix = [self randomWordPrefix];
    
    return [NSString stringWithFormat:@"%@ %@", prefix, word];
}

- (nonnull NSString *)generateNameWithWordSuffix {
    NSString *word = [self randomWord];
    NSString *suffix = [self randomWordSuffix];
    
    return [NSString stringWithFormat:@"%@ %@", word, suffix];
}

- (nonnull NSString *)generateNameWithPartialSuffix {
    NSString *word = [self randomWord];
    NSString *suffix = [self randomPartialSuffix];
    
    return [word stringByAppendingString:suffix];
}

- (NSString *)generateNameWithMixedWords {
    NSString *word = [self randomWord];
    NSString *suffix = [self randomWordToMix];
    
    NSString *firstWord = [[NSString alloc] init];
    switch (word.length) {
        case 1:
            firstWord = [word substringToIndex:word.length-1];
            break;
            
        default:
            firstWord = [word substringToIndex:word.length-2];
            break;
    }
    NSString *secondWord = [suffix substringFromIndex:1];
    
    return [firstWord stringByAppendingString:secondWord];
}

- (NSString *)generateCrazyName {
    if ( ![self hasAnyWord] )
        return nil;
    
    NSString *word = [self randomWord];
    NSString *suffix = [self randomPartialSuffix];
    
    NSCharacterSet *vowelCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"aáãeêéiíoõuy"];
    NSString *unvowelWord = [[word componentsSeparatedByCharactersInSet:vowelCharacterSet] componentsJoinedByString:@""];
    
    return [unvowelWord stringByAppendingString:suffix];
}

- (NSArray *)findWordPrefixes {
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    NSFetchRequest *fetchRequest = [Keyword fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"type == %@", @(WordPrefix)];
    
    NSError *error = nil;
    NSArray *keywords = [context executeFetchRequest:fetchRequest error:&error];
    
    if ( error )
        NSLog(@"Erro ao obter palavras-chave do tipo %d", WordPrefix);
    
    if ( !keywords )
        return [NSArray new];
    
    return keywords;
}

- (NSArray *)findWordPrefixesAndSuffixes {
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    NSFetchRequest *fetchRequest = [Keyword fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"type == %@ OR type == %@", @(WordPrefix), @(WordSuffix)];
    
    NSError *error = nil;
    NSArray *keywords = [context executeFetchRequest:fetchRequest error:&error];
    
    if ( error )
        NSLog(@"Erro ao obter palavras-chave dos tipos %d e %d", WordPrefix, WordSuffix);
    
    if ( !keywords )
        return [NSArray new];
    
    return keywords;
}


- (NSArray *)findWordSuffixes {
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    NSFetchRequest *fetchRequest = [Keyword fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"type == %@", @(WordSuffix)];
    
    NSError *error = nil;
    NSArray *keywords = [context executeFetchRequest:fetchRequest error:&error];
    
    if ( error )
        NSLog(@"Erro ao obter palavras-chave do tipo %d", WordSuffix);
    
    if ( !keywords )
        return [NSArray new];
    
    return keywords;
}

- (NSArray *)findPartialSuffixes {
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    NSFetchRequest *fetchRequest = [Keyword fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"type == %@", @(PartialSuffix)];
    
    NSError *error = nil;
    NSArray *keywords = [context executeFetchRequest:fetchRequest error:&error];
    
    if ( error )
        NSLog(@"Erro ao obter palavras-chave do tipo %d", PartialSuffix);
    
    if ( !keywords )
        return [NSArray new];
    
    return keywords;
}

- (nonnull NSString *)randomWord {
    NSString *word = nil;
    if ( [self hasOnlyOneWord] ) {
        word = self.words.firstObject;
    } else {
        NSUInteger index = [self randomWithMax:self.words.count];
        word = self.words[index];
    }
    return word;
}

- (nonnull NSString *)randomWordPrefix {
    NSArray<Keyword *> *prefixes = [self findWordPrefixes];
    NSUInteger index = [self randomWithMax:prefixes.count];
    return prefixes[index].name;
}

- (nonnull NSString *)randomWordSuffix {
    NSArray<Keyword *> *suffixes = [self findWordSuffixes];
    NSUInteger index = [self randomWithMax:suffixes.count];
    return suffixes[index].name;
}

- (nonnull NSString *)randomPartialSuffix {
    NSArray<Keyword *> *suffixes = [self findPartialSuffixes];
    NSUInteger index = [self randomWithMax:suffixes.count];
    return suffixes[index].name;
}

- (nonnull NSString *)randomWordToMix {
    NSArray<Keyword *> *words = [self findWordPrefixesAndSuffixes];
    NSUInteger index = [self randomWithMax:words.count];
    return words[index].name;
}

- (NSUInteger)randomWithMax:(NSUInteger)max {
    return (NSUInteger) arc4random_uniform((uint32_t) max);
}

#pragma mark - Persistence methods
- (void)createHistoryWithStartupName:(NSString *)startupName {
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    History *history = [NSEntityDescription insertNewObjectForEntityForName:@"History"
                                                     inManagedObjectContext:context];
    history.id = [[[NSUUID alloc] init] UUIDString];
    history.startupName = startupName;
    history.createdAt = [NSDate date];
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


- (NSDate *)lastGenerationRunAt {
    if ( self.lastGenerationRunAt )
        return self.lastGenerationRunAt;
    return [NSDate date];
}


@end
