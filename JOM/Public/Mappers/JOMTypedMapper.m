#import "JOMTypedMapper.h"
#import "JOMError.h"
#import "JOMObjectFactory.h"

@interface JOMTypedMapper ()
@property (strong, nonatomic) id<JOMMapper> wrappedMapper;
@property (copy, nonatomic) NSArray *allowedInputClasses;
@property (copy, nonatomic) NSArray *allowedOutputClasses;
@property (strong, nonatomic) id<JOMFactory> factory;
@property (weak, nonatomic) id<JOMMapper> rootMapper;
@end

@implementation JOMTypedMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithMapper:(id<JOMMapper>)mapper inputClasses:(NSArray *)inputClasses outputClasses:(NSArray *)outputClasses
{
    self = [super init];
    if (self) {
        self.wrappedMapper = mapper;
        self.allowedInputClasses = inputClasses;
        self.allowedOutputClasses = outputClasses;
        self.factory = [[JOMObjectFactory alloc] init];
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

#pragma mark - <JOMMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing JOMError **)error
{
    if (![self isObject:sourceObject aSubclassOfAnyClasses:self.allowedInputClasses]) {
        *error = [JOMError errorWithCode:JOMErrorInvalidSourceObjectType
                            sourceObject:sourceObject
                               sourceKey:nil
                       destinationObject:nil
                          destinationKey:self.destinationKey
                                 isFatal:YES
                        underlyingErrors:nil];
        return nil;
    }

    [self.wrappedMapper setupAsChildMapperWithMapper:self.rootMapper factory:self.factory];
    id object = [self.wrappedMapper objectFromSourceObject:sourceObject error:error];
    if (*error) {
        return nil;
    }

    if (![self isObject:object aSubclassOfAnyClasses:self.allowedOutputClasses]) {
        *error = [JOMError errorWithCode:JOMErrorInvalidResultingObjectType
                            sourceObject:sourceObject
                               sourceKey:nil
                       destinationObject:nil
                          destinationKey:self.destinationKey
                                 isFatal:YES
                        underlyingErrors:nil];
        return nil;
    }

    return object;
}

- (void)setupAsChildMapperWithMapper:(id<JOMMapper>)mapper factory:(id<JOMFactory>)factory
{
    self.rootMapper = mapper;
    self.factory = factory;
}

- (NSString *)destinationKey
{
    return self.wrappedMapper.destinationKey;
}

- (id<JOMMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[JOMTypedMapper alloc] initWithMapper:[self.wrappedMapper reverseMapperWithDestinationKey:destinationKey]
                                     inputClasses:self.allowedOutputClasses
                                    outputClasses:self.allowedInputClasses];
}

@end


JOM_EXTERN
JOMTypedMapper *JOMEnforceType(id<JOMMapper> mapperToWrap, Class expectedInputClass, Class expectedOutputClass)
{
    return JOMEnforceTypes(mapperToWrap, @[expectedInputClass], @[expectedOutputClass]);
}

JOM_EXTERN
JOMTypedMapper *JOMEnforceTypes(id<JOMMapper> mapperToWrap, NSArray *expectedInputClasses, NSArray *expectedOutputClasses)
{
    return [[JOMTypedMapper alloc] initWithMapper:mapperToWrap
                                     inputClasses:expectedInputClasses
                                    outputClasses:expectedOutputClasses];
}
