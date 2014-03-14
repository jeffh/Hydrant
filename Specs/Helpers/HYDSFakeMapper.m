#import "HYDSFakeMapper.h"
#import "HYDError.h"
#import "HYDFunctions.h"
#import "HYDDefaultAccessor.h"
#import "HYDKeyAccessor.h"

@implementation HYDSFakeMapper {
    NSMutableArray *_objectsToReturn;
    NSMutableArray *_errorsToReturn;
    NSMutableArray *_sourceObjectsReceived;
}

- (id)init
{
    self = [super init];
    if (self) {
        _objectsToReturn = [NSMutableArray array];
        _errorsToReturn = [NSMutableArray array];
        _sourceObjectsReceived = [NSMutableArray array];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p>", NSStringFromClass(self.class), self];
}

#pragma mark - Properties

- (void)setObjectsToReturn:(NSArray *)objectsToReturn
{
    _objectsToReturn = [objectsToReturn mutableCopy];
}

- (void)setErrorsToReturn:(NSArray *)errorsToReturn
{
    BOOL isValid = YES;
    for (id obj in errorsToReturn) {
        isValid = isValid && ([obj isKindOfClass:[NSError class]] || [obj isEqual:[NSNull null]]);
    }
    NSParameterAssert(isValid);
    _errorsToReturn = [errorsToReturn mutableCopy];
}

- (void)setSourceObjectsReceived:(NSArray *)sourceObjectsReceived
{
    _sourceObjectsReceived = [sourceObjectsReceived mutableCopy];
}


#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    [_sourceObjectsReceived addObject:sourceObject ?: [NSNull null]];

    HYDSetObjectPointer(error, nil);

    if (self.errorsToReturn.count && ![self.errorsToReturn[0] isEqual:[NSNull null]]) {
        HYDSetObjectPointer(error, self.errorsToReturn[0]);
    }
    if (self.errorsToReturn.count > 1) {
        [_errorsToReturn removeObjectAtIndex:0];
    }

    id object = nil;

    if (self.objectsToReturn.count && ![self.objectsToReturn[0] isEqual:[NSNull null]]) {
        object = self.objectsToReturn[0];
    }
    if (self.objectsToReturn.count > 1) {
        [_objectsToReturn removeObjectAtIndex:0];
    }
    return object;
}

- (id<HYDMapper>)reverseMapper
{
    return self.reverseMapperToReturn;
}

@end
