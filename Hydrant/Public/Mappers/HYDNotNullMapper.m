#import "HYDNotNullMapper.h"
#import "HYDIdentityMapper.h"
#import "HYDError.h"
#import "HYDFunctions.h"


@interface HYDNotNullMapper ()

@property (strong, nonatomic) id<HYDMapper> mapper;

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

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    HYDSetError(error, nil);
    HYDError *innerError = nil;
    id resultingObject = [self.mapper objectFromSourceObject:sourceObject error:&innerError];

    if (innerError) {
        HYDSetError(error, innerError);
        return resultingObject;
    }

    if (!resultingObject) {
        HYDSetError(error, [HYDError errorWithCode:HYDErrorInvalidResultingObjectType
                                      sourceObject:sourceObject
                                         sourceKey:nil
                                 destinationObject:nil
                                    destinationKey:self.destinationKey
                                           isFatal:YES
                                  underlyingErrors:nil]);
    }

    return resultingObject;
}

- (id<HYDMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[[self class] alloc] initWithMapper:[self.mapper reverseMapperWithDestinationKey:destinationKey]];
}

- (NSString *)destinationKey
{
    return self.mapper.destinationKey;
}

@end


HYD_EXTERN
HYD_OVERLOADED
HYDNotNullMapper *HYDMapNotNull(NSString *destinationKey)
{
    return HYDMapNotNull(HYDMapIdentity(destinationKey));
}


HYD_EXTERN
HYD_OVERLOADED
HYDNotNullMapper *HYDMapNotNull(id<HYDMapper> mapper)
{
    return [[HYDNotNullMapper alloc] initWithMapper:mapper];
}
