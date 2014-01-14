#import "JKSStringToNumberMapper.h"
#import "JKSError.h"
#import "JKSNumberToStringMapper.h"


@interface JKSStringToNumberMapper ()
@property(nonatomic, strong) NSNumberFormatter *numberFormatter;
@end

@implementation JKSStringToNumberMapper

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

- (id)objectFromSourceObject:(id)sourceObject error:(NSError * __autoreleasing *)error
{
    id value = [self.numberFormatter numberFromString:[sourceObject description]];

    if (!value && sourceObject) {
        *error = [JKSError mappingErrorWithCode:JKSErrorInvalidSourceObjectValue
                                   sourceObject:sourceObject
                                       byMapper:self];
    }
    return value;
}

- (id)objectFromSourceObject:(id)sourceObject toClass:(Class)dstClass error:(NSError * __autoreleasing *)error
{
    id value = [self objectFromSourceObject:sourceObject error:error];
    if (*error) {
        return nil;
    }

    if (value && ![[value class] isSubclassOfClass:dstClass]) {
        *error = [JKSError mappingErrorWithCode:JKSErrorInvalidResultingObjectType
                                   sourceObject:sourceObject
                                       byMapper:self];
        return nil;
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
JKSStringToNumberMapper *JKSStringToNumber(NSString *destKey, NSNumberFormatterStyle numberFormaterStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormaterStyle;
    return [[JKSStringToNumberMapper alloc] initWithDestinationKey:destKey numberFormatter:numberFormatter];
}