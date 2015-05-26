#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSFakeMapper.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDSplitMapperSpec)

describe(@"HYDSplitMapper", ^{
    __block id<HYDMapper> mapper;
    __block HYDSFakeMapper *child1;
    __block HYDSFakeMapper *child2;

    beforeEach(^{
        child1 = [HYDSFakeMapper new];
        child2 = [HYDSFakeMapper new];
        mapper = HYDMapSplit(child1, child2);
    });

    describe(@"parsing an object", ^{
        __block id sourceObject;
        __block id parsedObject;
        __block HYDError *error;

        beforeEach(^{
            sourceObject = @1;
            child1.objectsToReturn = @[@"hi"];
            parsedObject = [mapper objectFromSourceObject:@1 error:&error];
        });

        it(@"should call the first child mapper", ^{
            child1.sourceObjectsReceived should equal(@[@1]);
            parsedObject should equal(@"hi");
        });

        it(@"should not call the second child mapper", ^{
            child2.sourceObjectsReceived should be_empty;
        });
    });

    describe(@"reverse mapping", ^{
        it(@"should return the second child mapper", ^{
            [mapper reverseMapper] should be_same_instance_as(child2);
        });
    });
});

SPEC_END
