#import <Foundation/Foundation.h>

@interface JKSDotNetDateFormatter : NSDateFormatter

- (id)init;

- (NSString *)stringFromDate:(NSDate *)date;
- (NSDate *)dateFromString:(NSString *)string;

@end
