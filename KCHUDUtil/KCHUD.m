//
//  KCHUD.m
//  KCHUDUtil
//
//  Created by Kumar C on 4/19/16.
//  Copyright © 2016 Kumar C. All rights reserved.
//

#import "KCHUD.h"

@interface KCHUD ()

@property (nonatomic, strong) NSPointerArray *hudList;

@end

@implementation KCHUD

+ (instancetype) sharedHUD
{
    static KCHUD *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        _hudList = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

- (NSMutableArray*)  CreateNonRetainingMutableArray {
    return (NSMutableArray *)CFBridgingRelease(CFArrayCreateMutable(nil, 0, nil));
}

- (void) showHUDInView : (UIView *) view
{
    [self hideInView:view];
    KCSpinner *spinner = [KCSpinner showInView:view isMini:NO];
    [_hudList addPointer:(__bridge void * _Nullable)(spinner)];
}

- (void) showMiniHUDInView : (UIView *) view
{
    [self hideInView:view];
    KCSpinner *spinner = [KCSpinner showInView:view isMini:YES];
    [_hudList addPointer:(__bridge void * _Nullable)(spinner)];
}


- (void) hideInView : (UIView *) view
{
    if (view == nil) {
        return;
    }
    KCSpinner *spinner = nil;
    NSInteger index = 0;
    [_hudList compact];
    for (KCSpinner *spinnerObj in _hudList) {
        if (spinnerObj == nil) {
            index++;
            continue;
        }
        UIView *superview = [spinnerObj superview];
        if (superview && superview == view) {
            spinnerObj.superview.userInteractionEnabled = YES;
            [spinnerObj stopAnimating];
            spinner = spinnerObj;
            break;
        }
        index++;
        
    }
    if (spinner) {
        [_hudList removePointerAtIndex:index];
    }
}

+ (void) showBlockingHUD:(UIViewController *)viewController
{
    [[self sharedHUD] showHUDInView:viewController.view];
    viewController.view.userInteractionEnabled = NO;
}

+ (void) showBlockingHUDInView:(UIView *)view
{
    [[self sharedHUD] showHUDInView:view];
    view.userInteractionEnabled = NO;
}

+ (void) showProgressHUD:(UIViewController *)viewController
{
    if (viewController == nil) {
        return;
    }
    [[self sharedHUD] showHUDInView:viewController.view];
}

+ (void) showProgressHUDInView:(UIView *)view
{
    [[self sharedHUD] showHUDInView:view];
}

+ (void) hideProgressHUD:(UIViewController *)viewController
{
    if (viewController == nil) {
        return;
    }
    [[self sharedHUD] hideInView:viewController.view];
}

+ (void) hideProgressHUDInView:(UIView *)view
{
    [[self sharedHUD] hideInView:view];
}

+ (void) showMiniHUDInView:(UIView *)view
{
    [[self sharedHUD] showMiniHUDInView:view];
}

@end
