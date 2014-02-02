#import "HYDUUIDFormatter.h"
#import "HYDFunctions.h"

@implementation HYDUUIDFormatter

#pragma mark - NSFormatter

- (NSString *)stringForObjectValue:(id)obj
{
    if ([obj isKindOfClass:[NSUUID class]]) {
        return [obj UUIDString];
    }
    return nil;
}

- (BOOL)getObjectValue:(out id *)obj forString:(NSString *)string errorDescription:(out NSString **)error
{
    HYDSetObjectPointer(obj, nil);
    if (![string isKindOfClass:[NSString class]]) {
        HYDSetObjectPointer(error, HYDLocalizedStringFormat(@"The value '%@' is not a valid string", string));
        return NO;
    }

    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:string];

    if (!uuid) {
        HYDSetObjectPointer(error, HYDLocalizedStringFormat(@"The value '%@' is not a valid UUID", string));
        return NO;
    }

    HYDSetObjectPointer(obj, uuid);
    return YES;
}

@end
