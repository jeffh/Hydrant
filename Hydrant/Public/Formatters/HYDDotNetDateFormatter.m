#import "HYDDotNetDateFormatter.h"
#import "HYDFunctions.h"


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

- (BOOL)getObjectValue:(out __autoreleasing id *)obj forString:(NSString *)string errorDescription:(out __autoreleasing NSString **)error
{
    HYDSetObjectPointer(obj, nil);

    NSTextCheckingResult *result = [dateRegExpr__ firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    if (!result) {
        HYDSetObjectPointer(error, HYDLocalizedStringFormat(@"The value '%@' is not a valid .net date", string));
        return NO;
    }
    NSString *epochTimeInMilliseconds = [string substringWithRange:[result rangeAtIndex:1]];
    HYDSetObjectPointer(obj, [NSDate dateWithTimeIntervalSince1970:epochTimeInMilliseconds.doubleValue / 1000.0]);
    return YES;
}

- (NSString *)stringForObjectValue:(id)obj
{
    if (![obj isKindOfClass:[NSDate class]]) {
        return nil;
    }

    NSDate *date = obj;

    NSString *timeZone = [super stringForObjectValue:date];
    if ([timeZone isEqualToString:@"+0000"]) {
        timeZone = @"";
    }
    NSTimeInterval milliseconds = date.timeIntervalSince1970 * 1000.0;
    return [NSString stringWithFormat:@"/Date(%1.0f%@)/", milliseconds, timeZone];
}

@end
