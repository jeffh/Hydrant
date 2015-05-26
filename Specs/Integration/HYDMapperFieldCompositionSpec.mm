#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDMapperFieldCompositionSpec)

describe(@"Mapping fields that access multiple properties", ^{
    __block id<HYDMapper> mapper;
    __block HYDError *error;
    __block id sourceObject;

    beforeEach(^{
        id<HYDMapper> joinedNameMapper = HYDMapWithBlock(^id(id incomingValue, __autoreleasing HYDError **err) {
            return [incomingValue componentsJoinedByString:@" "];
        }, ^id(id incomingValue, __autoreleasing HYDError **err){
            return [incomingValue componentsSeparatedByString:@" "];
        });
        mapper = HYDMapObject([NSDictionary class], [NSDictionary class],
                              @{HYDAccessKey(@"first", @"last") : @[joinedNameMapper, @"name"]});
        sourceObject = @{@"first": @"John",
                         @"last": @"Doe"};
    });

    describe(@"mapping", ^{
        it(@"should work", ^{
            id resultingObject = [mapper objectFromSourceObject:sourceObject error:&error];
            resultingObject should equal(@{@"name": @"John Doe"});
        });
    });

    describe(@"reverse mapping", ^{
        it(@"should work", ^{
            id resultingObject = [mapper objectFromSourceObject:sourceObject error:&error];
            error should be_nil;
            id finalObject = [[mapper reverseMapper] objectFromSourceObject:resultingObject error:&error];
            error should be_nil;
            finalObject should equal(sourceObject);
        });
    });
});

SPEC_END
