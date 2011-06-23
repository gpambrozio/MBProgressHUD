//
//  MBProgressHUD+TaskExecute.h
//
//  Created by Gustavo Ambrozio on 22/6/11.
//  Copyright 2011 CodeCrop Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface MBProgressHUD (TaskExecute)

+ (id)showHUDAddedTo:(UIView *)view 
            animated:(BOOL)animated
           withLabel:(NSString*)label
         cancelLabel:(NSString*)cancelLabel
            priority:(long)priority
        hudCustomize:(void (^)(MBProgressHUD *hud))hudCustomize
         executeTask:(id (^)(void))task;

@end
