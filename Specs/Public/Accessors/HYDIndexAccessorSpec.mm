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

            [SpecHelper specHelper].sharedExampleContext[@"accessor"] = accessor;
            [SpecHelper specHelper].sharedExampleContext[@"createTargetObject"] = ^{ return [NSMutableArray array]; };
            [SpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = @[@"hi", [NSNull null], @"bob"];
            [SpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = [NSNull null];
            [SpecHelper specHelper].sharedExampleContext[@"expectedFieldNames"] = @[@"0", @"2"];
            [SpecHelper specHelper].sharedExampleContext[@"expectedValues"] = @[@"hi", @"bob"];
            [SpecHelper specHelper].sharedExampleContext[@"validSourceObjectWithNulls"] = @[[NSNull null], @"pi", @"pizza"];
            [SpecHelper specHelper].sharedExampleContext[@"expectedValuesWithNulls"] = @[[NSNull null], @"pizza"];
        });

        itShouldBehaveLike(@"an accessor");
    });

    context(@"with one key", ^{
        beforeEach(^{
            [SpecHelper specHelper].sharedExampleContext[@"accessor"] = accessor;
            [SpecHelper specHelper].sharedExampleContext[@"createTargetObject"] = ^{ return [NSMutableArray array]; };
            [SpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = @[@"Jesse"];
            [SpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = @{};
            [SpecHelper specHelper].sharedExampleContext[@"expectedFieldNames"] = @[@"0"];
            [SpecHelper specHelper].sharedExampleContext[@"expectedValues"] = @[@"Jesse"];
            [SpecHelper specHelper].sharedExampleContext[@"validSourceObjectWithNulls"] =  @[[NSNull null]];
            [SpecHelper specHelper].sharedExampleContext[@"expectedValuesWithNulls"] = @[[NSNull null]];
        });

        itShouldBehaveLike(@"an accessor");
    });
});

SPEC_END
