//
//  Keyword+CoreDataProperties.h
//  StartupNameGenerator
//
//  Created by Marcelo Moscone on 4/26/17.
//  Copyright © 2017 Agendor. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Keyword+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Keyword (CoreDataProperties)

+ (NSFetchRequest<Keyword *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *type;

@end

NS_ASSUME_NONNULL_END
