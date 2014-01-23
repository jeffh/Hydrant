#import "HYDDotNetDateFormatter.h"

@interface HYDDotNetDateFormatter ()
@end

@implementation HYDDotNetDateFormatter

static NSRegularExpression *dateRegExpr__;

+ (void)initialize
{
    NSError *error = nil;
    dateRegExpr__ = [NSRegularExpression regularExpressionWithPattern:@"\\/Date\\((-?\\d+)(([+-]\\d+)?)\\)\\/"
                                                              options:NSRegularExpressionCaseInsensitive
                                                                error:&error];
    NSAssert(error == nil, @"Failed to parse regular expression: %@", error);
}

- (id)init
{
    self = [super init];
    if (self) {
        self.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        self.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        self.dateFormat = @"ZZ";
    }
    return self;
}

#pragma mark - NSFormatter

// TODO: support NSFormatter methods
- (BOOL)getObjectValue:(out __autoreleasing id *)obj forString:(NSString *)string range:(inout NSRange *)rangep error:(out NSError *__autoreleasing *)error
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (NSString *)stringForObjectValue:(id)obj
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - NSDateFormatter

- (NSString *)stringFromDate:(NSDate *)date
{
    NSString *timeZone = [super stringForObjectValue:date];
    if ([timeZone isEqualToString:@"+0000"]) {
        timeZone = @"";
    }
    NSTimeInterval milliseconds = date.timeIntervalSince1970 * 1000.0;
    return [NSString stringWithFormat:@"/Date(%1.0f%@)/", milliseconds, timeZone];
}

- (NSDate *)dateFromString:(NSString *)string
{
    NSTextCheckingResult *result = [dateRegExpr__ firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    if (!result) {
        return nil;
    }
    NSString *epochTimeInMilliseconds = [string substringWithRange:[result rangeAtIndex:1]];
    return [NSDate dateWithTimeIntervalSince1970:epochTimeInMilliseconds.doubleValue / 1000.0];
}


@end
