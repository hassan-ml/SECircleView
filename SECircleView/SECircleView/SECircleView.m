//
//  SECircleView.m
//
//
//  Created by John Spicer on 2016-01-25.
//  Copyright © 2016 John Spicer. All rights reserved.
//

#import "SECircleView.h"
#import "UIColor+HexString.h"

#define SE_OVERAGE_COLOR [UIColor colorWithRed:255/255.0f green:233/255.0f blue:199/255.0 alpha:1.0f] // 0xFFE9C7

@implementation SECircleView

@synthesize circleSize;
@synthesize percentUsed;
@synthesize isOver;

#define     pi                              3.14159
#define     DEGREES_TO_RADIANS(degrees)     ((pi * degrees)/ 180)

/** 
 How does the drawing work: let me show the way!
 
 [REGULAR USAGE]
 
 [1] drawing is from 0 to 360 degrees (from the TOP not the side)
 [2] drawing is counter clockwise
 [3] drawing is from full to zero data remaining
        -> at 100% usage remaining, the full circle is shown
        -> at 0% usage remaining, there is no circle
        -> the last 25% of the circle is a different color or gradient
 
 [OVERAGE]

 [1] drawing is from 0 to 360 degrees (from the TOP not the side)
 [2] drawing is counter clockwise
 [3] Color is red, no gradient
 [4] drawing is from zero usage to full usage in batches of 100MB
        -> at 100% for a bucket, the circle will be redrawn with 200MB being the max
        -> and so on
*/

- (void)drawInsideCircle:(BOOL)showGradient bucketStatus:(BOOL)bucketSizeUnavailableUntilNextBillCycle
{
    // inside circle - always 100%
    {
        // D9EFE1
        UIColor *theColor = [UIColor colorWithHexString:@"cceadf"];
        // Set up the shape of the circle
        CAShapeLayer *circle = [CAShapeLayer layer];
        // Make a circular shape
        CGRect myRect = CGRectMake(0, 0, circleSize, circleSize);
        
        circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(myRect, 4.0f, 4.0f) cornerRadius:circleSize].CGPath;
        // Center the shape in self.view
        circle.position = CGPointMake(0, 0);
        
        // Configure the appearance of the circle
        circle.fillColor = theColor.CGColor;
        circle.strokeColor = theColor.CGColor;
        circle.lineWidth = 0;
        
        // Add to parent layer
        [self.layer addSublayer:circle];
        
        if (bucketSizeUnavailableUntilNextBillCycle == YES)
        {
            return;
        }
        
        if (showGradient == NO)
            return;

        // now our circle outside
        // 0x538711
        theColor = [UIColor colorWithHexString:@"00955e"];
        
        float lineWidth = 11.0f;
        
        // Set up the shape of the circle
        CAShapeLayer *circle1 = [CAShapeLayer layer];
        // Make a circular shape
        CGRect theFrame = CGRectMake(0, 0, circleSize, circleSize);
        circle1.path = [UIBezierPath bezierPathWithRoundedRect:theFrame cornerRadius:circleSize].CGPath;
        // Center the shape in self.view
        circle1.position = CGPointMake(0, 0);
        
        // Configure the apperence of the circle
        circle1.fillColor = [UIColor clearColor].CGColor;
        circle1.strokeColor = theColor.CGColor;
        circle1.lineWidth = lineWidth;
        
        // Add to parent layer
        [self.layer addSublayer:circle1];

        // now for our gradient. I could not find any code that would
        // let you apply a gradient along an arc.
        // so we will just have 90 or so different colors
        {
            // we have the colors now: xF59829 (R:245 G:152 B:41) and end is 0x00955E (R:00 G:149 B:94)
            CGPoint center = CGPointMake(100, 100);
            float radius = 100.0f;
            NSInteger endAngle, startAngle;
            float red, green, blue;
            //#f59829
            red             = 245.0f;
            green           = 152.0f;
            blue            = 41.0f;
            startAngle = -90;

            for (endAngle = -89; endAngle <= 0; endAngle += 1)
            {
                //DLog(@"startAngle = %ld, endAngle = %ld", (long)startAngle, (long)endAngle);
                UIColor *color = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0f];
                
                CAShapeLayer *circle = [CAShapeLayer layer];
                circle.path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:DEGREES_TO_RADIANS(startAngle) endAngle:DEGREES_TO_RADIANS(endAngle) clockwise:YES].CGPath;
                circle.position = CGPointMake(0, 0);
                
                // Configure the appearence of the circle
                circle.fillColor = [UIColor clearColor].CGColor;
                circle.strokeColor = color.CGColor;
                circle.lineWidth = lineWidth;
                
                // Add to parent layer
                [self.layer addSublayer:circle];
                
                // I did this backwards.
                // What the hell was I thinking??
                // red gets decremented (245-0)/90 = 2.72
                red -= 1.8f;//2.72f;
                // green gets decremented (152-149)/90 = 0.033
                green -= 0.188888888;//0.033f;
                // blue gets incremented (94-41)/90 = 0.588
                blue += 0.26666667;//0.588;
                startAngle += 1;
                NSLog(@"colors r:%f g:%f b:%f", red, green, blue);
            }
            
        }
    }
}

