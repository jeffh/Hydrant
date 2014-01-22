#import <Foundation/Foundation.h>

@interface JOMDotNetDateFormatter : NSDateFormatter

- (id)init;

- (NSString *)stringFromDate:(NSDate *)date;
- (NSDate *)dateFromString:(NSString *)string;

@end
