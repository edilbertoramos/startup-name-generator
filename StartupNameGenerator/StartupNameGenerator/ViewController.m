//
//  ViewController.m
//  StartupNameGenerator
//
//  Created by Marcelo Moscone on 4/25/17.
//  Copyright © 2017 Agendor. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Keyword+CoreDataClass.h"
#import "History+CoreDataClass.h"
#import <Toast/UIView+Toast.h>
#import "StartupNameTableViewCell.h"

typedef enum {
    WordPrefix = 1,
    WordSuffix,
    PartialSuffix
} KeywordType;

static NSString *CellIdentifier = @"startupNameCell";

@interface ViewController ()
@property (strong, nonatomic) NSArray *words;
@property (strong, nonatomic) NSDate *lastGenerationRunAt;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSError *error;
    if ( ![self.fetchedResultsController performFetch:&error] ) {
        NSLog(@"Erro ao obter histórico. ERRO: %@, %@", error, [error userInfo]);
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGestureRecognizer];

}

- (void)dismissKeyboard {
    [self.view endEditing:TRUE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action methods
- (IBAction)generateButtonTapped:(id)sender {
    NSString *inputText = [self.inputTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ( inputText && inputText.length > 0 ) {
        self.words = [inputText componentsSeparatedByString:@" "];
        [self generateStartupNames];

    } else {
        [self showErrorToast:@"Digite ao menos uma palavra"];
    }
    [self.view endEditing:TRUE];

}

- (IBAction)cleanupButtonTapped:(id)sender {
    [self deleteAllHistory];
}

#pragma mark - Generators
- (void)generateStartupNames {
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

#pragma mark - UITableViewDataSource methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    //static NSString *CellIdentifier = @"startupNameCell";..
    StartupNameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedResultsController.fetchedObjects count];
}

#pragma mark - Utils
- (void)configureCell:(StartupNameTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    History *history = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.labelName.text = history.startupName;
}

- (BOOL)hasAnyWord {
    return self.words && self.words.count > 0;
}

- (BOOL)hasOnlyOneWord {
    return self.words && self.words.count == 1;
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

- (void)showErrorToast:(NSString *)message {
    CSToastStyle *toastStyle = [[CSToastStyle alloc] initWithDefaultStyle];
    toastStyle.backgroundColor = UIColor.redColor;

    [self.view makeToast:message
                duration:[CSToastManager defaultDuration]
                position:[CSToastManager defaultPosition]
                   style:toastStyle];
}

#pragma mark - Persistence methods
- (void)createHistoryWithStartupName:(NSString *)startupName {
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;

    History *history = [NSEntityDescription insertNewObjectForEntityForName:@"History"
                                                     inManagedObjectContext:context];
    history.startupName = startupName;
    history.createdAt = [NSDate date];
    history.isFavorite = FALSE;
}

- (void)deleteAllHistory {
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;

    NSFetchRequest *fetchRequest = [History fetchRequest];
    NSError *error = nil;
    NSArray *historyList = [context executeFetchRequest:fetchRequest error:&error];

    if ( error )
        NSLog(@"Erro ao obter históricos");

    for (History *history in historyList) {
        [context deleteObject:history];
    }
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

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

    UITableView *tableView = self.tableView;

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        default:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - Getters & setters
- (NSFetchedResultsController *)fetchedResultsController {

    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;

    NSFetchRequest *fetchRequest = [History fetchRequest];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    fetchRequest.fetchBatchSize = 20;

    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:context
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:@"StartupNamesCache"];
    self.fetchedResultsController = fetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (NSDate *)lastGenerationRunAt {
    if ( self.lastGenerationRunAt )
        return self.lastGenerationRunAt;
    return [NSDate date];
}



@end
