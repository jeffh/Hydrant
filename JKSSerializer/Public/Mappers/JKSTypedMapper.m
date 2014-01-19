#import "JKSTypedMapper.h"
#import "JKSError.h"
#import "JKSObjectFactory.h"

@interface JKSTypedMapper ()
@property (strong, nonatomic) id<JKSMapper> wrappedMapper;
@property (copy, nonatomic) NSArray *allowedInputClasses;
@property (copy, nonatomic) NSArray *allowedOutputClasses;
@property (strong, nonatomic) id<JKSFactory> factory;
@property (weak, nonatomic) id<JKSMapper> rootMapper;
@end

@implementation JKSTypedMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithMapper:(id<JKSMapper>)mapper inputClasses:(NSArray *)inputClasses outputClasses:(NSArray *)outputClasses
{
    self = [super init];
    if (self) {
        self.wrappedMapper = mapper;
        self.allowedInputClasses = inputClasses;
        self.allowedOutputClasses = outputClasses;
        self.factory = [[JKSObjectFactory alloc] init];
        self.rootMapper = self;
    }
    return self;
}

#pragma mark - Private

- (BOOL)isObject:(id)object aSubclassOfAnyClasses:(NSArray *)classes
{
    if (!object) {
        return YES;
    }
    Class targetClass = [object class];
    for (Class aClass in classes) {
        if ([targetClass isSubclassOfClass:aClass]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - <JKSMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(NSError *__autoreleasing *)error
{
    if (![self isObject:sourceObject aSubclassOfAnyClasses:self.allowedInputClasses]) {
        *error = [JKSError mappingErrorWithCode:JKSErrorInvalidSourceObjectType sourceObject:sourceObject byMapper:self];
        return nil;
    }

    [self.wrappedMapper setupAsChildMapperWithMapper:self.rootMapper factory:self.factory];
    id object = [self.wrappedMapper objectFromSourceObject:sourceObject error:error];
    if (*error) {
        return nil;
    }

    if (![self isObject:object aSubclassOfAnyClasses:self.allowedOutputClasses]) {
        *error = [JKSError mappingErrorWithCode:JKSErrorInvalidResultingObjectType sourceObject:sourceObject byMapper:self];
        return nil;
    }

    return object;
}

- (void)setupAsChildMapperWithMapper:(id<JKSMapper>)mapper factory:(id<JKSFactory>)factory
{
    self.rootMapper = mapper;
    self.factory = factory;
}

- (NSString *)destinationKey
{
    return self.wrappedMapper.destinationKey;
}

- (id<JKSMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[JKSTypedMapper alloc] initWithMapper:[self.wrappedMapper reverseMapperWithDestinationKey:destinationKey]
                                     inputClasses:self.allowedOutputClasses
                                    outputClasses:self.allowedInputClasses];
}

@end


JKS_EXTERN
JKSTypedMapper *JKSEnforceType(id<JKSMapper> mapperToWrap, Class expectedInputClass, Class expectedOutputClass)
{
    return JKSEnforceTypes(mapperToWrap, @[expectedInputClass], @[expectedOutputClass]);
}

JKS_EXTERN
JKSTypedMapper *JKSEnforceTypes(id<JKSMapper> mapperToWrap, NSArray *expectedInputClasses, NSArray *expectedOutputClasses)
{
    return [[JKSTypedMapper alloc] initWithMapper:mapperToWrap
                                     inputClasses:expectedInputClasses
                                    outputClasses:expectedOutputClasses];
}
