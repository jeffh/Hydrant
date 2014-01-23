#import "HYDStringToURLMapper.h"
#import "HYDError.h"


@implementation HYDStringToURLMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationKey:(NSString *)destinationKey
{
    return [self initWithDestinationKey:destinationKey allowedSchemes:nil];
}

- (id)initWithDestinationKey:(NSString *)destinationKey allowedSchemes:(NSSet *)schemes
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.allowedSchemes = schemes;
    }
    return self;
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    *error = nil;
    NSURL *url = [NSURL URLWithString:[sourceObject description]];

    if (!url && sourceObject) {
        *error = [HYDError errorWithCode:HYDErrorInvalidSourceObjectValue
                            sourceObject:sourceObject
                               sourceKey:nil
                       destinationObject:nil
                          destinationKey:self.destinationKey
                                 isFatal:YES
                        underlyingErrors:nil];
    }

    if (url && self.allowedSchemes.count
        && ![self.allowedSchemes containsObject:url.scheme.lowercaseString]) {
        *error = [HYDError errorWithCode:HYDErrorInvalidSourceObjectValue
                            sourceObject:sourceObject
                               sourceKey:nil
                       destinationObject:nil
                          destinationKey:self.destinationKey
                                 isFatal:YES
                        underlyingErrors:nil];
        url = nil;
    }

    return url;
}

- (id<HYDMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return nil;
}

@end


HYD_EXTERN
HYDStringToURLMapper *HYDStringToURL(NSString *destinationKey)
{
    return [[HYDStringToURLMapper alloc] initWithDestinationKey:destinationKey];
}


HYD_EXTERN
HYDStringToURLMapper *HYDStringToURLOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
{
    NSSet *schemes = [NSSet setWithArray:[allowedSchemes valueForKey:@"lowercaseString"]];
    return [[HYDStringToURLMapper alloc] initWithDestinationKey:destinationKey
                                                 allowedSchemes:schemes];
}
