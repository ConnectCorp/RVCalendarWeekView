//
//  RVWeekView.m
//  RVCalendarWeekView
//
//  Created by Badchoice on 22/8/16.
//  Copyright © 2016 revo. All rights reserved.
//

#import "MSWeekView.h"

#import "NSDate+Easy.h"
#import "RVCollection.h"

#define MAS_SHORTHAND
#import "Masonry.h"

// Collection View Reusable Views
#import "MSGridline.h"
#import "MSAllDayEventsGridline.h"
#import "MSTimeRowHeaderBackground.h"
#import "MSDayColumnHeaderBackground.h"
#import "MSEventCell.h"
#import "MSEventCellStandard.h"
#import "MSTimeRowHeader.h"
#import "MSCurrentTimeIndicator.h"
#import "MSCurrentTimeGridline.h"
#import "MSEventStandard.h"

#define MSEventCellReuseIdentifier        @"MSEventCellReuseIdentifier"
#define MSDayColumnHeaderReuseIdentifier  @"MSDayColumnHeaderReuseIdentifier"
#define MSTimeRowHeaderReuseIdentifier    @"MSTimeRowHeaderReuseIdentifier"

@interface MSWeekView ()

- (NSString *)reuseIdentifierForEvent:(MSEvent *)event;
- (NSString *)reuseIdentifierForPostfix:(NSString *)postfix;

@end

@implementation MSWeekView

//================================================
#pragma mark - Init
//================================================
-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

-(void)setup{
    
    self.daysToShowOnScreen = 6;
    self.daysToShow         = 30;
    self.weekFlowLayout     = [MSCollectionViewCalendarLayout new];
    self.weekFlowLayout.delegate = self;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.weekFlowLayout];
    self.collectionView.dataSource                      = self;
    self.collectionView.delegate                        = self;
    self.collectionView.directionalLockEnabled          = YES;
    self.collectionView.showsVerticalScrollIndicator    = NO;
    self.collectionView.showsHorizontalScrollIndicator  = NO;
    /*if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
     self.collectionView.pagingEnabled = YES;
     }*/
    
    [self addSubview:self.collectionView];
    [self.collectionView makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.height);
        make.width.equalTo(self.width);
        make.left.equalTo(self.left);
        make.top.equalTo(self.top);
    }];
    
    self.weekFlowLayout.sectionLayoutType = MSSectionLayoutTypeHorizontalTile;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.eventCellClass = MSEventCellStandard.class;
    self.dayColumnHeaderClass = MSDayColumnHeader.class;
    self.timeRowHeaderClass = MSTimeRowHeader.class;
    
    self.currentTimeIndicatorClass = MSCurrentTimeIndicator.class;
    self.currentTimeGridlineClass = MSCurrentTimeGridline.class;
    self.allDayEventsGridlineClass = MSAllDayEventsGridline.class;
    self.verticalGridlineClass = MSGridline.class;
    self.horizontalGridlineClass = MSGridline.class;
    self.timeRowHeaderBackgroundClass = MSTimeRowHeaderBackground.class;
    self.dayColumnHeaderBackgroundClass = MSDayColumnHeaderBackground.class;
    
    self.clipsToBounds = YES;
    
    [self registerClasses];
}

-(void)registerEventCellClass:(Class)cls forReuseIdentifierPostfix:(NSString *)postfix{
    [self.collectionView registerClass:cls forCellWithReuseIdentifier:[self reuseIdentifierForPostfix:postfix]];
}

-(NSString *)reuseIdentifierForEvent:(MSEvent *)event{
    return [self reuseIdentifierForPostfix:event.reuseIdentifierPostfix];
}

-(NSString *)reuseIdentifierForPostfix:(NSString *)postfix{
    return [NSString stringWithFormat:@"%@-%@", MSEventCellReuseIdentifier, postfix];
}

