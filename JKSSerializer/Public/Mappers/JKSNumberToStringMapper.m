#import "JKSNumberToStringMapper.h"
#import "JKSError.h"
#import "JKSStringToNumberMapper.h"

@interface JKSNumberToStringMapper ()
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@end

@implementation JKSNumberToStringMapper

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

#pragma mark - <JKSMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing JKSError **)error
{
    id value = [self.numberFormatter stringFromNumber:sourceObject];

    if (!value && sourceObject) {
        *error = [JKSError errorWithCode:JKSErrorInvalidSourceObjectValue
                            sourceObject:sourceObject
                                byMapper:self];
    }
    return value;
}

- (void)setupAsChildMapperWithMapper:(id<JKSMapper>)mapper factory:(id<JKSFactory>)factory
{
}

- (id<JKSMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[JKSStringToNumberMapper alloc] initWithDestinationKey:destinationKey numberFormatter:self.numberFormatter];
}

@end


JKS_EXTERN
JKSNumberToStringMapper *JKSNumberToString(NSString *destKey)
{
    return JKSNumberToStringByFormat(destKey, NSNumberFormatterDecimalStyle);
}

JKS_EXTERN
JKSNumberToStringMapper *JKSNumberToStringByFormat(NSString *destKey, NSNumberFormatterStyle numberFormatStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormatStyle;
    return [[JKSNumberToStringMapper alloc] initWithDestinationKey:destKey numberFormatter:numberFormatter];
}

JKS_EXTERN
JKSNumberToStringMapper *JKSNumberToStringByFormatter(NSString *destKey, NSNumberFormatter *numberFormatter)
{
    return [[JKSNumberToStringMapper alloc] initWithDestinationKey:destKey numberFormatter:numberFormatter];
}