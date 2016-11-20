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
    return [self make:start end:end hasStartTime:true hasEndTime:true isSometimeEvent:false];
}

+ (instancetype)make:(NSDate *)start end:(NSDate *)end hasStartTime:(BOOL)hasStartTime hasEndTime:(BOOL)hasEndTime isSometimeEvent:(BOOL)isSometimeEvent {
    return [[self alloc] initWithStartDate:start endDate:end hasStartTime:hasStartTime hasEndTime:hasEndTime isSometimeEvent:isSometimeEvent];
}

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate hasStartTime:(BOOL)hasStartTime hasEndTime:(BOOL)hasEndTime isSometimeEvent:(BOOL)isSometimeEvent {
    if (self = [super init]) {
        self.reuseIdentifierPostfix = MSEventDefaultReuseIdentifierPostfix;
        self.startDate = startDate;
        self.endDate = endDate;
        self.hasStartTime = hasStartTime;
        self.hasEndTime = hasEndTime;
        self.isSometimeEvent = isSometimeEvent;
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
    
    return newEvent;
}

@end