#import <Foundation/Foundation.h>

/*! Represents the specific camel-casing style.
 *
 *  - HYDCamelCaseLowerStyle is where the first letter is lowercased (eg - camelCase)
 *  - HYDCamelCaseUpperStyle is where the first letter is uppercased (eg - CamelCase)
 */
typedef NS_ENUM(NSUInteger, HYDCamelCaseStyle) {
    HYDCamelCaseLowerStyle,
    HYDCamelCaseUpperStyle,
};

/*! A value transformer that converts from strings in snake case (snake_case)
 *  into camel case (camelCase or CamelCase).
 *
 *  This is useful for key transforming for the reflective mapper.
 *
 *  @see HYDReflectiveMapper
 */
@interface HYDSnakeToCamelCaseValueTransformer : NSValueTransformer

- (id)init;
- (id)initWithCamelCaseStyle:(HYDCamelCaseStyle)camelCaseStyle;

@end
