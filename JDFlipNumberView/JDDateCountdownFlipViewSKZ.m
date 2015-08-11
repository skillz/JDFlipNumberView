//
//  JDCountdownFlipView.m
//
//  Created by Markus Emrich on 12.03.11.
//  Copyright 2011 Markus Emrich. All rights reserved.
//

#import "JDDateCountdownFlipViewSKZ.h"

static CGFloat kFlipAnimationUpdateInterval = 0.5; // = 2 times per second

@interface JDDateCountdownFlipViewSKZ ()
@property (nonatomic) NSInteger dayDigitCount;
@property (nonatomic, strong) JDFlipNumberViewSKZ* dayFlipNumberView;
@property (nonatomic, strong) JDFlipNumberViewSKZ* hourFlipNumberView;
@property (nonatomic, strong) JDFlipNumberViewSKZ* minuteFlipNumberView;
@property (nonatomic, strong) JDFlipNumberViewSKZ* secondFlipNumberView;

@property (nonatomic, strong) NSTimer *animationTimer;
- (void)setupUpdateTimer;
- (void)handleTimer:(NSTimer*)timer;
@end

@implementation JDDateCountdownFlipViewSKZ

- (id)init
{
    return [self initWithDayDigitCount:3];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithDayDigitCount:3];
    if (self) {
        self.frame = frame;
    }
    return self;
}

- (id)initWithDayDigitCount:(NSInteger)dayDigits;
{
    self = [super initWithFrame: CGRectZero];
    if (self) {
        _dayDigitCount = dayDigits;
        // view setup
        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
		
        // setup flipviews
        self.dayFlipNumberView = [[JDFlipNumberViewSKZ alloc] initWithDigitCount:_dayDigitCount];
        self.hourFlipNumberView = [[JDFlipNumberViewSKZ alloc] initWithDigitCount:2];
        self.minuteFlipNumberView = [[JDFlipNumberViewSKZ alloc] initWithDigitCount:2];
        self.secondFlipNumberView = [[JDFlipNumberViewSKZ alloc] initWithDigitCount:2];
        
        // set maximum values
        self.hourFlipNumberView.maximumValue = 23;
        self.minuteFlipNumberView.maximumValue = 59;
        self.secondFlipNumberView.maximumValue = 59;
        
        // disable reverse flipping
        self.dayFlipNumberView.reverseFlippingDisabled = YES;
        self.hourFlipNumberView.reverseFlippingDisabled = YES;
        self.minuteFlipNumberView.reverseFlippingDisabled = YES;
        self.secondFlipNumberView.reverseFlippingDisabled = YES;

        [self setZDistance:60];
        
        // set inital frame
        CGRect frame = self.hourFlipNumberView.frame;
        self.frame = CGRectMake(0, 0, frame.size.width*(dayDigits+7), frame.size.height);
        
        // add subviews
        for (JDFlipNumberViewSKZ* view in @[self.dayFlipNumberView, self.hourFlipNumberView, self.minuteFlipNumberView, self.secondFlipNumberView]) {
            [self addSubview:view];
        }
        
        // set inital dates
        self.targetDate = [NSDate date];
        [self setupUpdateTimer];
    }
    return self;
}

#pragma mark setter

- (void)setZDistance:(NSUInteger)zDistance;
{
    for (JDFlipNumberViewSKZ* view in @[self.dayFlipNumberView, self.hourFlipNumberView, self.minuteFlipNumberView, self.secondFlipNumberView]) {
        [view setZDistance:zDistance];
    }
}

- (void)setFrame:(CGRect)frame;
{
    if (self.dayFlipNumberView == nil) {
        [super setFrame:frame];
        return;
    }
    
    CGFloat digitWidth = frame.size.width/(self.dayFlipNumberView.digitCount+7);
    CGFloat margin     = digitWidth/3.0;
    CGFloat currentX   = 0;

    // resize first flipview
    self.dayFlipNumberView.frame = CGRectMake(0, 0, digitWidth * self.dayDigitCount, frame.size.height);
    currentX += self.dayFlipNumberView.frame.size.width;
    
    // update flipview frames
    for (JDFlipNumberViewSKZ* view in @[self.hourFlipNumberView, self.minuteFlipNumberView, self.secondFlipNumberView]) {
        currentX   += margin;
        view.frame = CGRectMake(currentX, 0, digitWidth*2, frame.size.height);
        currentX   += view.frame.size.width;
    }
    
    // take bottom right of last view for new size, to match size of subviews
    CGRect lastFrame = self.secondFlipNumberView.frame;
    frame.size.width  = ceil(lastFrame.size.width  + lastFrame.origin.x);
    frame.size.height = ceil(lastFrame.size.height + lastFrame.origin.y);
    
    [super setFrame:frame];
}

- (void)setTargetDate:(NSDate *)targetDate;
{
    _targetDate = targetDate;
    [self updateValuesAnimated:NO];
}

#pragma mark update timer


- (void)start;
{
    if (self.animationTimer == nil) {
        [self setupUpdateTimer];
    }
}

- (void)stop;
{
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}

- (void)setupUpdateTimer;
{
    self.animationTimer = [NSTimer timerWithTimeInterval:kFlipAnimationUpdateInterval
                                                  target:self
                                                selector:@selector(handleTimer:)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.animationTimer forMode:NSRunLoopCommonModes];
}

- (void)handleTimer:(NSTimer*)timer;
{
    [self updateValuesAnimated:YES];
}

- (void)updateValuesAnimated:(BOOL)animated;
{
    if (self.targetDate == nil) {
        return;
    }
    
    if ([self.targetDate timeIntervalSinceDate:[NSDate date]] > 0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSUInteger flags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents* dateComponents = [[NSCalendar currentCalendar] components:flags fromDate:[NSDate date] toDate:self.targetDate options:0];
#pragma clang diagnostic pop

        [self.dayFlipNumberView setValue:[dateComponents day] animated:animated];
        [self.hourFlipNumberView setValue:[dateComponents hour] animated:animated];
        [self.minuteFlipNumberView setValue:[dateComponents minute] animated:animated];
        [self.secondFlipNumberView setValue:[dateComponents second] animated:animated];
    } else {
        [self.dayFlipNumberView setValue:0 animated:animated];
        [self.hourFlipNumberView setValue:0 animated:animated];
        [self.minuteFlipNumberView setValue:0 animated:animated];
        [self.secondFlipNumberView setValue:0 animated:animated];
        [self stop];
    }
}

@end
