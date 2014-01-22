#import "JOMNumberToStringMapper.h"
#import "JOMError.h"
#import "JOMStringToNumberMapper.h"

@interface JOMNumberToStringMapper ()
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@end

@implementation JOMNumberToStringMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationKey:(NSString *)destinationKey numberFormatter:(NSNumberFormatter *)numberFormatter
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.numberFormatter = numberFormatter;
    }
    return self;
}

#pragma mark - <JOMMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing JOMError **)error
{
    id value = [self.numberFormatter stringFromNumber:sourceObject];

    if (!value && sourceObject) {
        *error = [JOMError errorWithCode:JOMErrorInvalidSourceObjectValue
                            sourceObject:sourceObject
                               sourceKey:nil
                       destinationObject:nil
                          destinationKey:self.destinationKey
                                 isFatal:YES
                        underlyingErrors:nil];
    }
    return value;
}

- (void)setupAsChildMapperWithMapper:(id<JOMMapper>)mapper factory:(id<JOMFactory>)factory
{
}

- (id<JOMMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[JOMStringToNumberMapper alloc] initWithDestinationKey:destinationKey numberFormatter:self.numberFormatter];
}

@end


JOM_EXTERN
JOMNumberToStringMapper *JOMNumberToString(NSString *destKey)
{
    return JOMNumberToStringByFormat(destKey, NSNumberFormatterDecimalStyle);
}

JOM_EXTERN
JOMNumberToStringMapper *JOMNumberToStringByFormat(NSString *destKey, NSNumberFormatterStyle numberFormatStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormatStyle;
    return [[JOMNumberToStringMapper alloc] initWithDestinationKey:destKey numberFormatter:numberFormatter];
}

JOM_EXTERN
JOMNumberToStringMapper *JOMNumberToStringByFormatter(NSString *destKey, NSNumberFormatter *numberFormatter)
{
    return [[JOMNumberToStringMapper alloc] initWithDestinationKey:destKey numberFormatter:numberFormatter];
}