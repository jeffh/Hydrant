#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDBlockMapperSpec)

describe(@"HYDBlockMapper", ^{
    __block id<HYDMapper> mapper;
    __block id objectToReturn;
    __block HYDError *errorToReturn;

    beforeEach(^{
        objectToReturn = @"1";
        errorToReturn = nil;

        mapper = HYDMapWithBlock(^id(id incomingValue, __autoreleasing HYDError **error) {
            if (![@1 isEqual:incomingValue]) {
                if (error) {
                    *error = [HYDError errorWithCode:0
                                        sourceObject:nil
                                      sourceAccessor:nil
                                   destinationObject:nil
                                 destinationAccessor:nil
                                             isFatal:YES
                                    underlyingErrors:nil];
                }
                return nil;
            }
            return @"parsedObject";
        }, ^id(id incomingValue, __autoreleasing HYDError **error) {
            return @1;
        });

        [SpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
        [SpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = @1;
        [SpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = @"HI";
        [SpecHelper specHelper].sharedExampleContext[@"expectedParsedObject"] = @"parsedObject";
    });

    itShouldBehaveLike(@"a mapper that converts from one value to another");
});

SPEC_END
