//
//  AKEvent.m
//  Example
//
//  Created by ak on 18.01.2016.
//  Copyright © 2016 Eric Horacek. All rights reserved.
//

#import "MSEvent.h"
#import "NSDate+Easy.h"

@implementation MSEvent

+ (instancetype)make:(NSDate *)start {
    return [self make:start end:nil];
}

+ (instancetype)make:(NSDate *)start end:(NSDate *)end {
    return [self make:start end:end hasStartTime:true hasEndTime:true isSometimeEvent:false isUserCreated:false];
}

+ (instancetype)make:(NSDate *)start end:(NSDate *)end hasStartTime:(BOOL)hasStartTime hasEndTime:(BOOL)hasEndTime isSometimeEvent:(BOOL)isSometimeEvent isUserCreated:(BOOL)isUserCreated {
    return [[self alloc] initWithStartDate:start endDate:end hasStartTime:hasStartTime hasEndTime:hasEndTime isSometimeEvent:isSometimeEvent isUserCreated:isUserCreated];
}

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate hasStartTime:(BOOL)hasStartTime hasEndTime:(BOOL)hasEndTime isSometimeEvent:(BOOL)isSometimeEvent isUserCreated:(BOOL)isUserCreated {
    if (self = [super init]) {
        self.reuseIdentifierPostfix = MSEventDefaultReuseIdentifierPostfix;
        self.startDate = startDate;
        self.endDate = endDate;
        self.hasStartTime = hasStartTime;
        self.hasEndTime = hasEndTime;
        self.isSometimeEvent = isSometimeEvent;
        self.isUserCreated = isUserCreated;
    }
    return self;
}

- (NSDate *)day {
    return [NSCalendar.currentCalendar startOfDayForDate:self.startDate];
}

- (id)copyWithZone:(NSZone *)zone {
    MSEvent *newEvent = [[[self class] allocWithZone:zone] init];
    
    newEvent.reuseIdentifierPostfix = [self.reuseIdentifierPostfix copyWithZone:zone];
    newEvent.startDate = [self.startDate copyWithZone:zone];
    newEvent.endDate = [self.endDate copyWithZone:zone];
    newEvent.hasStartTime = self.hasStartTime;
    newEvent.hasEndTime = self.hasEndTime;
    newEvent.isSometimeEvent = self.isSometimeEvent;
    newEvent.isUserCreated = self.isUserCreated;
    
    return newEvent;
}

@end