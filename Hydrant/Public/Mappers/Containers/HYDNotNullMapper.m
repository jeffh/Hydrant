#import "HYDNotNullMapper.h"
#import "HYDIdentityMapper.h"
#import "HYDError.h"
#import "HYDFunctions.h"


@interface HYDNotNullMapper : NSObject <HYDMapper>

@property (strong, nonatomic) id<HYDMapper> mapper;

- (id)initWithMapper:(id<HYDMapper>)mapper;

@end


@implementation HYDNotNullMapper

- (id)initWithMapper:(id<HYDMapper>)mapper
{
    self = [super init];
    if (self) {
        self.mapper = mapper;
    }
    return self;
}

#pragma mark - <NSObject>

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@>",
            NSStringFromClass(self.class),
            self.mapper];
}

#pragma mark - HYDMapper

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    HYDSetObjectPointer(error, nil);
    HYDError *innerError = nil;
    id resultingObject = [self.mapper objectFromSourceObject:sourceObject error:&innerError];

    if (innerError) {
        HYDSetObjectPointer(error, innerError);
        return resultingObject;
    }

    if (!resultingObject) {
        HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorInvalidResultingObjectType
                                              sourceObject:sourceObject
                                            sourceAccessor:nil
                                         destinationObject:nil
                                       destinationAccessor:nil
                                                   isFatal:YES
                                          underlyingErrors:nil]);
    }

    return resultingObject;
}

- (id<HYDMapper>)reverseMapper
{
    return [[[self class] alloc] initWithMapper:[self.mapper reverseMapper]];
}

@end

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNotNull(void)
{
    return HYDMapNotNull(HYDMapIdentity());
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNotNullFrom(id<HYDMapper> innerMapper)
{
    return HYDMapNotNull(innerMapper);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNotNull(id<HYDMapper> innerMapper)
{
    return [[HYDNotNullMapper alloc] initWithMapper:innerMapper];
}
