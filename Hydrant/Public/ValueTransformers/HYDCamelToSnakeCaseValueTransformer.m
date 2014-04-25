#import "HYDCamelToSnakeCaseValueTransformer.h"


@interface HYDCamelToSnakeCaseValueTransformer ()

@property (nonatomic, assign) HYDCamelCaseStyle camelCaseStyle;

@end


@implementation HYDCamelToSnakeCaseValueTransformer

- (id)init
{
    return [self initWithCamelCaseStyle:HYDCamelCaseLowerStyle];
}

- (id)initWithCamelCaseStyle:(HYDCamelCaseStyle)camelCaseStyle
{
    self = [super init];
    if (self) {
        self.camelCaseStyle = camelCaseStyle;
    }
    return self;
}

- (id)transformedValue:(id)value
{
    if (![value isKindOfClass:[NSString class]]) {
        return nil;
    }

    NSString *stringValue = value;
    NSMutableString *result = [NSMutableString string];

    for (NSUInteger i=0; i<stringValue.length; i++) {
        NSString *character = [stringValue substringWithRange:NSMakeRange(i, 1)];

        if ([self isUppercasedString:character] && [self isAlphaNumericCharacter:[character characterAtIndex:0]] && i != 0) {
            [result appendString:@"_"];
        }
        [result appendString:[character lowercaseString]];
    }

    return result;
}

- (id)reverseTransformedValue:(id)value
{
    if (![value isKindOfClass:[NSString class]]) {
        return nil;
    }

    NSString *stringValue = value;
    NSMutableString *result = [NSMutableString string];

    BOOL wasPreviousCharacterUnderscored = NO;
    for (NSUInteger i=0; i<stringValue.length; i++) {
        unichar chr = [stringValue characterAtIndex:i];

        if (chr != '_') {
            NSString *character = [stringValue substringWithRange:NSMakeRange(i, 1)];

            if ((self.camelCaseStyle == HYDCamelCaseUpperStyle && i == 0 && [self isAlphaNumericCharacter:chr]) || wasPreviousCharacterUnderscored) {
                [result appendString:[character uppercaseString]];
            } else {
                [result appendString:[character lowercaseString]];
            }
        }
        wasPreviousCharacterUnderscored = (chr == '_');
    }

    return result;
}

#pragma mark - Private

- (BOOL)isAlphaNumericCharacter:(unichar)chr
{
    return [[NSCharacterSet alphanumericCharacterSet] characterIsMember:chr];
}

- (BOOL)isUppercasedString:(NSString *)string
{
    return [string isEqualToString:string.uppercaseString];
}

@end
