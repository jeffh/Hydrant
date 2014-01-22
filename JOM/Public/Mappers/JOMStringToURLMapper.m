#import "JOMStringToURLMapper.h"
#import "JOMError.h"

@implementation JOMStringToURLMapper

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

#pragma mark - <JOMMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing JOMError **)error
{
    *error = nil;
    NSURL *url = [NSURL URLWithString:[sourceObject description]];

    if (!url && sourceObject) {
        *error = [JOMError errorWithCode:JOMErrorInvalidSourceObjectValue
                            sourceObject:sourceObject
                               sourceKey:nil
                       destinationObject:nil
                          destinationKey:self.destinationKey
                                 isFatal:YES
                        underlyingErrors:nil];
    }

    if (url && self.allowedSchemes.count
        && ![self.allowedSchemes containsObject:url.scheme.lowercaseString]) {
        *error = [JOMError errorWithCode:JOMErrorInvalidSourceObjectValue
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

- (void)setupAsChildMapperWithMapper:(id<JOMMapper>)mapper factory:(id<JOMFactory>)factory
{
}

- (id<JOMMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return nil;
}

@end

JOM_EXTERN
JOMStringToURLMapper *JOMStringToURL(NSString *destinationKey)
{
    return [[JOMStringToURLMapper alloc] initWithDestinationKey:destinationKey];
}


JOM_EXTERN
JOMStringToURLMapper *JOMStringToURLOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
{
    NSSet *schemes = [NSSet setWithArray:[allowedSchemes valueForKey:@"lowercaseString"]];
    return [[JOMStringToURLMapper alloc] initWithDestinationKey:destinationKey
                                                 allowedSchemes:schemes];
}
