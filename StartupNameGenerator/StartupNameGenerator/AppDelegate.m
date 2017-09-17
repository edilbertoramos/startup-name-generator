//
//  AppDelegate.m
//  StartupNameGenerator
//
//  Created by Marcelo Moscone on 4/25/17.
//  Copyright © 2017 Agendor. All rights reserved.
//

#import "AppDelegate.h"
#import "Keyword+CoreDataClass.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self verifyIfKeywordsIsPopulated];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"StartupNameGenerator"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

#pragma mark - pre-populate keyword list

- (void)verifyIfKeywordsIsPopulated {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [Keyword fetchRequest];
    fetchRequest.includesSubentities = NO;
    fetchRequest.returnsObjectsAsFaults = NO;

    NSUInteger keywordsCount = [context countForFetchRequest:fetchRequest error:&error];

    if ( error )
        NSLog(@"Erro ao verificar quantidade de palavras-chave. ERROR %@", error.debugDescription);

    if ( keywordsCount > 0 )
        return;

    [self populateKeywordList];
}

- (void)populateKeywordList {

    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    NSString *keywordListFilePath = [[NSBundle mainBundle] pathForResource:@"keyword-list" ofType:@"csv"];
    if ( !keywordListFilePath )
        return;

    NSString *fileContents = [NSString stringWithContentsOfFile:keywordListFilePath
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];

    if ( error )
        NSLog(@"Não foi possível acessar o arquivo da lista de palavras-chave. ERROR %@", error.debugDescription);

    NSArray *rows = [fileContents componentsSeparatedByString:@"\n"];
    printf("%lu", (unsigned long)rows.count);
    for (NSString *row in rows) {
        NSArray* columns = [row componentsSeparatedByString:@","];
        NSString *name = columns[0];
        NSString *type = columns[1];

        Keyword *keyword = [NSEntityDescription insertNewObjectForEntityForName:@"Keyword"
                                                 inManagedObjectContext:context];
        keyword.name = name;
        keyword.type = [NSNumber numberWithInteger:type.integerValue];
    }

    error = nil;
    if ( ![context save:&error] )
        NSLog(@"Erro ao popular palavras-chave. ERROR %@", error.debugDescription);
    
    [context reset];
}

@end
