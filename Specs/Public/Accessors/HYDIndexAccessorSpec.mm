#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDIndexAccessorSpec)

describe(@"HYDIndexAccessor", ^{
    __block id<HYDAccessor> accessor;

    beforeEach(^{
        accessor = HYDAccessIndex(@0);
    });

    describe(@"fieldNames", ^{
        it(@"should return the keys it was given", ^{
            [accessor fieldNames] should equal(@[@"0"]);
            [HYDAccessIndex(@0, @1, @2) fieldNames] should equal(@[@"0", @"1", @"2"]);
        });
    });

    describe(@"equality", ^{
        context(@"when the fields all match", ^{
            it(@"should be equal", ^{
                accessor should equal(HYDAccessIndex(@0));
                HYDAccessIndex(@1, @2) should equal(HYDAccessIndex(@1, @2));
            });
        });

        context(@"when the fields don't match", ^{
            it(@"should not be equal", ^{
                accessor should_not equal(HYDAccessIndex(@1));
            });
        });
    });

    context(@"with multiple keys", ^{
        beforeEach(^{
            accessor = HYDAccessIndex(@0, @2);

            [CDRSpecHelper specHelper].sharedExampleContext[@"accessor"] = accessor;
            [CDRSpecHelper specHelper].sharedExampleContext[@"createTargetObject"] = ^{ return [NSMutableArray array]; };
            [CDRSpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = @[@"hi", [NSNull null], @"bob"];
            [CDRSpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = [NSNull null];
            [CDRSpecHelper specHelper].sharedExampleContext[@"expectedFieldNames"] = @[@"0", @"2"];
            [CDRSpecHelper specHelper].sharedExampleContext[@"expectedValues"] = @[@"hi", @"bob"];
            [CDRSpecHelper specHelper].sharedExampleContext[@"validSourceObjectWithNulls"] = @[[NSNull null], @"pi", @"pizza"];
            [CDRSpecHelper specHelper].sharedExampleContext[@"expectedValuesWithNulls"] = @[[NSNull null], @"pizza"];
        });

        itShouldBehaveLike(@"an accessor");
    });

    context(@"with one key", ^{
        beforeEach(^{
            [CDRSpecHelper specHelper].sharedExampleContext[@"accessor"] = accessor;
            [CDRSpecHelper specHelper].sharedExampleContext[@"createTargetObject"] = ^{ return [NSMutableArray array]; };
            [CDRSpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = @[@"Jesse"];
            [CDRSpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = @{};
            [CDRSpecHelper specHelper].sharedExampleContext[@"expectedFieldNames"] = @[@"0"];
            [CDRSpecHelper specHelper].sharedExampleContext[@"expectedValues"] = @[@"Jesse"];
            [CDRSpecHelper specHelper].sharedExampleContext[@"validSourceObjectWithNulls"] =  @[[NSNull null]];
            [CDRSpecHelper specHelper].sharedExampleContext[@"expectedValuesWithNulls"] = @[[NSNull null]];
        });

        itShouldBehaveLike(@"an accessor");
    });
});

SPEC_END
