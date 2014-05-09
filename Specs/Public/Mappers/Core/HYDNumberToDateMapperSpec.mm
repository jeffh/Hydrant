// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSFakeMapper.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDNumberToDateMapperSpec)

describe(@"HYDNumberToDateMapper", ^{
    __block id<HYDMapper> mapper;

    beforeEach(^{
        HYDSFakeMapper *innerMapper = [HYDSFakeMapper new];
        mapper = HYDMapNumberToDateSince1970(innerMapper, HYDDateTimeUnitMilliseconds);
        NSDictionary *scope = @{@"mapper": mapper,
                                @"innerMapper": innerMapper,
                                @"validSourceObject": @1000.1,
                                @"invalidSourceObject": [NSObject new],
                                @"expectedParsedObject": [NSDate dateWithTimeIntervalSince1970:1.0001],
                                @"sourceObjectsMatcher": ^(NSNumber *actual, NSNumber *expected) {
                                    [actual doubleValue] should be_close_to([expected doubleValue]);
                                }};
        [[SpecHelper specHelper].sharedExampleContext addEntriesFromDictionary:scope];
    });

    itShouldBehaveLike(@"a mapper that converts from one value to another");
});

SPEC_END
