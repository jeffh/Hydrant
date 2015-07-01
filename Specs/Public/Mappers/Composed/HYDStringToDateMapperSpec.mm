#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDStringToDateMapperSpec)

describe(@"HYDStringToDateMapper", ^{
    __block id<HYDMapper> mapper;

    beforeEach(^{
        NSDateComponents *referenceDateComponents = [[NSDateComponents alloc] init];
        referenceDateComponents.year = 2012;
        referenceDateComponents.month = 2;
        referenceDateComponents.day = 1;
        referenceDateComponents.hour = 14;
        referenceDateComponents.minute = 30;
        referenceDateComponents.second = 45;
        referenceDateComponents.calendar = [NSCalendar currentCalendar];
        referenceDateComponents.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        NSDate *date = [referenceDateComponents date];
        NSString *dateString = @"2012-02-01 at 14:30:45";

        mapper = HYDMapStringToDate(@"yyyy-MM-dd 'at' HH:mm:ss");
        [CDRSpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
        [CDRSpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = dateString;
        [CDRSpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = @1;
        [CDRSpecHelper specHelper].sharedExampleContext[@"expectedParsedObject"] = date;
    });

    itShouldBehaveLike(@"a mapper that converts from one value to another");
});

SPEC_END
