//
//  KCSpinner.m
//  KCHUDUtil
//
//  Created by Kumar C on 4/19/16.
//  Copyright © 2016 Kumar C. All rights reserved.
//

#import "KCSpinner.h"

static NSString *kCRingStrokeAnimationKey = @"kcmaterialdesignspinner.stroke";
static NSString *kCRingRotationAnimationKey = @"kcmaterialdesignspinner.rotation";

@interface KCSpinner ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, readwrite) BOOL isAnimating;

@end


/// A UIView subclass for showing progress HUD.
@implementation KCSpinner

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (id) initWithView : (UIView *) view isMini  : (BOOL) isMini
{
    self = [self initWithFrame:CGRectMake(0, 0, isMini ? 2 : 500, isMini ? 25 : 50)];
    if (self) {
        _hidesWhenStopped = YES;
        self.lineWidth = 2;
        //        self.tintColor = [UIColor colorWithRed:16.0/255.0 green:200.0/255.0 blue:164.0/255.0 alpha:1.0];
        self.tintColor = [UIColor lightGrayColor];
        self.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
    }
    return self;
}

- (void) hide
{
    _removeFromSuperViewOnHide = YES;
    [self stopAnimating];
}

+ (instancetype) showInView:(UIView *)view isMini : (BOOL) isMIni
{
    KCSpinner *spinner = [[self alloc] initWithView:view isMini:isMIni];
    spinner.removeFromSuperViewOnHide = YES;
    [view addSubview:spinner];
    [spinner startAnimating];
    return spinner;
}

+ (BOOL) hideSpinnerForView:(UIView *)view;
{
    KCSpinner *hud = [self HUDForView:view];
    if (hud != nil) {
        hud.removeFromSuperViewOnHide = YES;
        [hud stopAnimating];
        return YES;
    }
    return NO;
}

+ (NSUInteger)hideAllHUDsForView:(UIView *)view {
    NSArray *huds = [KCSpinner allHUDsForView:view];
    for (KCSpinner *hud in huds) {
        hud.removeFromSuperViewOnHide = YES;
        [hud stopAnimating];
    }
    return [huds count];
}

+ (NSArray *)allHUDsForView:(UIView *)view {
    NSMutableArray *huds = [NSMutableArray array];
    NSArray *subviews = view.subviews;
    for (UIView *aView in subviews) {
        if ([aView isKindOfClass:self]) {
            [huds addObject:aView];
        }
    }
    return [NSArray arrayWithArray:huds];
}


+ (instancetype)HUDForView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            return (KCSpinner *)subview;
        }
    }
    return nil;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.layer addSublayer:self.progressLayer];
    
    // See comment in resetAnimations on why this notification is used.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAnimations) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc
{
    if (_isAnimating) {
        [self stopAnimating];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.progressLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    [self updatePath];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    self.progressLayer.strokeColor = self.tintColor.CGColor;
}

- (void)resetAnimations {
    // If the app goes to the background, returning it to the foreground causes the animation to stop (even though it's not explicitly stopped by our code). Resetting the animation seems to kick it back into gear.
    if (self.isAnimating) {
        [self restartAnimation];
    }
}

- (void)setAnimating:(BOOL)animate {
    (animate ? [self startAnimating] : [self stopAnimating]);
}

- (void)startAnimating {
    if (self.isAnimating)
        return;
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.duration = 4.f;
    animation.fromValue = @(0.f);
    animation.toValue = @(2 * M_PI);
    animation.repeatCount = INFINITY;
    [self.progressLayer addAnimation:animation forKey:kCRingRotationAnimationKey];
    
    CABasicAnimation *headAnimation = [CABasicAnimation animation];
    headAnimation.keyPath = @"strokeStart";
    headAnimation.duration = 1.f;
    headAnimation.fromValue = @(0.f);
    headAnimation.toValue = @(0.25f);
    headAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *tailAnimation = [CABasicAnimation animation];
    tailAnimation.keyPath = @"strokeEnd";
    tailAnimation.duration = 1.f;
    tailAnimation.fromValue = @(0.f);
    tailAnimation.toValue = @(1.f);
    tailAnimation.timingFunction = self.timingFunction;
    
    
    CABasicAnimation *endHeadAnimation = [CABasicAnimation animation];
    endHeadAnimation.keyPath = @"strokeStart";
    endHeadAnimation.beginTime = 1.f;
    endHeadAnimation.duration = 0.5f;
    endHeadAnimation.fromValue = @(0.25f);
    endHeadAnimation.toValue = @(1.f);
    endHeadAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *endTailAnimation = [CABasicAnimation animation];
    endTailAnimation.keyPath = @"strokeEnd";
    endTailAnimation.beginTime = 1.f;
    endTailAnimation.duration = 0.5f;
    endTailAnimation.fromValue = @(1.f);
    endTailAnimation.toValue = @(1.f);
    endTailAnimation.timingFunction = self.timingFunction;
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    [animations setDuration:1.5f];
    [animations setAnimations:@[headAnimation, tailAnimation, endHeadAnimation, endTailAnimation]];
    animations.repeatCount = INFINITY;
    [self.progressLayer addAnimation:animations forKey:kCRingStrokeAnimationKey];
    
    
    self.isAnimating = true;
    
    if (self.hidesWhenStopped) {
        self.hidden = NO;
    }
}

- (void) restartAnimation
{
    [self.progressLayer removeAnimationForKey:kCRingRotationAnimationKey];
    [self.progressLayer removeAnimationForKey:kCRingStrokeAnimationKey];
    self.isAnimating = false;
    [self startAnimating];
}

- (void)stopAnimating {
    if (!self.isAnimating)
        return;
    
    [self.progressLayer removeAnimationForKey:kCRingRotationAnimationKey];
    [self.progressLayer removeAnimationForKey:kCRingStrokeAnimationKey];
    self.isAnimating = false;
    
    //    if (self.hidesWhenStopped) {
    self.hidden = YES;
    //    }
    
    //    if (_removeFromSuperViewOnHide) {
    [self removeFromSuperview];
    //    }
}

#pragma mark - Private

- (void)updatePath {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2) - self.progressLayer.lineWidth / 2;
    CGFloat startAngle = (CGFloat)(0);
    CGFloat endAngle = (CGFloat)(2*M_PI);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.progressLayer.path = path.CGPath;
    
    self.progressLayer.strokeStart = 0.f;
    self.progressLayer.strokeEnd = 0.f;
}

#pragma mark - Properties

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.strokeColor = self.tintColor.CGColor;
        _progressLayer.fillColor = nil;
        _progressLayer.lineWidth = 1.5f;
    }
    return _progressLayer;
}

- (BOOL)isAnimating {
    return _isAnimating;
}

- (CGFloat)lineWidth {
    return self.progressLayer.lineWidth;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    self.progressLayer.lineWidth = lineWidth;
    [self updatePath];
}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped {
    _hidesWhenStopped = hidesWhenStopped;
    self.hidden = !self.isAnimating && hidesWhenStopped;
}

@end
