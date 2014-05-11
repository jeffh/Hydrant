// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSPerson.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDKeyAccessorSpec)

describe(@"HYDKeyAccessor", ^{
    __block id<HYDAccessor> accessor;

    beforeEach(^{
        accessor = HYDAccessKey(@"firstName");
    });

    describe(@"fieldNames", ^{
        it(@"should return the keys it was given", ^{
            [accessor fieldNames] should equal(@[@"firstName"]);
        });

        context(@"when a period is in the key", ^{
            it(@"should return the keys with a dot in double quotes", ^{
                NSArray *expectedValue = @[@"yo", @"\"that.dog\"", @"w\\hoa", @"\"\\\"\\\\n.o\\\"\""];
                [HYDAccessKey(@"yo", @"that.dog", @"w\\hoa", @"\"\\n.o\"") fieldNames] should equal(expectedValue);
            });
        });
    });

    describe(@"equality", ^{
        context(@"when the fields all match", ^{
            it(@"should be equal", ^{
                accessor should equal(HYDAccessKey(@"firstName"));
                HYDAccessKey(@"foo", @"bar") should equal(HYDAccessKey(@"foo", @"bar"));
            });
        });

        context(@"when the fields don't match", ^{
            it(@"should not be equal", ^{
                accessor should_not equal(HYDAccessKey(@"cakes"));
            });
        });
    });

    context(@"with multiple keys", ^{
        beforeEach(^{
            accessor = HYDAccessKey(@"firstName", @"lastName");

            [SpecHelper specHelper].sharedExampleContext[@"accessor"] = accessor;
            [SpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = ({
                HYDSPerson *person = [[HYDSPerson alloc] init];
                person.firstName = @"John";
                person.lastName = @"Doe";
                person;
            });
            [SpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = @{@"firstName": @"lastName"};
            [SpecHelper specHelper].sharedExampleContext[@"createTargetObject"] = ^{ return [HYDSPerson new]; };
            [SpecHelper specHelper].sharedExampleContext[@"expectedFieldNames"] = @[@"firstName", @"lastName"];
            [SpecHelper specHelper].sharedExampleContext[@"expectedValues"] = @[@"John", @"Doe"];
            [SpecHelper specHelper].sharedExampleContext[@"validSourceObjectWithNulls"] = @{@"firstName": [NSNull null], @"lastName": @"Doe"};
            [SpecHelper specHelper].sharedExampleContext[@"expectedValuesWithNulls"] = @[[NSNull null], @"Doe"];
        });

        itShouldBehaveLike(@"an accessor");
    });

    context(@"with one key", ^{
        beforeEach(^{
            [SpecHelper specHelper].sharedExampleContext[@"accessor"] = accessor;
            [SpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = ({
                HYDSPerson *person = [[HYDSPerson alloc] init];
                person.firstName = @"John";
                person;
            });
            [SpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = @{};
            [SpecHelper specHelper].sharedExampleContext[@"createTargetObject"] = ^{ return [HYDSPerson new]; };
            [SpecHelper specHelper].sharedExampleContext[@"expectedFieldNames"] = @[@"firstName"];
            [SpecHelper specHelper].sharedExampleContext[@"expectedValues"] = @[@"John"];
            [SpecHelper specHelper].sharedExampleContext[@"validSourceObjectWithNulls"] = @{@"firstName": [NSNull null]};
            [SpecHelper specHelper].sharedExampleContext[@"expectedValuesWithNulls"] = @[[NSNull null]];
        });

        itShouldBehaveLike(@"an accessor");
    });
});

SPEC_END
