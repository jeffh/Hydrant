#import "JOMStringToNumberMapper.h"
#import "JOMError.h"
#import "JOMNumberToStringMapper.h"


@interface JOMStringToNumberMapper ()
@property(nonatomic, strong) NSNumberFormatter *numberFormatter;
@end

@implementation JOMStringToNumberMapper

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

#pragma mark - <JOMMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing JOMError **)error
{
    id value = [self.numberFormatter numberFromString:[sourceObject description]];

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
    return [[JOMNumberToStringMapper alloc] initWithDestinationKey:destinationKey numberFormatter:self.numberFormatter];
}

@end

JOM_EXTERN
JOMStringToNumberMapper *JOMStringToNumber(NSString *destKey)
{
    return JOMStringToNumberByFormat(destKey, NSNumberFormatterDecimalStyle);
}

JOM_EXTERN
JOMStringToNumberMapper *JOMStringToNumberByFormat(NSString *destKey, NSNumberFormatterStyle numberFormaterStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormaterStyle;
    return [[JOMStringToNumberMapper alloc] initWithDestinationKey:destKey numberFormatter:numberFormatter];
}

JOM_EXTERN
JOMStringToNumberMapper *JOMStringToNumberByFormatter(NSString *destKey, NSNumberFormatter *numberFormatter)
{
    return [[JOMStringToNumberMapper alloc] initWithDestinationKey:destKey numberFormatter:numberFormatter];
}