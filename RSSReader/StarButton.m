//
//  StarButton.m
//  RSSReader
//
//  Created by NSSimpleApps on 31.05.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import "StarButton.h"

@implementation StarButton

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    CGFloat R = MIN(rect.size.height, rect.size.width)/2;
    CGFloat r = 0.449028*R;
    
    CGPoint farPoints[5] = {
        CGPointMake(R*cos(M_PI_2) + R, -R*sin(M_PI_2) + R),
        CGPointMake(R*cos(M_PI_2 + 2*M_PI/5) + R, -R*sin(M_PI_2 + 2*M_PI/5) + R),
        CGPointMake(R*cos(M_PI_2 + 4*M_PI/5) + R, -R*sin(M_PI_2 + 4*M_PI/5) + R),
        CGPointMake(R*cos(M_PI_2 + 6*M_PI/5) + R, -R*sin(M_PI_2 + 6*M_PI/5) + R),
        CGPointMake(R*cos(M_PI_2 + 8*M_PI/5) + R, -R*sin(M_PI_2 + 8*M_PI/5) + R) };
    
    CGPoint nearPoints[5] = {
        CGPointMake(r*cos(M_PI_2 + M_PI/5) + R, -r*sin(M_PI_2 + M_PI/5) + R),
        CGPointMake(r*cos(M_PI_2 + 3*M_PI/5) + R, -r*sin(M_PI_2 + 3*M_PI/5) + R),
        CGPointMake(r*cos(M_PI_2 + 5*M_PI/5) + R, -r*sin(M_PI_2 + 5*M_PI/5) + R),
        CGPointMake(r*cos(M_PI_2 + 7*M_PI/5) + R, -r*sin(M_PI_2 + 7*M_PI/5) + R),
        CGPointMake(r*cos(M_PI_2 + 9*M_PI/5) + R, -r*sin(M_PI_2 + 9*M_PI/5) + R) };
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    
    if (self.isFavorite) {
        
        CGContextSetRGBFillColor(context, 1.0, 1.0, 0.0, 1.0);
    } else {
        
        CGContextSetRGBFillColor(context, 0.666667, 0.666667, 0.666667, 1.0);
    }
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, 1.0);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    CGPathMoveToPoint(pathRef, NULL, farPoints[0].x, farPoints[0].y);
    
    for (NSInteger i = 0; i < 4; i++) {
        
        CGPathAddLineToPoint(pathRef, NULL, nearPoints[i].x, nearPoints[i].y);
        CGPathAddLineToPoint(pathRef, NULL, farPoints[i + 1].x, farPoints[i + 1].y);
    }
    CGPathAddLineToPoint(pathRef, NULL, nearPoints[4].x, nearPoints[4].y);
    CGPathAddLineToPoint(pathRef, NULL, farPoints[0].x, farPoints[0].y);
    
    CGPathCloseSubpath(pathRef);
    
    CGContextAddPath(context, pathRef);
    CGContextFillPath(context);
    
    CGContextAddPath(context, pathRef);
    CGContextStrokePath(context);
    
    CGPathRelease(pathRef);
}

@end
