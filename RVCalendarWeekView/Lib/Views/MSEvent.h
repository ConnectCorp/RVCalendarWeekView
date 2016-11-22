//
//  AKEvent.h
//  Example
//
//  Created by ak on 18.01.2016.
//  Copyright © 2016 Eric Horacek. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MSEventDefaultReuseIdentifierPostfix @"default"

@interface MSEvent : NSObject <NSCopying>

@property (nonatomic, strong) NSString *reuseIdentifierPostfix;
@property (nonatomic, strong) NSUUID *internalIdentifier;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic) BOOL hasStartTime;
@property (nonatomic) BOOL hasEndTime;
@property (nonatomic) BOOL isSometimeEvent;
@property (nonatomic) BOOL isUserCreated;

+ (instancetype)make:(NSDate *)start;
+ (instancetype)make:(NSDate *)start end:(NSDate *)end;
+ (instancetype)make:(NSDate *)start end:(NSDate *)end hasStartTime:(BOOL)hasStartTime hasEndTime:(BOOL)hasEndTime isSometimeEvent:(BOOL)isSometimeEvent isUserCreated:(BOOL)isUserCreated;

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate hasStartTime:(BOOL)hasStartTime hasEndTime:(BOOL)hasEndTime isSometimeEvent:(BOOL)isSometimeEvent isUserCreated:(BOOL)isUserCreated;

- (NSDate *)day;

@end