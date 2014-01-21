#import "JKSOptionalMapper.h"
#import "JKSError.h"
#import "JKSObjectFactory.h"

@interface JKSOptionalMapper ()
@property (strong, nonatomic) id<JKSMapper> wrappedMapper;
@property (strong, nonatomic) id defaultValue;
@property (strong, nonatomic) id reverseDefaultValue;
@property (strong, nonatomic) id<JKSFactory> factory;
@property (weak, nonatomic) id<JKSMapper> rootMapper;
@end

@implementation JKSOptionalMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithMapper:(id<JKSMapper>)mapper defaultValue:(id)defaultValue reverseDefaultValue:(id)reverseDefaultValue
{
    self = [super init];
    if (self) {
        self.wrappedMapper = mapper;
        self.defaultValue = defaultValue;
        self.reverseDefaultValue = reverseDefaultValue;
        self.rootMapper = self;
        self.factory = [[JKSObjectFactory alloc] init];
    }
    return self;
}

#pragma mark - <JKSMapper>

- (NSString *)destinationKey
{
    return [self.wrappedMapper destinationKey];
}

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing JKSError **)error
{
    [self.wrappedMapper setupAsChildMapperWithMapper:self.rootMapper factory:self.factory];

    id resultingObject = [self.wrappedMapper objectFromSourceObject:sourceObject error:error];

    if (*error){
        *error = [JKSError errorFromError:*error
                      prependingSourceKey:nil
                        andDestinationKey:nil
                  replacementSourceObject:nil
                                  isFatal:NO];
        return self.defaultValue;
    }

    return resultingObject;
}

- (void)setupAsChildMapperWithMapper:(id<JKSMapper>)mapper factory:(id<JKSFactory>)factory
{
    self.rootMapper = mapper;
    self.factory = factory;
}

- (id<JKSMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    id<JKSMapper> reverseWrappedMapper = [self.wrappedMapper reverseMapperWithDestinationKey:destinationKey];
    return [[[self class] alloc] initWithMapper:reverseWrappedMapper
                                   defaultValue:self.reverseDefaultValue
                            reverseDefaultValue:self.defaultValue];
}


@end

JKS_EXTERN
JKSOptionalMapper *JKSOptional(id<JKSMapper> mapper)
{
    return JKSOptionalWithDefault(mapper, nil);
}

JKS_EXTERN
JKSOptionalMapper *JKSOptionalWithDefault(id<JKSMapper> mapper, id defaultValue)
{
    return JKSOptionalWithDefaultAndReversedDefault(mapper, defaultValue, defaultValue);
}
JKS_EXTERN
JKSOptionalMapper *JKSOptionalWithDefaultAndReversedDefault(id<JKSMapper> mapper, id defaultValue, id reversedDefault)
{
    return [[JKSOptionalMapper alloc] initWithMapper:mapper
                                        defaultValue:defaultValue
                                 reverseDefaultValue:reversedDefault];
}