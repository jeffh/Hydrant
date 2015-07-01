#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDNumberToStringMapperSpec)

describe(@"HYDNumberToStringMapper", ^{
    __block id<HYDMapper> mapper;

    beforeEach(^{
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *number = @(1235555);
        NSString *numberString = [formatter stringFromNumber:number];

        mapper = HYDMapDecimalNumberToString();
        [CDRSpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
        [CDRSpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = number;
        [CDRSpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = [NSDate date];
        [CDRSpecHelper specHelper].sharedExampleContext[@"expectedParsedObject"] = numberString;
    });

    itShouldBehaveLike(@"a mapper that converts from one value to another");
});

SPEC_END
