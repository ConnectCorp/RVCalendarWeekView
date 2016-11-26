//
//  MSWeekViewDecoratorDragable.m
//  RVCalendarWeekView
//
//  Created by Jordi Puigdellívol on 1/9/16.
//  Copyright © 2016 revo. All rights reserved.
//

#import "MSWeekViewDecoratorDragable.h"
#import "MSEventCellStandard.h"
#import "NSDate+Easy.h"
#import "RVCollection.h"
#import "NSDate+DateTools.h"
#import "UIColor+HexString.h"

@interface MSWeekViewDecoratorDragable () <UIGestureRecognizerDelegate>

@property (nonatomic) NSTimer *scrollCollectionViewTimer;

@end

@implementation MSWeekViewDecoratorDragable

+(__kindof MSWeekView*)makeWith:(MSWeekView*)weekView andDelegate:(id<MSWeekViewDragableDelegate>)delegate{
    MSWeekViewDecoratorDragable * weekViewDecorator = [super makeWith:weekView];
    weekViewDecorator.dragDelegate = delegate;
    return weekViewDecorator;
}

//=========================================================
#pragma mark - Collection view datasource
//=========================================================
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MSEventCellStandard *cell = (MSEventCellStandard*)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    UIPanGestureRecognizer *gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onEventCellPan:)];
    gr.delegate = self;
    [cell addGestureRecognizer:gr];
    
    BOOL showDragHandle = [self.dragDelegate respondsToSelector:@selector(weekView:shouldShowBottomDragHandle:)] &&
    [self.dragDelegate weekView:self.weekView shouldShowBottomDragHandle:cell.event] &&
    cell.event.endDate == cell.displayedEvent.endDate; // Only show handle for last Displayed Events corresponding to Event
    
    if (showDragHandle) {
        cell.bottomDragHandle.hidden = NO;
        UIGestureRecognizer* pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onBottomDragHandlePan:)];
        [cell.bottomDragHandle addGestureRecognizer:pgr];
    } else {
        cell.bottomDragHandle.hidden = YES;
    }
    
    return cell;
}

//=========================================================
#pragma mark - Gesture recognizer delegate
//=========================================================
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    MSEventCell* eventCell = (MSEventCell*)gestureRecognizer.view;
    return [self.dragDelegate weekView:self.weekView canStartMovingEvent:eventCell.event];
}

//=========================================================
#pragma mark - Drag & Drop
//=========================================================
-(void)onEventCellPan:(UIPanGestureRecognizer*)gestureRecognizer{
    // Cancel the scroll collection view timer when a new pan event is fired.
    [self.scrollCollectionViewTimer invalidate];
    self.scrollCollectionViewTimer = nil;
    
    MSEventCell* eventCell = (MSEventCell*)gestureRecognizer.view;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        //NSLog(@"Pan began: %@",eventCell.akEvent.title);
        CGPoint touchOffsetInCell = [gestureRecognizer locationInView:gestureRecognizer.view];
        startPoint = [gestureRecognizer locationInView:self.baseWeekView];
        mDragableEvent = [MSDragableEvent makeWithEventCell:eventCell andOffset:self.weekView.collectionView.contentOffset touchOffset:touchOffsetInCell];
        [self.baseWeekView addSubview:mDragableEvent];
    }
    else if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
        CGPoint cp = [gestureRecognizer locationInView:self.baseWeekView];
        
        CGPoint newOrigin;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            float xOffset = -13;
            if([self isPortrait]){
                xOffset = 5;
            }
            float x = [self round:cp.x toNearest:self.weekFlowLayout.sectionWidth] + xOffset
            - ((int)self.collectionView.contentOffset.x % (int)self.weekFlowLayout.sectionWidth);
            newOrigin = CGPointMake(x, cp.y);
        }
        else{
            newOrigin = CGPointMake(cp.x, cp.y);
        }
        newOrigin = CGPointMake(newOrigin.x - mDragableEvent.touchOffset.x,
                                newOrigin.y - mDragableEvent.touchOffset.y);
        
        [UIView animateWithDuration:0.1 animations:^{
            mDragableEvent.frame = (CGRect) { .origin = newOrigin, .size = mDragableEvent.frame.size };
        }];
        
        NSDate* date = [self dateForDragable];
        mDragableEvent.timeLabel.text = [date format:@"HH:mm" timezone:@"device"];
        
    }
    else if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        //NSLog(@"Pan ended: %@",eventCell.akEvent.title);
        [self onDragEnded:eventCell endPoint: [gestureRecognizer locationInView:self.baseWeekView]];
    }
    [self scrollCollectionView:gestureRecognizer];
}

