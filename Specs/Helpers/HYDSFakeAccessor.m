#import "HYDSFakeAccessor.h"
#import "HYDError.h"
#import "HYDFunctions.h"

@implementation HYDSFakeAccessor

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p: [%@]>", NSStringFromClass(self.class), self, [self.fieldNames componentsJoinedByString:@", "]];
}

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - <HYDAccessor>

- (NSArray *)valuesFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    self.sourceValueReceived = sourceObject;
    HYDSetObjectPointer(error, self.sourceErrorToReturn);
    return self.valuesToReturn;
}

- (HYDError *)setValues:(NSArray *)values onObject:(id)destinationObject
{
    self.valuesToSetReceived = values;
    self.destinationObjectReceived = destinationObject;

    [destinationObject setValue:values[0] forKey:self.fieldNames[0]];

    return self.setValuesErrorToReturn;
}

@end
