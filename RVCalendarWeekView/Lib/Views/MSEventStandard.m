//
//  MSEventStandard.m
//  RVCalendarWeekView
//
//  Created by Kyle Fleming on 10/14/16.
//  Copyright © 2016 Kyle Fleming. All rights reserved.
//

#import "MSEventStandard.h"

@implementation MSEventStandard

+ (instancetype)make:(NSDate *)start title:(NSString *)title location:(NSString *)location {
    return [self make:start end:nil title:title location:location];
}

+ (instancetype)make:(NSDate *)start end:(NSDate *)end title:(NSString *)title location:(NSString *)location {
    return [self make:start end:end hasStartTime:true hasEndTime:true isSometimeEvent:false title:title location:location];
}

+ (instancetype)make:(NSDate *)start end:(NSDate *)end hasStartTime:(BOOL)hasStartTime hasEndTime:(BOOL)hasEndTime isSometimeEvent:(BOOL)isSometimeEvent title:(NSString *)title location:(NSString *)location {
    return [[self alloc] initWithStartDate:start endDate:end hasStartTime:hasStartTime hasEndTime:hasEndTime isSometimeEvent:isSometimeEvent title:title location:location];
}

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate hasStartTime:(BOOL)hasStartTime hasEndTime:(BOOL)hasEndTime isSometimeEvent:(BOOL)isSometimeEvent title:(NSString*)title location:(NSString*)location {
    if (self = [super initWithStartDate:startDate endDate:endDate hasStartTime:hasStartTime hasEndTime:hasEndTime isSometimeEvent:isSometimeEvent]) {
        self.title = title;
        self.location = location;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MSEventStandard *newEvent = [super copyWithZone:zone];
    
    newEvent.title = [self.title copyWithZone:zone];
    newEvent.location = [self.location copyWithZone:zone];
    
    return newEvent;
}

@end
