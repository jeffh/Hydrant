#import "HYDObjectToStringFormatterMapper.h"
#import "HYDError.h"
#import "HYDStringToObjectFormatterMapper.h"


@implementation HYDObjectToStringFormatterMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationKey:(NSString *)destinationKey formatter:(NSFormatter *)formatter
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.formatter = formatter;
    }
    return self;
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    id resultingObject = nil;
    if (sourceObject) {
        resultingObject = [self.formatter stringForObjectValue:sourceObject];
    }

    if (resultingObject) {
        *error = nil;
    } else {
        *error = [HYDError errorWithCode:HYDErrorInvalidSourceObjectValue
                            sourceObject:sourceObject
                               sourceKey:nil
                       destinationObject:nil
                          destinationKey:self.destinationKey
                                 isFatal:YES
                        underlyingErrors:nil];
    }
    return resultingObject;
}

- (id<HYDMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[HYDStringToObjectFormatterMapper alloc] initWithDestinationKey:destinationKey formatter:self.formatter];
}

@end


HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDObjectToStringWithFormatter(NSString *destinationKey, NSFormatter *formatter)
{
    return [[HYDObjectToStringFormatterMapper alloc] initWithDestinationKey:destinationKey formatter:formatter];
}