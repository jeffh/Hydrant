#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSFakeMapper.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDDateToNumberMapperSpec)

describe(@"HYDDateToNumberMapper", ^{
    __block id<HYDMapper> mapper;

    beforeEach(^{
        HYDSFakeMapper *innerMapper = [HYDSFakeMapper new];
        mapper = HYDMapDateToNumberSince1970(innerMapper, HYDDateTimeUnitMilliseconds);
        NSDictionary *scope = @{@"mapper": mapper,
                                @"innerMapper": innerMapper,
                                @"validSourceObject": [NSDate dateWithTimeIntervalSince1970:1.0001],
                                @"invalidSourceObject": [NSObject new],
                                @"expectedParsedObject": @1000.1,
                                @"parsedObjectsMatcher": ^(NSNumber *actual, NSNumber *expected) {
                                    [actual doubleValue] should be_close_to([expected doubleValue]);
                                }};
        [[CDRSpecHelper specHelper].sharedExampleContext addEntriesFromDictionary:scope];
    });

    itShouldBehaveLike(@"a mapper that converts from one value to another");
});

SPEC_END
