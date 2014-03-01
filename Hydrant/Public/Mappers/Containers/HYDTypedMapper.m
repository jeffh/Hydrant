#import "HYDTypedMapper.h"
#import "HYDError.h"
#import "HYDIdentityMapper.h"
#import "HYDFunctions.h"
#import "HYDAnyClassSentinel.h"


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
        self.allowedInputClasses = (inputClasses.count ? inputClasses : @[[HYDAnyClassSentinel class]]);
        self.allowedOutputClasses = (outputClasses.count ? outputClasses : @[[HYDAnyClassSentinel class]]);
    }
    return self;
}

#pragma mark - <NSObject>

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@>",
            NSStringFromClass(self.class),
            self.wrappedMapper];
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    if (![self isObject:sourceObject aSubclassOfAnyClasses:self.allowedInputClasses]) {
        *error = [HYDError errorWithCode:HYDErrorInvalidSourceObjectType
                            sourceObject:sourceObject
                          sourceAccessor:nil
                       destinationObject:nil
                     destinationAccessor:self.destinationAccessor
                                 isFatal:YES
                        underlyingErrors:nil];
        return nil;
    }

    HYDError *innerError = nil;
    id object = [self.wrappedMapper objectFromSourceObject:sourceObject error:&innerError];
    
    HYDSetObjectPointer(error, innerError);
    if ([innerError isFatal]) {
        return nil;
    }

    if (![self isObject:object aSubclassOfAnyClasses:self.allowedOutputClasses]) {
        HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorInvalidResultingObjectType
                                              sourceObject:sourceObject
                                            sourceAccessor:nil
                                         destinationObject:nil
                                       destinationAccessor:self.destinationAccessor
                                                   isFatal:YES
                                          underlyingErrors:nil]);
        return nil;
    }

    return object;
}

- (id<HYDAccessor>)destinationAccessor
{
    return self.wrappedMapper.destinationAccessor;
}

- (id<HYDMapper>)reverseMapperWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor
{
    return [[HYDTypedMapper alloc] initWithMapper:[self.wrappedMapper reverseMapperWithDestinationAccessor:destinationAccessor]
                                     inputClasses:self.allowedOutputClasses
                                    outputClasses:self.allowedInputClasses];
}

#pragma mark - Private

- (BOOL)isObject:(id)object aSubclassOfAnyClasses:(NSArray *)classes
{
    if (!object) {
        return YES;
    }
    Class targetClass = [object class];
    for (Class aClass in classes) {
        if (aClass == [HYDAnyClassSentinel class] || [targetClass isSubclassOfClass:aClass]) {
            return YES;
        }
    }
    return NO;
}

@end

HYD_EXTERN_OVERLOADED
HYDTypedMapper *HYDMapType(NSString *destinationKey, Class expectedInputAndOutputClass)
{
    return HYDMapType(destinationKey, expectedInputAndOutputClass, expectedInputAndOutputClass);
}

HYD_EXTERN_OVERLOADED
HYDTypedMapper *HYDMapType(NSString *destinationKey, Class expectedInputClass, Class expectedOutputClass)
{
    return HYDMapTypes(destinationKey, [NSArray arrayWithObjects:expectedInputClass, nil], [NSArray arrayWithObjects:expectedOutputClass, nil]);
}

HYD_EXTERN_OVERLOADED
HYDTypedMapper *HYDMapTypes(NSString *destinationKey, NSArray *expectedInputClasses, NSArray *expectedOutputClasses)
{
    return HYDMapTypes(HYDMapIdentity(destinationKey), expectedInputClasses, expectedOutputClasses);
}

HYD_EXTERN_OVERLOADED
HYDTypedMapper *HYDMapType(id<HYDMapper> mapperToWrap, Class expectedInputAndOutputClass)
{
    return HYDMapType(mapperToWrap, expectedInputAndOutputClass, expectedInputAndOutputClass);
}

HYD_EXTERN_OVERLOADED
HYDTypedMapper *HYDMapType(id<HYDMapper> mapperToWrap, Class expectedInputClass, Class expectedOutputClass)
{
    return HYDMapTypes(mapperToWrap, [NSArray arrayWithObjects:expectedInputClass, nil], [NSArray arrayWithObjects:expectedOutputClass, nil]);
}

HYD_EXTERN_OVERLOADED
HYDTypedMapper *HYDMapTypes(id<HYDMapper> mapperToWrap, NSArray *expectedInputClasses, NSArray *expectedOutputClasses)
{
    return [[HYDTypedMapper alloc] initWithMapper:mapperToWrap
                                     inputClasses:expectedInputClasses
                                    outputClasses:expectedOutputClasses];
}
