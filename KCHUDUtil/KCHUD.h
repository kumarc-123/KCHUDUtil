//
//  KCHUD.h
//  KCHUDUtil
//
//  Created by Kumar C on 4/19/16.
//  Copyright © 2016 Kumar C. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCSpinner.h"

@interface KCHUD : NSObject

+ (instancetype) sharedHUD;

/// Blocks the user interations for the view controller and shows HUD.
+ (void) showBlockingHUD : (UIViewController *) viewController;

/// Shows non-blocking small HUD.
+ (void) showMiniHUDInView : (UIView *) view;

/// Shows blocking HUD
+ (void) showBlockingHUDInView : (UIView *) view;

/// Shows non-blocking HUD
+ (void) showProgressHUD : (UIViewController *) viewController;

/// Removes the HUD from the view controller and enables user interation.
+ (void) hideProgressHUD : (UIViewController *) viewController;

/// Shows non-blocking HUD.
+ (void) showProgressHUDInView : (UIView *) view;

/// Hides the HUD.
+ (void) hideProgressHUDInView : (UIView *) view;

@end
