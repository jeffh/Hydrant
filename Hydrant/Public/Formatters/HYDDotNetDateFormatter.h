#import <Foundation/Foundation.h>


/*! Creates a formatter that is responsible for converting to and from json.net Date-styled output.
 *  Can parse and emit date times formatted in this string: "/Date(1390186634595-0800)/".
 *
 *  @warning This is a customized NSDateFormatter that does not accept any customizations, so using any of the
 *           regular NSDateFormatter customization features may break this formatter.
 *
 *  This is available for your own use. If you want to use this in a mapper, use the HYDStringToObjectFormatterMapper
 *  or the HYDObjectToStringFormatterMapper and their associated helper constructors.
 *
 *  @see HYDMapStringToDate
 *  @see HYDMapDateToString
 */
@interface HYDDotNetDateFormatter : NSDateFormatter

- (id)init;

@end
