#import <Foundation/Foundation.h>

@interface HYDDotNetDateFormatter : NSDateFormatter

- (id)init;

- (NSString *)stringFromDate:(NSDate *)date;
- (NSDate *)dateFromString:(NSString *)string;

@end