-(void)registerClasses{
    [self.collectionView registerClass:self.eventCellClass forCellWithReuseIdentifier:[self reuseIdentifierForPostfix:MSEventDefaultReuseIdentifierPostfix]];
    [self.collectionView registerClass:self.dayColumnHeaderClass forSupplementaryViewOfKind:MSCollectionElementKindDayColumnHeader withReuseIdentifier:MSDayColumnHeaderReuseIdentifier];
    [self.collectionView registerClass:self.timeRowHeaderClass forSupplementaryViewOfKind:MSCollectionElementKindTimeRowHeader withReuseIdentifier:MSTimeRowHeaderReuseIdentifier];
    
    // These are optional. If you don't want any of the decoration views, just don't register a class for them.
    [self.weekFlowLayout registerClass:self.currentTimeIndicatorClass forDecorationViewOfKind:MSCollectionElementKindCurrentTimeIndicator];
    [self.weekFlowLayout registerClass:self.currentTimeGridlineClass forDecorationViewOfKind:MSCollectionElementKindCurrentTimeHorizontalGridline];
    [self.weekFlowLayout registerClass:self.allDayEventsGridlineClass forDecorationViewOfKind:MSCollectionElementKindAllDayEventsHorizontalGridline];
    [self.weekFlowLayout registerClass:self.verticalGridlineClass forDecorationViewOfKind:MSCollectionElementKindVerticalGridline];
    [self.weekFlowLayout registerClass:self.horizontalGridlineClass forDecorationViewOfKind:MSCollectionElementKindHorizontalGridline];
    [self.weekFlowLayout registerClass:self.timeRowHeaderBackgroundClass forDecorationViewOfKind:MSCollectionElementKindTimeRowHeaderBackground];
    [self.weekFlowLayout registerClass:self.dayColumnHeaderBackgroundClass forDecorationViewOfKind:MSCollectionElementKindDayColumnHeaderBackground];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    self.weekFlowLayout.sectionWidth = self.layoutSectionWidth;
}

-(void)forceReload:(BOOL)reloadEvents{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(reloadEvents)
            [self groupEventsByDays];
        [self.weekFlowLayout invalidateLayoutCache];
        [self.collectionView reloadData];
    });
}

- (CGFloat)layoutSectionWidth {
    CGFloat width               = CGRectGetWidth(self.collectionView.bounds);
    CGFloat timeRowHeaderWidth  = self.weekFlowLayout.timeRowHeaderWidth;
    CGFloat rightMargin         = self.weekFlowLayout.contentMargin.right;
    
    return floor((width - timeRowHeaderWidth - rightMargin) / self.daysToShowOnScreen);
}

-(NSDate*)firstDay{
    return [self.weekFlowLayout dateForDayColumnHeaderAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

//================================================
#pragma mark - Set Events
//================================================
-(void)setEvents:(NSArray *)events{
    mEvents = events;
    [self forceReload:YES];
}

-(void)addEvent:(MSEvent *)event{
    [self addEvents:@[event]];
}

-(void)addEvents:(NSArray*)events{
    self.events = [mEvents arrayByAddingObjectsFromArray:events];
    [self forceReload:YES];
}

-(void)removeEvent:(MSEvent*)event{
    self.events = [mEvents reject:^BOOL(MSEvent* arrayEvent) {
        return [arrayEvent isEqual:event];;
    }];
    [self forceReload:YES];
}

-(void)groupEventsByDays{
    NSArray *splitEvents = [self splitEvents];
    
    mEventsGroupedByDay = [splitEvents groupBy:@"startDate.toDeviceTimezoneDateString"].mutableCopy;
}

- (NSArray *)splitEvents {
    NSMutableArray *splitEvents = [NSMutableArray array];
    
    for (MSEventStandard *event in mEvents) {
        event.internalIdentifier = [NSUUID UUID];
        
        NSDate *endOfDay = [[[[NSCalendar currentCalendar] startOfDayForDate:event.startDate] addDay] substractSecond];
        if (event.hasStartTime == true && event.hasEndTime == true && event.endDate > endOfDay) {
            MSEventStandard *alteredEvent = [event copy];
            alteredEvent.endDate = endOfDay;
            alteredEvent.internalIdentifier = event.internalIdentifier;
            [splitEvents addObject:alteredEvent];
            
            NSDate *newEventStart = [endOfDay addSecond];
            while (newEventStart < event.endDate) {
                MSEventStandard *newEvent = [event copy];
                newEvent.title = @""; // Clear out title so it doesn't appear on multiple days
                newEvent.startDate = newEventStart;
                newEvent.endDate = ([newEventStart addDay] < event.endDate ? [[newEventStart addDay] substractSecond] : event.endDate); // If event spans more than one day, end it at midnight of the new day. Else end it at the designated end time.
                newEvent.internalIdentifier = event.internalIdentifier;
                [splitEvents addObject:newEvent];
                
                newEventStart = [newEventStart addDay];
            }
        } else {
            [splitEvents addObject:event];
        }
    }
    
    return splitEvents;
}

//================================================
#pragma mark - CollectionView Datasource
//================================================
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.daysToShow;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSString *dateString = [self dateStringForSection:section];
    return [mEventsGroupedByDay[dateString] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dateString    = [self dateStringForSection:indexPath.section];
    MSEvent *event          = [mEventsGroupedByDay[dateString] objectAtIndex:indexPath.row];
    MSEventStandard *originalEvent = nil;
    for (MSEventStandard *mEvent in mEvents) {
        originalEvent = (event.internalIdentifier == mEvent.internalIdentifier ? mEvent : originalEvent);
    }
    
    MSEventCell *cell       = [collectionView dequeueReusableCellWithReuseIdentifier:[self reuseIdentifierForEvent:event] forIndexPath:indexPath];
    cell.event              = originalEvent;
    cell.displayedEvent     = event;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view;
    if (kind == MSCollectionElementKindDayColumnHeader) {
        MSDayColumnHeader *dayColumnHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MSDayColumnHeaderReuseIdentifier forIndexPath:indexPath];
        NSDate *day                 = [self.weekFlowLayout dateForDayColumnHeaderAtIndexPath:indexPath];
        NSDate *currentDay          = [self currentTimeComponentsForCollectionView:self.collectionView layout:self.weekFlowLayout];
        
        NSDate *startOfDay          = [NSCalendar.currentCalendar startOfDayForDate:day];
        NSDate *startOfCurrentDay   = [NSCalendar.currentCalendar startOfDayForDate:currentDay];
        
        dayColumnHeader.day         = day;
        dayColumnHeader.currentDay  = [startOfDay isEqualToDate:startOfCurrentDay];
        
        view = dayColumnHeader;
        
        UITapGestureRecognizer* tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDayColumnHeaderTap:)];
        tgr.delegate = self;
        [view addGestureRecognizer:tgr];
    } else if (kind == MSCollectionElementKindTimeRowHeader) {
        MSTimeRowHeader *timeRowHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MSTimeRowHeaderReuseIdentifier forIndexPath:indexPath];
        timeRowHeader.time = [self.weekFlowLayout dateForTimeRowHeaderAtIndexPath:indexPath];
        view = timeRowHeader;
    }
    return view;
}

