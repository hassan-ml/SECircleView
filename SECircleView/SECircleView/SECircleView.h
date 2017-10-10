//
//  SECircleView.h
//  
//
//  Created by John Spicer on 2016-01-25.
//  Copyright © 2016 John Spicer. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A custom view that draws the usage circle.
 */
@interface SECircleView : UIView

@property float circleSize;                     /**< The size of the circle. */
@property float percentUsed;                    /**< What percent of the circle to show. */
@property BOOL isOver;                          /**< If true, we show the red circle. */

/**
 Handles drawing of circle (animated)
 */
-(void)showCircle:(NSDictionary*)inData;

/**
 Handles drawing of circle (not animated)
 */
- (void)showText;

/**
 Handles drawing of circle (not animated)
 */
- (void)showTalk;

@end
