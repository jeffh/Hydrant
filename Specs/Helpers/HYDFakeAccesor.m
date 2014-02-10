#import "HYDFakeAccesor.h"
#import "HYDError.h"
#import "HYDFunctions.h"

@implementation HYDFakeAccesor

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - <HYDAccessor>

- (NSArray *)valuesFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    self.sourceValuesReceived = sourceObject;
    HYDSetObjectPointer(error, self.sourceErrorToReturn);
    return self.valuesToReturn;
}

- (HYDError *)setValues:(NSArray *)values ofClasses:(NSArray *)destinationClasses onObject:(id)destinationObject
{
    self.valuesToSetReceived = values;
    self.destinationClassesReceived = destinationClasses;
    self.destinationObjectReceived = destinationObject;

    [destinationObject setValue:values[0] forKey:self.fieldNames[0]];

    return self.setValuesErrorToReturn;
}

@end
