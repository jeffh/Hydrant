#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HYDCamelCaseStyle) {
    HYDCamelCaseLowerStyle,
    HYDCamelCaseUpperStyle,
};

@interface HYDSnakeToCamelCaseValueTransformer : NSValueTransformer

- (id)init;
- (id)initWithCamelCaseStyle:(HYDCamelCaseStyle)camelCaseStyle;

@end
