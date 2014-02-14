#import "HYDSFakeFormatter.h"

@implementation HYDSFakeFormatter

- (NSString *)stringForObjectValue:(id)obj
{
    self.didReceiveObject = YES;
    self.objectReceived = obj;
    return self.stringToReturn;
}

- (BOOL)getObjectValue:(out __autoreleasing id *)obj forString:(NSString *)string errorDescription:(out NSString *__autoreleasing *)error
{
    self.didReceiveString = YES;
    *error = self.errorDescriptionToReturn;
    *obj = self.objectToReturn;
    self.stringReceived = string;
    return self.returnSuccess;
}

@end
