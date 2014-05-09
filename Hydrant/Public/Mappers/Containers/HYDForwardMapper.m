#import "HYDForwardMapper.h"
#import "HYDFunctions.h"
#import "HYDDefaultAccessor.h"
#import "HYDError.h"
#import "HYDFactory.h"
#import "HYDObjectFactory.h"
#import "HYDBackwardMapper.h"



@interface HYDForwardMapper : NSObject <HYDMapper>

@property (strong, nonatomic) id<HYDMapper> childMapper;
@property (strong, nonatomic) id<HYDAccessor> walkAccessor;
@property (strong, nonatomic) Class sourceClass;
@property (strong, nonatomic) id<HYDFactory> factory;

- (id)initWithMapper:(id<HYDMapper>)mapper
        walkAccessor:(id<HYDAccessor>)walkAccessor
         sourceClass:(Class)sourceClass;

@end


@implementation HYDForwardMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithMapper:(id<HYDMapper>)mapper
        walkAccessor:(id<HYDAccessor>)walkAccessor
         sourceClass:(Class)sourceClass
{
    self = [super init];
    if (self) {
        self.childMapper = mapper;
        self.walkAccessor = walkAccessor;
        self.sourceClass = sourceClass;
        self.factory = [[HYDObjectFactory alloc] init];
    }
    return self;
}

#pragma mark - HYDMapper

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    HYDError *err = nil;
    id value = HYDGetValueOrValues([self.walkAccessor valuesFromSourceObject:sourceObject error:&err]);

    if ([err isFatal]) {
        HYDSetObjectPointer(error, err);
        return nil;
    }

    err = nil;
    id resultingObject = [self.childMapper objectFromSourceObject:value error:&err];

    if (err) {
        HYDSetObjectPointer(error, [HYDError errorFromError:err
                                   prependingSourceAccessor:self.walkAccessor
                                     andDestinationAccessor:nil
                                    replacementSourceObject:sourceObject
                                                    isFatal:[err isFatal]]);
    }

    if ([err isFatal]) {
        return nil;
    }

    return resultingObject;
}

- (id<HYDMapper>)reverseMapper
{
    id<HYDMapper> reversedMapper = [self.childMapper reverseMapper];
    return HYDMapBackward(self.walkAccessor, self.sourceClass, reversedMapper);
}

@end

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapForward(id<HYDAccessor> walkAccessor, Class sourceClass, id<HYDMapper> childMapper)
{
    return [[HYDForwardMapper alloc] initWithMapper:childMapper walkAccessor:walkAccessor sourceClass:sourceClass];
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapForward(NSString *destinationKey, Class sourceClass, id<HYDMapper> childMapper)
{
    return HYDMapForward(HYDAccessDefault(destinationKey), sourceClass, childMapper);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapForward(id<HYDAccessor> accessor, id<HYDMapper> childMapper)
{
    return HYDMapForward(accessor, [NSDictionary class], childMapper);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapForward(NSString *destinationKey, id<HYDMapper> childMapper)
{
    return HYDMapForward(HYDAccessDefault(destinationKey), childMapper);
}
