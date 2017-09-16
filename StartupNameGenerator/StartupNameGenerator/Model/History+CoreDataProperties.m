//
//  History+CoreDataProperties.m
//  StartupNameGenerator
//
//  Created by Marcelo Moscone on 4/26/17.
//  Copyright © 2017 Agendor. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "History+CoreDataProperties.h"

@implementation History (CoreDataProperties)

+ (NSFetchRequest<History *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"History"];
}

@dynamic startupName;
@dynamic createdAt;

@end
