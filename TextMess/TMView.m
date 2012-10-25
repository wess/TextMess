//
//  TMView.m
//  TextMess
//
//  Created by Wess Cope on 10/25/12.
//  Copyright (c) 2012 Wess Cope. All rights reserved.
//

#import "TMView.h"
#import "WCAttributedString.h"

#define PATH_FOR_RESOURCE(filename, type)   [[NSBundle mainBundle] pathForResource:filename ofType:type]
#define READ_FILE(filename, type)           [[NSString alloc] initWithContentsOfFile:PATH_FOR_RESOURCE(filename, type) encoding:NSUTF8StringEncoding error:nil]

static CGFloat const kFrameInset = 10.0f;

@interface TMView()
{
    CTFramesetterRef    _framesetter;
    CGFloat             _lastScale;
}
@property (strong, nonatomic)    NSAttributedString     *text;
@property (readwrite, nonatomic) CGRect                 clippingFrame;
@property (strong, nonatomic) UIPinchGestureRecognizer  *pinchGesture;

- (void)updateClippingSize:(UIPinchGestureRecognizer *)gesture;
@end

@implementation TMView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        NSString *content               = [READ_FILE(@"test", @"txt") stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        WCAttributedString *attrString  = [WCAttributedString attributedString];
        attrString.font                 = [UIFont systemFontOfSize:18.0f];
        attrString.lineHeight           = 20.0f;
        [attrString append:content];
        
        self.text               = [attrString.string copy];
        self.backgroundColor    = [UIColor whiteColor];
        
        _clippingFrame = CGRectZero;
        
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(updateClippingSize:)];
        [self addGestureRecognizer:_pinchGesture];
    }
    return self;
}

- (void)dealloc
{
    CFRelease(_framesetter);
}

- (void)updateClippingSize:(UIPinchGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateEnded)
        _lastScale = 1.0f;
    
    
    CGPoint gesturePoint = [gesture locationInView:self];
    if(CGRectContainsPoint(_clippingFrame, gesturePoint))
    {
        CGFloat scale       = 1.0 - (_lastScale - gesture.scale);
        _lastScale          = gesture.scale;
        CGSize scaleSize    = CGSizeScale(_clippingFrame.size, scale);
        CGPoint scaleCenter = CGPointMake((gesturePoint.x - (scaleSize.width / 2)), (gesturePoint.y - (scaleSize.height / 2)));
        
        _clippingFrame.size = scaleSize;
        _clippingFrame.origin = scaleCenter;
        
        
        [self setNeedsDisplay];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(touches.count > 1)
        return;

    UITouch *touch      = [touches anyObject];
    CGPoint touchPoint  = [touch locationInView:self];
    CGFloat touchSize   = 100.0f + (kFrameInset * 2);
    CGFloat x           = touchPoint.x - (touchSize / 2);
    CGFloat y           = touchPoint.y - (touchSize / 2);
    
    _clippingFrame = CGRectMake(x, y, touchSize, touchSize);
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(touches.count > 1)
        return;
    
    UITouch *touch      = [touches anyObject];
    CGPoint touchPoint  = [touch locationInView:self];
    CGFloat touchSize   = 100.0f + (kFrameInset * 2);
    CGFloat x           = touchPoint.x - (touchSize / 2);
    CGFloat y           = touchPoint.y - (touchSize / 2);
    
    _clippingFrame = CGRectMake(x, y, touchSize, touchSize);
    [self setNeedsDisplay];    
}

- (void)drawRect:(CGRect)rect
{
    CGRect frame         = CGRectInset(rect, kFrameInset, kFrameInset);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);

    
    CGRect flippedClippingFrame = CGRectInvert(frame, _clippingFrame);
    
    CGMutablePathRef flippedClippingPath = CGPathCreateMutable();
    CGPathAddRect(flippedClippingPath, NULL, flippedClippingFrame);
    
    
    CFStringRef keys[]                  = { kCTFramePathClippingPathAttributeName };
    CFTypeRef values[]                  = { flippedClippingPath };
    CFDictionaryRef clippingPathDict    = CFDictionaryCreate(NULL,  (const void **)&keys, (const void **)&values, (sizeof(keys) / sizeof(keys[0])),  &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    NSArray *clippingPaths              = [NSArray arrayWithObject:(__bridge NSDictionary*)clippingPathDict];
    NSDictionary *optionsDict           = [NSDictionary dictionaryWithObject:clippingPaths forKey:(NSString*)kCTFrameClippingPathsAttributeName];
    
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, frame);

    if(_framesetter == NULL)
        _framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_text);
    
    CTFrameRef ctFrame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, 0), path, (__bridge CFDictionaryRef)optionsDict);
    
    CTFrameDraw(ctFrame, context);
    CGPathRelease(path);
    CFRelease(ctFrame);
}

@end
