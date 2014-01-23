#import "HYDTypedMapper.h"
#import "HYDError.h"
#import "HYDObjectFactory.h"


@interface HYDTypedMapper ()

@property (strong, nonatomic) id<HYDMapper> wrappedMapper;
@property (copy, nonatomic) NSArray *allowedInputClasses;
@property (copy, nonatomic) NSArray *allowedOutputClasses;

@end


@implementation HYDTypedMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithMapper:(id<HYDMapper>)mapper inputClasses:(NSArray *)inputClasses outputClasses:(NSArray *)outputClasses
{
    self = [super init];
    if (self) {
        self.wrappedMapper = mapper;
        self.allowedInputClasses = inputClasses;
        self.allowedOutputClasses = outputClasses;
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

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    if (![self isObject:sourceObject aSubclassOfAnyClasses:self.allowedInputClasses]) {
        *error = [HYDError errorWithCode:HYDErrorInvalidSourceObjectType
                            sourceObject:sourceObject
                               sourceKey:nil
                       destinationObject:nil
                          destinationKey:self.destinationKey
                                 isFatal:YES
                        underlyingErrors:nil];
        return nil;
    }

    id object = [self.wrappedMapper objectFromSourceObject:sourceObject error:error];
    if (*error) {
        return nil;
    }

    if (![self isObject:object aSubclassOfAnyClasses:self.allowedOutputClasses]) {
        *error = [HYDError errorWithCode:HYDErrorInvalidResultingObjectType
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

- (NSString *)destinationKey
{
    return self.wrappedMapper.destinationKey;
}

- (id<HYDMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[HYDTypedMapper alloc] initWithMapper:[self.wrappedMapper reverseMapperWithDestinationKey:destinationKey]
                                     inputClasses:self.allowedOutputClasses
                                    outputClasses:self.allowedInputClasses];
}

@end


HYD_EXTERN
HYDTypedMapper *HYDEnforceType(id<HYDMapper> mapperToWrap, Class expectedInputClass, Class expectedOutputClass)
{
    return HYDEnforceTypes(mapperToWrap, @[expectedInputClass], @[expectedOutputClass]);
}

HYD_EXTERN
HYDTypedMapper *HYDEnforceTypes(id<HYDMapper> mapperToWrap, NSArray *expectedInputClasses, NSArray *expectedOutputClasses)
{
    return [[HYDTypedMapper alloc] initWithMapper:mapperToWrap
                                     inputClasses:expectedInputClasses
                                    outputClasses:expectedOutputClasses];
}
