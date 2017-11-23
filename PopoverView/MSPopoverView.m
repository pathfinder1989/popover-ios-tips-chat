//
//  MSPopoverView.m
//  Test
//
//  Created by meishi on 22/11/2017.
//  Copyright © 2017 Kangbo. All rights reserved.
//

#import "MSPopoverView.h"

typedef NS_ENUM(NSUInteger, MSPointDirection){
    MSPointDirection_up,
    MSPointDirection_down
};

typedef enum {
    MSPopoverAnimationSlide = 0,
    MSPopoverAnimationPop,
    MSPopoverAnimationScale
} MSPopoverAnimation;

@interface MSPopoverView ()

@property(assign ,nonatomic) MSPointDirection pointDirection;
@property(assign ,nonatomic) CGPoint targetPoint;

@property(assign ,nonatomic) CGFloat pointerSize;

@property(nonatomic, assign) CGFloat topMargin;
@property(nonatomic, assign) CGFloat sidePadding;

@property(assign ,nonatomic) CGSize bubbleSize;

@property(nonatomic, strong) id targetObject;

@property(nonatomic, assign) MSPopoverAnimation animation;
@property(strong ,nonatomic) UIView *customView;
@end

@implementation MSPopoverView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithCustomView:(UIView *)customView
{
    self = [super init];
    if (self) {
        [self initialization];
        self.customView = customView;
        [self addSubview:customView];
    }
    return self;
}

- (void)initialization
{
    self.opaque = NO;
    _cornerRadius = 10.0;
    
    _topMargin = 2.0;
    _pointerSize = 12.0;
    _sidePadding = 2.0;
    
    _contentBgColor = [UIColor blackColor];
    _animation = MSPopoverAnimationScale;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_customView) {
        CGRect customRect = [self contentFrame];
        _customView.frame = customRect;
    }
}

//
//除了箭头以外的圆弧形的frame大小
- (CGRect)bubbleFrame
{
    CGRect bubbleFrame;
    if (_pointDirection == MSPointDirection_up) {
        bubbleFrame = CGRectMake(2.0, _targetPoint.y + _pointerSize, _bubbleSize.width, _bubbleSize.height);
    }
    else {
        bubbleFrame = CGRectMake(2.0, _targetPoint.y - _pointerSize - _bubbleSize.height, _bubbleSize.width, _bubbleSize.height);
    }
    return bubbleFrame;
}

//内容区域的大小
- (CGRect)contentFrame
{
    CGRect bubbleFrame = [self bubbleFrame];
    CGRect contentFrame = CGRectInset(bubbleFrame, _cornerRadius, _cornerRadius);
    
    return contentFrame;
}

- (void)drawRect:(CGRect)rect
{
    CGRect bubbleRect = [self bubbleFrame];
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 1.0);
    
    CGContextSetStrokeColorWithColor(c, _contentBgColor.CGColor);
    CGContextSetFillColorWithColor(c, _contentBgColor.CGColor);
    
    //创建可变路径
    CGMutablePathRef bubblePath = CGPathCreateMutable();
    //箭头朝上
    if (_pointDirection == MSPointDirection_up) {
        CGPathMoveToPoint(bubblePath, NULL, _targetPoint.x, _targetPoint.y);
        CGPathAddLineToPoint(bubblePath, NULL, _targetPoint.x+_pointerSize, _targetPoint.y+_pointerSize);
        
        CGPathAddArcToPoint(bubblePath, NULL,
                            bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y,
                            bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+_cornerRadius,
                            _cornerRadius);
        CGPathAddArcToPoint(bubblePath, NULL,
                            bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+bubbleRect.size.height,
                            bubbleRect.origin.x+bubbleRect.size.width-_cornerRadius, bubbleRect.origin.y+bubbleRect.size.height,
                            _cornerRadius);
        CGPathAddArcToPoint(bubblePath, NULL,
                            bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height,
                            bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height-_cornerRadius,
                            _cornerRadius);
        CGPathAddArcToPoint(bubblePath, NULL,
                            bubbleRect.origin.x, bubbleRect.origin.y,
                            bubbleRect.origin.x+_cornerRadius, bubbleRect.origin.y,
                            _cornerRadius);
        CGPathAddLineToPoint(bubblePath, NULL, _targetPoint.x-_pointerSize, _targetPoint.y+_pointerSize);
    }
    else {
        CGPathMoveToPoint(bubblePath, NULL, _targetPoint.x, _targetPoint.y);
        CGPathAddLineToPoint(bubblePath, NULL, _targetPoint.x-_pointerSize, _targetPoint.y-_pointerSize);
        
        CGPathAddArcToPoint(bubblePath, NULL,
                            bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height,
                            bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height-_cornerRadius,
                            _cornerRadius);
        CGPathAddArcToPoint(bubblePath, NULL,
                            bubbleRect.origin.x, bubbleRect.origin.y,
                            bubbleRect.origin.x+_cornerRadius, bubbleRect.origin.y,
                            _cornerRadius);
        CGPathAddArcToPoint(bubblePath, NULL,
                            bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y,
                            bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+_cornerRadius,
                            _cornerRadius);
        CGPathAddArcToPoint(bubblePath, NULL,
                            bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+bubbleRect.size.height,
                            bubbleRect.origin.x+bubbleRect.size.width-_cornerRadius, bubbleRect.origin.y+bubbleRect.size.height,
                            _cornerRadius);
        CGPathAddLineToPoint(bubblePath, NULL, _targetPoint.x+_pointerSize, _targetPoint.y-_pointerSize);
    }
    
    CGPathCloseSubpath(bubblePath);
    
    CGContextAddPath(c, bubblePath);
    CGContextDrawPath(c, kCGPathFillStroke);
    
    CGPathRelease(bubblePath);
}

