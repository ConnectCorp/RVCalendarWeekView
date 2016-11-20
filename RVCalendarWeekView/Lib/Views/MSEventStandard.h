//
//  MSEventStandard.h
//  RVCalendarWeekView
//
//  Created by Kyle Fleming on 10/14/16.
//  Copyright © 2016 Kyle Fleming. All rights reserved.
//

#import "MSEvent.h"

@interface MSEventStandard : MSEvent <NSCopying>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *location;

+ (instancetype)make:(NSDate *)start title:(NSString *)title location:(NSString *)location;
+ (instancetype)make:(NSDate *)start end:(NSDate *)end title:(NSString *)title location:(NSString *)location;
+ (instancetype)make:(NSDate *)start end:(NSDate *)end hasStartTime:(BOOL)hasStartTime hasEndTime:(BOOL)hasEndTime isSometimeEvent:(BOOL)isSometimeEvent title:(NSString *)title location:(NSString *)location;

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate hasStartTime:(BOOL)hasStartTime hasEndTime:(BOOL)hasEndTime isSometimeEvent:(BOOL)isSometimeEvent title:(NSString*)title location:(NSString*)location;

@end
