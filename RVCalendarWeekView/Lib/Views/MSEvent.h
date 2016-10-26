//
//  AKEvent.h
//  Example
//
//  Created by ak on 18.01.2016.
//  Copyright © 2016 Eric Horacek. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MSEventDefaultReuseIdentifierPostfix @"default"

@interface MSEvent : NSObject

@property (nonatomic, strong) NSString *reuseIdentifierPostfix;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic) BOOL hasStartTime;
@property (nonatomic) BOOL hasEndTime;

+ (instancetype)make:(NSDate *)start;
+ (instancetype)make:(NSDate *)start end:(NSDate *)end;
+ (instancetype)make:(NSDate *)start end:(NSDate *)end hasStartTime:(BOOL)hasStartTime hasEndTime:(BOOL)hasEndTime;

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate hasStartTime:(BOOL)hasStartTime hasEndTime:(BOOL)hasEndTime;

- (NSDate *)day;

@end