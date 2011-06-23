//
//  MBProgressHUD+TaskExecute.m
//
//  Created by Gustavo Ambrozio on 22/6/11.
//  Copyright 2011 CodeCrop Software. All rights reserved.
//

#import "MBProgressHUD+TaskExecute.h"

@implementation MBProgressHUD (TaskExecute)

+ (id)showHUDAddedTo:(UIView *)view 
            animated:(BOOL)animated
           withLabel:(NSString*)label
         cancelLabel:(NSString*)cancelLabel
            priority:(long)priority
        hudCustomize:(void (^)(MBProgressHUD *hud))hudCustomize
         executeTask:(id (^)(void))task {
    
    __block id blockReturn = nil;
    __block BOOL finished = NO;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(priority, 0), ^{
        blockReturn = [task() retain];
        finished = YES;
        dispatch_semaphore_signal(sem);
    });
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if (label)
        hud.labelText = label;
    if (cancelLabel)
        hud.detailsLabelText = cancelLabel;
    if (hudCustomize)
        hudCustomize(hud);
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    while (!finished && (cancelLabel == nil || hud.tag == 0)) {
        [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
    }
    [MBProgressHUD hideHUDForView:view animated:YES];
    
    id ret = nil;
    BOOL returnReleased = NO;
    if (finished) {
        ret = [blockReturn autorelease];
        returnReleased = YES;
    }
    
    if (!returnReleased) {
        // In this case I have to release the object myself.
        dispatch_async(dispatch_get_global_queue(priority, 0), ^{
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            [blockReturn release];
            dispatch_release(sem);
        });
    } else {
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        dispatch_release(sem);
    }
    
    return ret;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Center HUD
    CGRect allRect = self.bounds;
    // Draw rounded HUD bacgroud rect
    CGRect boxRect = CGRectMake(roundf((allRect.size.width - width) / 2) + xOffset,
                                roundf((allRect.size.height - height) / 2) + yOffset, width, height);
    
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    if (CGRectContainsPoint(boxRect, pt)) {

        [self setTag:1];
    
    }
}

@end
