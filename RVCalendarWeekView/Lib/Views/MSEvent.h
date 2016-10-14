//
//  AKEvent.h
//  Example
//
//  Created by ak on 18.01.2016.
//  Copyright © 2016 Eric Horacek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DateTools/DTTimePeriod.h>

#define MSEventDefaultReuseIdentifierPostfix @"default"

@interface MSEvent : DTTimePeriod

@property (nonatomic, strong) NSString *reuseIdentifierPostfix;

- (NSDate *)day;

@end