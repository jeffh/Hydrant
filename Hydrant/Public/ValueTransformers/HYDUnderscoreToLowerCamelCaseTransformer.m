#import "HYDUnderscoreToLowerCamelCaseTransformer.h"

@implementation HYDUnderscoreToLowerCamelCaseTransformer

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    if (![value isKindOfClass:[NSString class]]) {
        return nil;
    }

    NSCharacterSet *characterSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSString *stringValue = [value stringByTrimmingCharactersInSet:characterSet];
    NSMutableString *result = [NSMutableString string];

    BOOL wasPreviousCharacterUnderscored = NO;
    for (NSUInteger i=0; i<stringValue.length; i++) {
        unichar chr = [stringValue characterAtIndex:i];

        if (chr != '_') {
            NSString *character = [stringValue substringWithRange:NSMakeRange(i, 1)];
            if (wasPreviousCharacterUnderscored) {
                [result appendString:[character uppercaseString]];
            } else {
                [result appendString:[character lowercaseString]];
            }
        }
        wasPreviousCharacterUnderscored = (chr == '_');
    }

    return result;
}

- (id)reverseTransformedValue:(id)value
{
    if (![value isKindOfClass:[NSString class]]) {
        return nil;
    }

    NSCharacterSet *characterSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSString *stringValue = [value stringByTrimmingCharactersInSet:characterSet];
    NSMutableString *result = [NSMutableString string];

    for (NSUInteger i=0; i<stringValue.length; i++) {
        NSString *character = [stringValue substringWithRange:NSMakeRange(i, 1)];

        BOOL isCharacterUpperCased = [character isEqualToString:character.uppercaseString];
        if (isCharacterUpperCased && i != 0) {
            [result appendString:@"_"];
        }
        [result appendString:[character lowercaseString]];
    }

    return result;
}

@end
