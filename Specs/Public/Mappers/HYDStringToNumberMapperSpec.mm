// DO NOT any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDStringToNumberMapperSpec)

describe(@"HYDStringToNumberMapper", ^{
    __block id<HYDMapper> mapper;

    beforeEach(^{
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *number = @(1235555);
        NSString *numberString = [formatter stringFromNumber:number];

        mapper = HYDStringToNumber(@"destKey", NSNumberFormatterDecimalStyle);
        [SpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
        [SpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = numberString;
        [SpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = [NSDate date];
        [SpecHelper specHelper].sharedExampleContext[@"expectedParsedObject"] = number;
    });

    itShouldBehaveLike(@"a mapper that converts from one value to another");

    it(@"should preserve its destination key", ^{
        mapper.destinationKey should equal(@"destKey");
    });
});

SPEC_END
