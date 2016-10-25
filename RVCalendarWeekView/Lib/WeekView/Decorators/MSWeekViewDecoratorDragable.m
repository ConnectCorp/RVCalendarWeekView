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
    UIGestureRecognizer* lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onEventCellLongPress:)];
    lpgr.delegate = self;
    [cell addGestureRecognizer:lpgr];
    
    BOOL showDragHandle = [self.delegate respondsToSelector:@selector(weekView:shouldShowBottomDragHandle:)] &&
        [self.dragDelegate weekView:self.weekView shouldShowBottomDragHandle:cell.event];
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
-(void)onEventCellLongPress:(UILongPressGestureRecognizer*)gestureRecognizer{
    MSEventCell* eventCell = (MSEventCell*)gestureRecognizer.view;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        //NSLog(@"Long press began: %@",eventCell.akEvent.title);
        CGPoint touchOffsetInCell = [gestureRecognizer locationInView:gestureRecognizer.view];
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
        //NSLog(@"Long press ended: %@",eventCell.akEvent.title);
        [self onDragEnded:eventCell];
    }
}

-(void)onDragEnded:(MSEventCell*)eventCell{
    
    NSDate* newStartDate = [self dateForDragable];
    
    if([self canMoveToNewDate:eventCell.event newDate:newStartDate]){
        int duration = eventCell.event.durationInSeconds;
        eventCell.event.StartDate = newStartDate;
        eventCell.event.EndDate = [eventCell.event.StartDate dateByAddingSeconds:duration];
        [self.baseWeekView forceReload:YES];
        if(self.dragDelegate){
            [self.dragDelegate weekView:self.baseWeekView event:eventCell.event moved:newStartDate];
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
        CGPoint cp = [gestureRecognizer locationInView:self.baseWeekView];
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
        [self.dragDelegate weekView:self.baseWeekView event:eventCell.event moved:eventCell.event.StartDate];
    }
    
    [mBottomDragView removeFromSuperview];
    mBottomDragView = nil;
}

-(NSDate*)endDateForBottomDragable{
    CGPoint dropPoint = CGPointMake(CGRectGetMinX(mBottomDragView.frame),
                                    CGRectGetMaxY(mBottomDragView.frame));
    return [self dateForPoint:dropPoint];
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
