//
//  WCAttributedString.h
//  Bizjournals
//
//  Created by Wess Cope on 10/16/12.
//  Copyright (c) 2012 ACBJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Height)
- (CGSize)sizeForAttributedStringWithWidth:(CGFloat)width;
@end

@interface WCAttributedString : NSObject
@property (nonatomic, strong) NSMutableAttributedString *string;
@property (nonatomic, strong) UIFont                    *font;
@property (nonatomic, strong) UIColor                   *color;
@property (nonatomic, strong) NSString                  *textAlignment;
@property (nonatomic, strong) NSString                  *linebreakMode;
@property (nonatomic, readwrite) CGFloat lineHeight;
@property (assign, nonatomic) BOOL isHTML;

+ (id)attributedString;
- (void) append:(NSString *)formattedString, ...;

@end