- (NSDate *)dateForSection:(NSInteger)section {
    NSDate *startDate = self.firstDateToShow != nil ? self.firstDateToShow.copy : [NSDate today:@"device"];
    return [startDate addDays:section];
}

- (NSString *)dateStringForSection:(NSInteger)section {
    return [self dateForSection:section].toDeviceTimezoneDateString;
}


//================================================
#pragma mark - Week Flow Delegate
//================================================
- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout dayForSection:(NSInteger)section
{
    return [self dateForSection:section];
}

- (BOOL)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewLayout allDayForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *dateString    = [self dateStringForSection:indexPath.section];
    MSEvent *event          = [mEventsGroupedByDay[dateString] objectAtIndex:indexPath.row];
    return event.hasStartTime == false && event.hasEndTime == false;
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dateString    = [self dateStringForSection:indexPath.section];
    MSEvent *event          = [mEventsGroupedByDay[dateString] objectAtIndex:indexPath.row];
    return event.startDate;
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dateString    = [self dateStringForSection:indexPath.section];
    MSEvent *event          = [mEventsGroupedByDay[dateString] objectAtIndex:indexPath.row];
    return event.endDate ?: [event.startDate addHours:2]; // Default to 2 hour duration if no end date so event will still render on calendar.
}

- (NSDate *)currentTimeComponentsForCollectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout
{
    return NSDate.date;
}


//================================================
#pragma mark - Collection view delegate
//================================================
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.delegate){
        MSEventCell* cell = (MSEventCell*)[collectionView cellForItemAtIndexPath:indexPath];
        [self.delegate weekView:self eventSelected:cell];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
}

//================================================
#pragma mark - Collection view delegate
//================================================
-(void)onDayColumnHeaderTap:(UITapGestureRecognizer*)gestureRecognizer{
    MSDayColumnHeader *dayColumnHeader = gestureRecognizer.view;
    if(self.delegate) {
        [self.delegate weekView:self dayColumnHeaderTapped:dayColumnHeader];
    }
}

//================================================
#pragma mark - Dealloc
//================================================
-(void)dealloc{
    self.collectionView.dataSource  = nil;
    self.collectionView.delegate    = nil;
    self.collectionView             = nil;
    self.weekFlowLayout.delegate    = nil;
    self.weekFlowLayout             = nil;
    mEventsGroupedByDay             = nil;
}

@end
