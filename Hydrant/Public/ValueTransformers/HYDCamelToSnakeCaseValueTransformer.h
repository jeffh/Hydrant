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

/*! A value transformer that converts from strings in
 *  camel case (camelCase or CamelCase) into snake case (snake_case).
 *
 *  This is useful for key transforming for the reflective mapper.
 *
 *  The default constructor uses HYDCamelCaseLowerStyle.
 *
 *  @see HYDReflectiveMapper
 */
@interface HYDCamelToSnakeCaseValueTransformer : NSValueTransformer

- (instancetype)init;
- (instancetype)initWithCamelCaseStyle:(HYDCamelCaseStyle)camelCaseStyle;

@end
