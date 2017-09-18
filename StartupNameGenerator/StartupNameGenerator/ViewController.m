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
#import "HistoryStore.h"

static NSString *CellIdentifier = @"startupNameCell";

@interface ViewController ()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSDate *lastGenerationRunAt;

@end

@implementation ViewController


static BOOL possibleCombinations = YES;

- (void)viewDidLoad {
    [super viewDidLoad];

    NSError *error;
    if ( ![self.fetchedResultsController performFetch:&error] ) {
        NSLog(@"Erro ao obter histórico. ERRO: %@, %@", error, [error userInfo]);
    }
    
    [self setValues];
}

- (void)setValues{
    self.inputTextField.delegate = self;

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
        if (possibleCombinations){
            self.lastGenerationRunAt = [NSDate date];
            possibleCombinations =  [[HistoryStore sharedStore]
                                     generateStartupNamesWithKeyword:inputText
                                     withDate:self.lastGenerationRunAt
                                     andNotContainsInHistory:self.fetchedResultsController];
        }
        else
            [self showAlertWithMessage:@"Não há mais combinações possíveis"
                         andSuccessful:NO
                           andDuration:[CSToastManager defaultDuration]];
    } else {
        [self showAlertWithMessage:@"Digite ao menos uma palavra"
                     andSuccessful:NO andDuration:[CSToastManager
                                                   defaultDuration]];
    }
    [self.view endEditing:TRUE];
}

- (IBAction)cleanupButtonTapped:(id)sender {
    [[HistoryStore sharedStore] deleteAllHistoryExceptFavorite];
    possibleCombinations = YES;
}


#pragma mark - UITableViewDataSource methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    StartupNameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.history = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.lastGeneratedDate = self.lastGenerationRunAt;
    [cell setValuesWithHistory:[self.fetchedResultsController objectAtIndexPath:indexPath]
                      andIndex:indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedResultsController.fetchedObjects count];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    possibleCombinations = YES;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self dismissKeyboard];
    return YES;
}

#pragma mark - Utils
- (void)showAlertWithMessage:(NSString *)message
               andSuccessful: (BOOL)success
                 andDuration: (NSTimeInterval)duration{
    
    CSToastStyle *toastStyle = [[CSToastStyle alloc] initWithDefaultStyle];
    if (success)
        toastStyle.backgroundColor = UIColor.orangeColor;
    else
        toastStyle.backgroundColor = UIColor.redColor;
    [self.view makeToast:message
                duration:duration
                position:[CSToastManager defaultPosition]
                   style:toastStyle];
}

-(void)changedFavoriteWithOn: (BOOL)isFavorite{
    if(isFavorite)
        [self showAlertWithMessage:@"Favorito adicionado" andSuccessful:YES andDuration:1];
    else
        [self showAlertWithMessage:@"Favorito removido" andSuccessful:YES andDuration:1];
    
    [self dismissKeyboard];
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
    StartupNameTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];

            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            cell.history = [self.fetchedResultsController objectAtIndexPath:indexPath];
            cell.lastGeneratedDate = self.lastGenerationRunAt;
            [cell setValuesWithHistory:[self.fetchedResultsController objectAtIndexPath:indexPath]
                              andIndex:indexPath.row];
            [self changedFavoriteWithOn:cell.history.isFavorite];

            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self changedFavoriteWithOn:cell.history.isFavorite];

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
    NSSortDescriptor *sortFavorite = [[NSSortDescriptor alloc] initWithKey:@"isFavorite" ascending:NO];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    fetchRequest.sortDescriptors = @[sortFavorite, sortDescriptor];
    fetchRequest.fetchBatchSize = 20;

    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:context
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:@"StartupNamesCache"];
    self.fetchedResultsController = fetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

@end
