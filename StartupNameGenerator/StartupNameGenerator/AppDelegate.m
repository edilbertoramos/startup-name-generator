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
    // Override point for customization after application launch.
    [self verifyIfKeywordsIsPopulated];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"StartupNameGenerator"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
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
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
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
