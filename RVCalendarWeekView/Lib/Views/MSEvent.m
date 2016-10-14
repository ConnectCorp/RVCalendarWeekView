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

+(instancetype)make:(NSDate*)start{
    return [self make:start duration:60];
}

+(instancetype)make:(NSDate*)start end:(NSDate*)end{
    return [[self alloc] initWithStart:start end:end];
}

+(instancetype)make:(NSDate*)start duration:(int)minutes{
    return [self make:start end:[start addMinutes:minutes]];
}

- (instancetype)initWithStart:(NSDate*)start end:(NSDate*)end{
    self = [super initWithStartDate:start endDate:end];
    if (self) {
        self.reuseIdentifierPostfix = MSEventDefaultReuseIdentifierPostfix;
    }
    return self;
}

- (NSDate *)day{
    return [NSCalendar.currentCalendar startOfDayForDate:self.StartDate];
}

@end