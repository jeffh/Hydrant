#import "HYDURLFormatter.h"
#import "HYDFunctions.h"

@implementation HYDURLFormatter

- (id)init
{
    return [super init];
}

- (id)initWithAllowedSchemes:(NSSet *)allowedSchemes
{
    self = [super init];
    if (self) {
        self.allowedSchemes = allowedSchemes;
    }
    return self;
}

#pragma mark - NSFormatter

- (BOOL)getObjectValue:(out __autoreleasing id *)obj forString:(NSString *)string errorDescription:(out __autoreleasing NSString **)error
{
    HYDSetObjectPointer(obj, nil);

    if (![string isKindOfClass:[NSString class]]) {
        HYDSetObjectPointer(error, HYDLocalizedStringFormat(@"The value '%@' is not a string", string));
        return NO;
    }

    NSURL *url = [NSURL URLWithString:string];
    if (!url.scheme) {
        HYDSetObjectPointer(error, HYDLocalizedStringFormat(@"The value '%@' is not a valid URL", string));
        return NO;
    }

    if (self.allowedSchemes && ![self.allowedSchemes containsObject:url.scheme.lowercaseString]) {
        NSString *allowedSchemes = [self.allowedSchemes.allObjects componentsJoinedByString:@", "];
        HYDSetObjectPointer(error, HYDLocalizedStringFormat(@"The value '%@' is not a valid URL with an accepted scheme: %@", string, allowedSchemes));
        return NO;
    }

    HYDSetObjectPointer(obj, url);

    return YES;
}

- (NSString *)stringForObjectValue:(id)obj
{
    if (![obj isKindOfClass:[NSURL class]]) {
        return nil;
    }

    NSURL *url = obj;

    if (self.allowedSchemes && ![self.allowedSchemes containsObject:url.scheme.lowercaseString]) {
        return nil;
    }

    return url.absoluteString;
}


@end