#pragma mark - animate
- (void)popoverAtView:(UIView *)targetView inView:(UIView *)containerView animated:(BOOL)animated
{
    if (!self.targetObject) {
        self.targetObject = targetView;
    }
    [containerView addSubview:self];
    
    CGSize textSize = CGSizeZero;
    if (self.customView != nil) {
        textSize = self.customView.frame.size;
    }
    if (CGSizeEqualToSize(textSize, CGSizeZero)) {
        textSize = CGSizeMake(120, 60);
    }
    
    _bubbleSize = CGSizeMake(textSize.width + _cornerRadius * 2, textSize.height + _cornerRadius * 2);
    
    //将目标view转换到某一个view上的坐标 两个放到一个坐标系中
    CGPoint targetRelativeOrigin = [targetView.superview convertPoint:targetView.frame.origin toView:containerView.superview];
    CGPoint containerRelativeOrigin = [containerView.superview convertPoint:containerView.frame.origin toView:containerView.superview];
    
    CGFloat pointerY;
    //如果目标view在上面，则箭头朝上 向下弹出
    if (targetRelativeOrigin.y + targetView.bounds.size.height < containerRelativeOrigin.y) {
        pointerY = 0.0;
        _pointDirection = MSPointDirection_up;
    }
    //如果目标view 在下面，则箭头朝下 向上弹出
    else if (targetRelativeOrigin.y > containerRelativeOrigin.y + containerView.bounds.size.height) {
        pointerY = containerView.bounds.size.height;
        _pointDirection = MSPointDirection_down;
    }
    else {
        CGPoint targetOriginInContainer = [targetView convertPoint:CGPointMake(0.0, 0.0) toView:containerView];
        CGFloat sizeBelow = containerView.bounds.size.height - targetOriginInContainer.y;
        if (sizeBelow > targetOriginInContainer.y) {
            pointerY = targetOriginInContainer.y + targetView.bounds.size.height;
            _pointDirection = MSPointDirection_up;
        }
        else {
            pointerY = targetOriginInContainer.y;
            _pointDirection = MSPointDirection_down;
        }
    }
    
    CGFloat containerViewWidth = containerView.frame.size.width;
    
    //目标view的中心点
    CGPoint targetCenter = [targetView.superview convertPoint:targetView.center toView:containerView];
    
    CGFloat targetCenterX = targetCenter.x;
    CGFloat x_b = targetCenterX - roundf(_bubbleSize.width/2);
    if (x_b < _sidePadding) {
        x_b = _sidePadding;
    }
    if (x_b + _bubbleSize.width + _sidePadding > containerViewWidth) {
        x_b = containerViewWidth - _bubbleSize.width - _sidePadding;
    }
    if (targetCenterX - _pointerSize < x_b + _cornerRadius) {
        targetCenterX = x_b + _cornerRadius + _pointerSize;
    }
    
    if (targetCenterX + _pointerSize > x_b + _bubbleSize.width - _cornerRadius) {
        targetCenterX = x_b + _bubbleSize.width - _cornerRadius - _pointerSize;
    }
    
    CGFloat fullHeight = _bubbleSize.height + _pointerSize + 10.0;
    
    CGFloat y_b;
    if (_pointDirection == MSPointDirection_up) {
        y_b = _topMargin + pointerY;
        _targetPoint = CGPointMake(targetCenterX - x_b, 0);
    }
    else {
        y_b = pointerY - fullHeight;
        _targetPoint = CGPointMake(targetCenterX - x_b, fullHeight-2.0);
    }
    
    CGRect finalFrame = CGRectMake(x_b - _sidePadding,
                                   y_b,
                                   _bubbleSize.width + _sidePadding * 2,
                                   fullHeight);
    
    if (animated) {
        if (_animation == MSPopoverAnimationSlide) {
            self.alpha = 0.0;
            CGRect startFrame = finalFrame;
            startFrame.origin.y += 10;
            self.frame = startFrame;
        }
        else if (_animation == MSPopoverAnimationPop) {
            self.frame = finalFrame;
            self.alpha = 0.5;
            
            self.transform = CGAffineTransformMakeScale(0.75f, 0.75f);
            
            [UIView animateWithDuration:.3 animations:^{
                self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
                self.alpha = 1.0;
            } completion:^(BOOL finished) {
                self.transform = CGAffineTransformIdentity;
            }];
            
        }
        else if (_animation == MSPopoverAnimationScale){
            //self.layer.anchorPoint = CGPointMake(_targetPoint.x / self.frame.size.width, _targetPoint.y / self.frame.size.height);
            self.frame = finalFrame;
            self.alpha = 0.f;
            self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
                self.alpha = 1.f;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.transform = CGAffineTransformIdentity;
                } completion:nil];
            }];
        }

        [self setNeedsDisplay];

        if (_animation == MSPopoverAnimationSlide) {
            [UIView beginAnimations:nil context:nil];
            self.alpha = 1.0;
            self.frame = finalFrame;
            [UIView commitAnimations];
        }
    }
    else {
        [self setNeedsDisplay];
        self.frame = finalFrame;
    }
}

- (void)dismissAnimated:(BOOL)animated
{
    if (animated) {
        CGRect frame = self.frame;
        frame.origin.y += 10.0;
        
        [UIView animateWithDuration:.3 animations:^{
            self.alpha = 0.0;
            self.frame = frame;
        } completion:^(BOOL finished) {
            [self finaliseDismiss];
        }];
    }
    else {
        [self finaliseDismiss];
    }
}

- (void)finaliseDismiss
{
    [self removeFromSuperview];
    self.targetObject = nil;
}
@end