- (void)scrollCollectionView:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded &&
        gestureRecognizer.state != UIGestureRecognizerStateCancelled) {
        CGPoint cp = [gestureRecognizer locationInView:self.baseWeekView];
        CGFloat minDistanceFromEdge = 50;
        CGFloat distanceXFromLeftEdge = cp.x - self.weekView.weekFlowLayout.timeRowHeaderWidth;
        CGFloat distanceXFromRightEdge = CGRectGetMaxX(self.collectionView.frame) - cp.x;
        CGFloat distanceYFromTopEdge = cp.y - self.weekView.weekFlowLayout.dayColumnHeaderHeight;
        CGFloat distanceYFromBottomEdge = CGRectGetMaxY(self.collectionView.frame) - cp.y;
        
        CGFloat delX = 0;
        CGFloat delY = 0;
        
        if (distanceXFromRightEdge < minDistanceFromEdge) {
            delX = minDistanceFromEdge - distanceXFromRightEdge;
        } else if (distanceXFromLeftEdge < minDistanceFromEdge) {
            delX = -(minDistanceFromEdge - distanceXFromLeftEdge);
        }
        
        if (distanceYFromBottomEdge < minDistanceFromEdge) {
            delY = minDistanceFromEdge - distanceYFromBottomEdge;
        } else if (distanceYFromTopEdge < minDistanceFromEdge) {
            delY = -(minDistanceFromEdge - distanceYFromTopEdge);
        }
        
        
        if (delX != 0 || delY != 0) {
            CGRect newRect = CGRectMake(self.collectionView.contentOffset.x + delX,
                                        self.collectionView.contentOffset.y + delY,
                                        self.collectionView.frame.size.width,
                                        self.collectionView.frame.size.height);
            [self.weekView.collectionView scrollRectToVisible:newRect animated:YES];
            self.scrollCollectionViewTimer = [NSTimer scheduledTimerWithTimeInterval:.1
                                                                              target:self
                                                                            selector:@selector(scrollCollectionViewWithUserInfo:)
                                                                            userInfo:gestureRecognizer
                                                                             repeats:NO];
        }
    }
}

- (void)scrollCollectionViewWithUserInfo:(NSTimer *)timer {
    [self scrollCollectionView:timer.userInfo];
}

- (void)onDragEnded:(MSEventCell *)eventCell endPoint:(CGPoint)endPoint {
    NSDate *endPointDate = [self dateForPoint:endPoint];
    NSDate *newDate = endPointDate;
    
    if([self canMoveToNewDate:eventCell.event newDate:newDate]){
        eventCell.event.startDate = newDate;
        
        [self.baseWeekView forceReload:YES];
        if (self.dragDelegate) {
            [self.dragDelegate weekView:self.baseWeekView event:eventCell.event moved:newDate];
        }
    }
    
    [mDragableEvent removeFromSuperview];
    mDragableEvent = nil;
}

-(NSDate*)dateForDragable{
    CGPoint dropPoint = CGPointMake(mDragableEvent.frame.origin.x + mDragableEvent.touchOffset.x,
                                    mDragableEvent.frame.origin.y);
    return [self dateForPoint:dropPoint];
}

//=========================================================
#pragma mark - Bottom drag handle
//=========================================================

-(void)onBottomDragHandlePan:(UIPanGestureRecognizer*)gestureRecognizer{
    UIView *parentView = gestureRecognizer.view.superview;
    
    MSEventCell* eventCell;
    while (!eventCell) {
        if ([parentView isKindOfClass:[MSEventCell class]]) {
            eventCell = (MSEventCell*) parentView;
        } else {
            parentView = parentView.superview;
        }
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        mBottomDragView = [UIView new];
        mBottomDragView.frame = eventCell.frame;
        mBottomDragView.backgroundColor = [UIColor colorWithHexString:@"0DAAAB"];
        [self.baseWeekView.collectionView insertSubview:mBottomDragView belowSubview:eventCell];
    }
    else if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
        CGPoint cp = [gestureRecognizer locationInView:self.baseWeekView.collectionView];
        [UIView animateWithDuration:0.1 animations:^{
            CGFloat minEventDuration = 15; // Minutes
            CGFloat minHeight = (self.weekFlowLayout.hourHeight / 60) * minEventDuration;
            
            CGFloat height = MAX(minHeight, cp.y - mBottomDragView.frame.origin.y);
            CGRect newFrame = (CGRect) {
                .origin = mBottomDragView.frame.origin,
                .size = CGSizeMake(mBottomDragView.frame.size.width, height)
            };
            mBottomDragView.frame = newFrame;
        }];
        
        [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.baseWeekView];
    }
    else if(gestureRecognizer.state == UIGestureRecognizerStateEnded ||
            gestureRecognizer.state == UIGestureRecognizerStateCancelled){
        [self onBottomDragEnded:eventCell bottomDragView:mBottomDragView];
    }
}

-(void)onBottomDragEnded:(MSEventCell*)eventCell bottomDragView:(UIView*)bottomDragView{
    NSDate* newEndDate = [self endDateForBottomDragable];
    eventCell.event.EndDate = newEndDate;
    [self.baseWeekView forceReload:YES];
    if(self.dragDelegate){
        [self.dragDelegate weekView:self.baseWeekView event:eventCell.event moved:eventCell.event.startDate];
    }
    
    [mBottomDragView removeFromSuperview];
    mBottomDragView = nil;
}

-(NSDate*)endDateForBottomDragable{
    CGPoint dropPoint = CGPointMake(CGRectGetMinX(mBottomDragView.frame),
                                    CGRectGetMaxY(mBottomDragView.frame));
    CGPoint dropPointInWeekView = [self.baseWeekView convertPoint:dropPoint fromView:mBottomDragView.superview];
    return [self dateForPoint:dropPointInWeekView];
}

//=========================================================
#pragma mark - Can move to new date?
//=========================================================
-(BOOL)canMoveToNewDate:(MSEvent*)event newDate:(NSDate*)newDate{
    if (! self.dragDelegate) return true;
    return [self.dragDelegate weekView:self canMoveEvent:event to:newDate];
}

-(BOOL)isPortrait{
    return (UIDevice.currentDevice.orientation == UIDeviceOrientationPortrait || UIDevice.currentDevice.orientation == UIDeviceOrientationFaceUp);
}


@end
