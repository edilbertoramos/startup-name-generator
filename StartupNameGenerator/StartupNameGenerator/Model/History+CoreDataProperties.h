//
//  History+CoreDataProperties.h
//  StartupNameGenerator
//
//  Created by Marcelo Moscone on 4/26/17.
//  Copyright © 2017 Agendor. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "History+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface History (CoreDataProperties)

+ (NSFetchRequest<History *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *startupName;
@property (nullable, nonatomic, copy) NSDate *createdAt;

@end

NS_ASSUME_NONNULL_END
