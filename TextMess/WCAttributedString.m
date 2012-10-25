//
//  WCAttributedString.m
//  Bizjournals
//
//  Created by Wess Cope on 10/16/12.
//  Copyright (c) 2012 ACBJ. All rights reserved.
//

#import "WCAttributedString.h"
#import <CoreText/CoreText.h>

@implementation NSAttributedString (Height)

- (CGSize)sizeForAttributedStringWithWidth:(CGFloat)width
{
    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self);
    
    CFIndex offset = 0, length;
    CGFloat y = 0;
    do {
        length = CTTypesetterSuggestLineBreak(typesetter, offset, width);
        CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(offset, length));
        
        CGFloat ascent, descent, leading;
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        CFRelease(line);
        
        offset += length;
        y += ascent + descent + leading;
    } while (offset < [self length]);
    
    CFRelease(typesetter);
    
    return CGSizeMake(width, ceil(y));
}

@end

#define MATCHSTART(STR1, STR2) ([[STR1 uppercaseString] hasPrefix:[STR2 uppercaseString]])

@implementation WCAttributedString
@synthesize string          = _string;
@synthesize font            = _font;
@synthesize color           = _color;
@synthesize textAlignment   = _textAlignment;
@synthesize linebreakMode   = _linebreakMode;
@synthesize lineHeight      = _lineHeight;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _string     = [[NSMutableAttributedString alloc] init];
        _font       = [UIFont systemFontOfSize:12.0f];
        _lineHeight = 16.0f;
    }
    
    return self;
}

+ (id)attributedString
{
    return [[self alloc] init];
}

- (uint8_t) ctAlignment
{
	if (!_textAlignment) return kCTNaturalTextAlignment;
	if (MATCHSTART(_textAlignment, @"n")) return kCTNaturalTextAlignment;
	if (MATCHSTART(_textAlignment, @"l")) return kCTLeftTextAlignment;
	if (MATCHSTART(_textAlignment, @"c")) return kCTCenterTextAlignment;
	if (MATCHSTART(_textAlignment, @"r")) return kCTRightTextAlignment;
	if (MATCHSTART(_textAlignment, @"j")) return kCTJustifiedTextAlignment;
	return kCTNaturalTextAlignment;
}

- (uint8_t) ctBreakMode
{
	if (!_linebreakMode) return kCTLineBreakByWordWrapping;
	if (MATCHSTART(_linebreakMode, @"word")) return kCTLineBreakByWordWrapping;
	if (MATCHSTART(_linebreakMode, @"char")) return kCTLineBreakByCharWrapping;
	if (MATCHSTART(_linebreakMode, @"clip")) return kCTLineBreakByClipping;
	if (MATCHSTART(_linebreakMode, @"head")) return kCTLineBreakByTruncatingHead;
	if (MATCHSTART(_linebreakMode, @"tail")) return kCTLineBreakByTruncatingTail;
	if (MATCHSTART(_linebreakMode, @"mid")) return kCTLineBreakByTruncatingMiddle;
	return kCTLineBreakByWordWrapping;
}

- (CTParagraphStyleRef) newParagraphStyle
{
	int addedTraits = 0;
	if (_textAlignment) addedTraits++;
	if (_linebreakMode) addedTraits++;
    //	if (!addedTraits) return nil;
    
	uint8_t theAlignment = [self ctAlignment];
	CTParagraphStyleSetting alignSetting = {
		kCTParagraphStyleSpecifierAlignment,
		sizeof(uint8_t),
		&theAlignment};
    
	uint8_t theLineBreak = [self ctBreakMode];
	CTParagraphStyleSetting wordBreakSetting = {
		kCTParagraphStyleSpecifierLineBreakMode,
		sizeof(uint8_t),
		&theLineBreak};
    
    CGFloat lineSpacing = _lineHeight;
    //    CGFloat minLineSize = 0.0f;
    //    CGFloat maxLineSize = CGFLOAT_MAX;
    
    CTParagraphStyleSetting settings[8] = {
        alignSetting,
        wordBreakSetting,
        (CTParagraphStyleSetting){ kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(float_t), (float_t[]){ 0.01f } },
        (CTParagraphStyleSetting){ kCTParagraphStyleSpecifierMinimumLineHeight,  sizeof(float_t), (float_t[]){ lineSpacing } },
        (CTParagraphStyleSetting){ kCTParagraphStyleSpecifierMaximumLineHeight,  sizeof(float_t), (float_t[]){ lineSpacing } },
        (CTParagraphStyleSetting){ kCTParagraphStyleSpecifierLineSpacing,        sizeof(float_t), (float_t[]){ 0.0f } },
        (CTParagraphStyleSetting){ kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(float_t), (float_t[]){ 0.0f } },
        (CTParagraphStyleSetting){ kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(float_t), (float_t[]){ 0.0f } }
    };
    
	CTParagraphStyleRef paraStyle       = CTParagraphStyleCreate(settings, 8);
    
    //    CTParagraphStyleSetting settings[3] = {alignSetting, wordBreakSetting, lineSpacingSetting};
    //	CTParagraphStyleRef paraStyle       = CTParagraphStyleCreate(settings, 3);
    
	return paraStyle;
}

- (void) append:(NSString *) formatstring, ...
{
    if (!formatstring || [formatstring isEqualToString:@""]) return;
    
    //    formatstring = [formatstring stringByReplacingOccurrencesOfString:@"%" withString:@"%%"];
    
	va_list arglist;
	va_start(arglist, formatstring);
	NSString *outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
    
	CTFontRef basicFontRef = CTFontCreateWithName((__bridge CFStringRef)_font.fontName, _font.pointSize, NULL);
	NSMutableDictionary *basicFontAttr = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										  (__bridge id) basicFontRef, (__bridge NSString *) kCTFontAttributeName,
										  nil];
	CFRelease(basicFontRef);
    
	if (_color)
		[basicFontAttr setObject:(__bridge id) _color.CGColor forKey:(__bridge NSString *)kCTForegroundColorAttributeName];
    
	CTParagraphStyleRef style = [self newParagraphStyle];
	if (style)
    {
		[basicFontAttr setObject:(__bridge id)style forKey:(__bridge NSString *)kCTParagraphStyleAttributeName];
        CFRelease(style);
    }
    
	NSAttributedString *newString = [[NSAttributedString alloc] initWithString:outstring attributes:basicFontAttr];
    
	[self.string appendAttributedString:newString];
}


@end