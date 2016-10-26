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
    return [self make:start end:end hasStartTime:true hasEndTime:true];
}

+ (instancetype)make:(NSDate *)start end:(NSDate *)end hasStartTime:(BOOL)hasStartTime hasEndTime:(BOOL)hasEndTime {
    return [[self alloc] initWithStartDate:start endDate:end hasStartTime:hasStartTime hasEndTime:hasEndTime];
}

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate hasStartTime:(BOOL)hasStartTime hasEndTime:(BOOL)hasEndTime {
    if (self = [super init]) {
        self.reuseIdentifierPostfix = MSEventDefaultReuseIdentifierPostfix;
        self.startDate = startDate;
        self.endDate = endDate;
        self.hasStartTime = hasStartTime;
        self.hasEndTime = hasEndTime;
    }
    return self;
}

- (NSDate *)day {
    return [NSCalendar.currentCalendar startOfDayForDate:self.startDate];
}

@end