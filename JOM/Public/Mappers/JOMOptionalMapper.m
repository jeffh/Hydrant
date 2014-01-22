#import "JOMOptionalMapper.h"
#import "JOMError.h"
#import "JOMObjectFactory.h"
#import "JOMIdentityMapper.h"

@interface JOMOptionalMapper ()
@property (strong, nonatomic) id<JOMMapper> wrappedMapper;
@property (strong, nonatomic) JOMValueBlock defaultValueBlock;
@property (strong, nonatomic) JOMValueBlock reverseDefaultValueBlock;
@property (strong, nonatomic) id<JOMFactory> factory;
@property (weak, nonatomic) id<JOMMapper> rootMapper;
@end

@implementation JOMOptionalMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithMapper:(id<JOMMapper>)mapper defaultValue:(JOMValueBlock)defaultValue reverseDefaultValue:(JOMValueBlock)reverseDefaultValue
{
    self = [super init];
    if (self) {
        self.wrappedMapper = mapper;
        self.defaultValueBlock = defaultValue;
        self.reverseDefaultValueBlock = reverseDefaultValue;
        self.rootMapper = self;
        self.factory = [[JOMObjectFactory alloc] init];
    }
    return self;
}

#pragma mark - <JOMMapper>

- (NSString *)destinationKey
{
    return [self.wrappedMapper destinationKey];
}

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing JOMError **)error
{
    [self.wrappedMapper setupAsChildMapperWithMapper:self.rootMapper factory:self.factory];

    id resultingObject = [self.wrappedMapper objectFromSourceObject:sourceObject error:error];

    if (*error){
        *error = [JOMError errorFromError:*error
                      prependingSourceKey:nil
                        andDestinationKey:nil
                  replacementSourceObject:nil
                                  isFatal:NO];
        return self.defaultValueBlock();
    }

    return resultingObject;
}

- (void)setupAsChildMapperWithMapper:(id<JOMMapper>)mapper factory:(id<JOMFactory>)factory
{
    self.rootMapper = mapper;
    self.factory = factory;
}

- (id<JOMMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    id<JOMMapper> reverseWrappedMapper = [self.wrappedMapper reverseMapperWithDestinationKey:destinationKey];
    return [[[self class] alloc] initWithMapper:reverseWrappedMapper
                                   defaultValue:self.reverseDefaultValueBlock
                            reverseDefaultValue:self.defaultValueBlock];
}


@end

JOM_EXTERN
JOMOptionalMapper *JOMOptional(id<JOMMapper> mapper)
{
    return JOMOptionalWithDefault(mapper, nil);
}

JOM_EXTERN
JOMOptionalMapper *JOMOptionalField(NSString *destinationKey)
{
    return JOMOptional(JOMIdentity(destinationKey));
}

JOM_EXTERN
JOMOptionalMapper *JOMOptionalWithDefault(id<JOMMapper> mapper, id defaultValue)
{
    return JOMOptionalWithDefaultAndReversedDefault(mapper, defaultValue, defaultValue);
}

JOM_EXTERN
JOMOptionalMapper *JOMOptionalFieldWithDefault(NSString *destinationKey, id defaultValue)
{
    return JOMOptionalWithDefault(JOMIdentity(destinationKey), defaultValue);
}

JOM_EXTERN
JOMOptionalMapper *JOMOptionalWithDefaultAndReversedDefault(id<JOMMapper> mapper, id defaultValue, id reversedDefault)
{
    return [[JOMOptionalMapper alloc] initWithMapper:mapper
                                        defaultValue:^{ return defaultValue; }
                                 reverseDefaultValue:^{ return reversedDefault; }];
}