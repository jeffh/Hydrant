#import "JKSStringToNumberMapper.h"
#import "JKSError.h"
#import "JKSNumberToStringMapper.h"


@interface JKSStringToNumberMapper ()
@property(nonatomic, strong) NSNumberFormatter *numberFormatter;
@end

@implementation JKSStringToNumberMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationKey:(NSString *)destinationKey numberFormatter:(NSNumberFormatter *)numberFormatter
{
    self = [super init];
    if (self){
        self.destinationKey = destinationKey;
        self.numberFormatter = numberFormatter;
    }
    return self;
}

#pragma mark - <JKSMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing JKSError **)error
{
    id value = [self.numberFormatter numberFromString:[sourceObject description]];

    if (!value && sourceObject) {
        *error = [JKSError errorWithCode:JKSErrorInvalidSourceObjectValue
                            sourceObject:sourceObject
                               sourceKey:nil
                       destinationObject:nil
                          destinationKey:self.destinationKey
                                 isFatal:YES
                        underlyingErrors:nil];
    }
    return value;
}

- (void)setupAsChildMapperWithMapper:(id<JKSMapper>)mapper factory:(id<JKSFactory>)factory
{
}

- (id<JKSMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[JKSNumberToStringMapper alloc] initWithDestinationKey:destinationKey numberFormatter:self.numberFormatter];
}

@end

JKS_EXTERN
JKSStringToNumberMapper *JKSStringToNumber(NSString *destKey)
{
    return JKSStringToNumberByFormat(destKey, NSNumberFormatterDecimalStyle);
}

JKS_EXTERN
JKSStringToNumberMapper *JKSStringToNumberByFormat(NSString *destKey, NSNumberFormatterStyle numberFormaterStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormaterStyle;
    return [[JKSStringToNumberMapper alloc] initWithDestinationKey:destKey numberFormatter:numberFormatter];
}

JKS_EXTERN
JKSStringToNumberMapper *JKSStringToNumberByFormatter(NSString *destKey, NSNumberFormatter *numberFormatter)
{
    return [[JKSStringToNumberMapper alloc] initWithDestinationKey:destKey numberFormatter:numberFormatter];
}