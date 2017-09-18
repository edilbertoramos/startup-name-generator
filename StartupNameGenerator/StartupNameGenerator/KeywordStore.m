//
//  KeywordStore.m
//  StartupNameGenerator
//
//  Created by EDILBERTO DA SILVA RAMOS JUNIOR on 17/09/17.
//  Copyright © 2017 Agendor. All rights reserved.
//

#import "KeywordStore.h"

typedef enum {
    WordPrefix = 1,
    WordSuffix,
    PartialSuffix
} KeywordType;

@interface KeywordStore()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (strong, nonatomic) NSArray *words;

@end

@implementation KeywordStore

#pragma mark - Instancetype

+ (instancetype)sharedStore {
    static KeywordStore *sharedStore = nil;
    
    if (!sharedStore) {
        AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
        
        sharedStore = [[self alloc] initPrivate];
        sharedStore.managedObjectContext = appDelegate.persistentContainer.viewContext;
        
        sharedStore.fetchRequest = [Keyword fetchRequest];
    }
    return sharedStore;
}

- (instancetype)initPrivate {
    self = [super init];
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[KeywordStore sharedStore]"
                                 userInfo:nil];
}



#pragma mark - Utils

- (BOOL)hasAnyWord {
    return self.words && self.words.count > 0;
}

- (BOOL)hasOnlyOneWord {
    return self.words && self.words.count == 1;
}

- (BOOL)wordValidation: (NSString *)word {
    self.words = [word componentsSeparatedByString:@" "];
    if ( ![self hasAnyWord] )
        return NO;
    return YES;

}




#pragma mark - Generators

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

- (nonnull NSString *)generateNameWithMixedWords {
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

- (nonnull NSString *)generateCrazyName {
    if ( ![self hasAnyWord] )
        return nil;
    
    NSString *word = [self randomWord];
    NSString *suffix = [self randomPartialSuffix];
    
    NSCharacterSet *vowelCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"aáãeêéiíoõuy"];
    NSString *unvowelWord = [[word componentsSeparatedByCharactersInSet:vowelCharacterSet] componentsJoinedByString:@""];
    
    return [unvowelWord stringByAppendingString:suffix];
}




#pragma mark - Find


- (NSArray *)findWordPrefixes {
    self.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"type == %@", @(WordPrefix)];
    
    NSError *error = nil;
    NSArray *keywords = [self.managedObjectContext executeFetchRequest:self.fetchRequest error:&error];
    
    if ( error )
        NSLog(@"Erro ao obter palavras-chave do tipo %d", WordPrefix);
    
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

- (NSArray *)findWordPrefixesAndSuffixes {
    self.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"type == %@ OR type == %@", @(WordPrefix), @(WordSuffix)];
    
    NSError *error = nil;
    NSArray *keywords = [self.managedObjectContext executeFetchRequest:self.fetchRequest error:&error];
    
    if ( error )
        NSLog(@"Erro ao obter palavras-chave dos tipos %d e %d", WordPrefix, WordSuffix);
    
    if ( !keywords )
        return [NSArray new];
    
    return keywords;
}


- (NSArray *)findWordSuffixes {
    self.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"type == %@", @(WordSuffix)];
    
    NSError *error = nil;
    NSArray *keywords = [self.managedObjectContext executeFetchRequest:self.fetchRequest error:&error];
    
    if ( error )
        NSLog(@"Erro ao obter palavras-chave do tipo %d", WordSuffix);
    
    if ( !keywords )
        return [NSArray new];
    
    return keywords;
}

- (NSArray *)findPartialSuffixes {
    self.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"type == %@", @(PartialSuffix)];
    
    NSError *error = nil;
    NSArray *keywords = [self.managedObjectContext executeFetchRequest:self.fetchRequest error:&error];
    
    if ( error )
        NSLog(@"Erro ao obter palavras-chave do tipo %d", PartialSuffix);
    
    if ( !keywords )
        return [NSArray new];
    
    return keywords;
}

@end