-(void)showCircle:(NSDictionary*)inData
{
    /*
     [REGULAR USAGE]
     
     [1] drawing is from 0 to 360 degrees (from the TOP not the side)
     [2] drawing is counter clockwise
     [3] drawing is from full to zero data remaining
     -> at 100% usage remaining, the full circle is shown
     -> at 0% usage remaining, there is no circle
     -> the last 25% of the circle is a different color or gradient
     */
    
    BOOL bucketSizeUnavailableUntilNextBillCycle = [[inData objectForKey:@"bucketSizeUnavailableUntilNextBillCycle"] boolValue];

    NSInteger overage = [[inData objectForKey:@"overage"] integerValue];
    if (overage > 0 && !bucketSizeUnavailableUntilNextBillCycle)
    {
        [self doOverageDrawing:overage];

        return;
    }
    
    [self drawInsideCircle:YES bucketStatus:bucketSizeUnavailableUntilNextBillCycle];

    if (bucketSizeUnavailableUntilNextBillCycle == YES)
    {
        return;
    }
    
    // draw a white ark counter clockwise to erase what they've used
    {
        long totalUsed = [[inData objectForKey:@"totalDataUsed"] integerValue];
        long remaining = [[inData objectForKey:@"remaining"] integerValue];
        
        long dataUpsell = [[inData objectForKey:@"planUpsellSize"] integerValue];
        
        long total = [[inData objectForKey:@"planSize"] integerValue] + dataUpsell;
        NSLog(@"SECircleView:showCircle::total = %ld, remaining = %ld", total, remaining);
        
        percentUsed = 100 - (float)(((float)total - (float)totalUsed)/total * 100.0f);
        float endAngle = percentUsed/100.0f;
        float lineWidth = 12.0f;
        
        // Set up the shape of the circle
        CAShapeLayer *circle = [CAShapeLayer layer];
        // Make a circular shape
        circle.path = [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, circleSize, circleSize)
                                                  cornerRadius:circleSize] bezierPathByReversingPath].CGPath;
        
        // Center the shape in self.view
        circle.position = CGPointMake(0, 0);
        
        // Configure the apperence of the circle
        circle.fillColor = [UIColor clearColor].CGColor;
        circle.strokeColor = [UIColor whiteColor].CGColor;
        circle.lineWidth = lineWidth;
        
        // Add to parent layer
        [self.layer addSublayer:circle];
        
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = 2.0f;
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:endAngle];
        pathAnimation.removedOnCompletion = NO;
        pathAnimation.fillMode = kCAFillModeForwards;
        [circle addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    }

/*
 {
 periodGroup = Anytime;     <- NOT USED
 usageSummaryType = D;      <- NOT USED
 used = 0;                  <- NOT USED

 overage = 0;
 remaining = 1048576;
 total = 1048576;
 uom = KB;
 }
*/
}

- (void)doOverageDrawing:(long)overage
{
/*
    [OVERAGE]
    
    [1] [REDACTED] drawing is from 0 to 360 degrees (from the TOP not the side)
    [2] [REDACTED] drawing is counter clockwise
    [3] [REDACTED] Color is red, no gradient
    [4] [REDACTED] drawing is from zero usage to full usage in batches of 100MB
            -> at 100% for a bucket, the circle will be redrawn with 200MB being the max
            -> and so on
 
    [1] So now, we just draw the inner circle in a different color
            -> no circle drawn on the outside
*/
    
    //DLog(@"SECircleView:doOverageDrawing::overage = %ld", overage);
    
    // inside circle - always 100%
    {
        // #FFE9C7
        UIColor *theColor = SE_OVERAGE_COLOR;
        // Set up the shape of the circle
        CAShapeLayer *circle = [CAShapeLayer layer];
        // Make a circular shape
        CGRect myRect = CGRectMake(0, 0, circleSize, circleSize);
        
        circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(myRect, 4.0f, 4.0f) cornerRadius:circleSize].CGPath;
        // Center the shape in self.view
        circle.position = CGPointMake(0, 0);
        
        // Configure the appearance of the circle
        circle.fillColor = theColor.CGColor;
        circle.strokeColor = theColor.CGColor;
        circle.lineWidth = 0;
        
        // Add to parent layer
        [self.layer addSublayer:circle];
    }
}


//- (void)doNextBillCycleUnavailableDrawing:(long)overage
//{
//    /*
//     [OVERAGE]
//     
//     [1] [REDACTED] drawing is from 0 to 360 degrees (from the TOP not the side)
//     [2] [REDACTED] drawing is counter clockwise
//     [3] [REDACTED] Color is red, no gradient
//     [4] [REDACTED] drawing is from zero usage to full usage in batches of 100MB
//             -> at 100% for a bucket, the circle will be redrawn with 200MB being the max
//         -> and so on
//     
//     [1] So now, we just draw the inner circle in a different color
//     -> no circle drawn on the outside
//     */
//    
//    //DLog(@"SECircleView:doOverageDrawing::overage = %ld", overage);
//    
//    // inside circle - always 100%
//    {
//        need the color for the grey
//        // #FFE9C7
//        UIColor *theColor = UIColor colorWithHexString:@"";
//        // Set up the shape of the circle
//        CAShapeLayer *circle = [CAShapeLayer layer];
//        // Make a circular shape
//        CGRect myRect = CGRectMake(0, 0, circleSize, circleSize);
//        
//        circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(myRect, 4.0f, 4.0f) cornerRadius:circleSize].CGPath;
//        // Center the shape in self.view
//        circle.position = CGPointMake(0, 0);
//        
//        // Configure the appearance of the circle
//        circle.fillColor = theColor.CGColor;
//        circle.strokeColor = theColor.CGColor;
//        circle.lineWidth = 0;
//        
//        // Add to parent layer
//        [self.layer addSublayer:circle];
//    }
//}

- (void)showText
{
    [self drawInsideCircle:NO bucketStatus:NO];
}

- (void)showTalk
{
    [self drawInsideCircle:NO bucketStatus:NO];
}

@end
