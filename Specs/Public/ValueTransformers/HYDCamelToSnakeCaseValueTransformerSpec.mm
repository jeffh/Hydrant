// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDCamelToSnakeCaseValueTransformerSpec)

describe(@"HYDCamelToSnakeCaseValueTransformer", ^{
    __block HYDCamelToSnakeCaseValueTransformer *transformer;

    beforeEach(^{
        transformer = [[HYDCamelToSnakeCaseValueTransformer alloc] init];
    });

    context(@"parsing a string", ^{
        context(@"when converting to lower camel cased", ^{
            it(@"should convert snake case", ^{
                [transformer reverseTransformedValue:@"foo_bar"] should equal(@"fooBar");
                [transformer reverseTransformedValue:@"foo_bar_lol"] should equal(@"fooBarLol");
                [transformer reverseTransformedValue:@"Yo__Dog"] should equal(@"yoDog");
                [transformer reverseTransformedValue:@"_yoDog"] should equal(@"Yodog");
                [transformer reverseTransformedValue:@"yoDog_"] should equal(@"yodog");
                [transformer reverseTransformedValue:@"^%)$(@yoDog$!@$)!#(~"] should equal(@"^%)$(@yodog$!@$)!#(~");
            });
        });

        context(@"when converting to upper camel cased", ^{
            beforeEach(^{
                transformer = [[HYDCamelToSnakeCaseValueTransformer alloc] initWithCamelCaseStyle:HYDCamelCaseUpperStyle];
            });

            it(@"should convert snake case", ^{
                [transformer reverseTransformedValue:@"foo_bar"] should equal(@"FooBar");
                [transformer reverseTransformedValue:@"foo_bar_lol"] should equal(@"FooBarLol");
                [transformer reverseTransformedValue:@"Yo__Dog"] should equal(@"YoDog");
                [transformer reverseTransformedValue:@"_yoDog"] should equal(@"Yodog");
                [transformer reverseTransformedValue:@"yoDog_"] should equal(@"Yodog");
                [transformer reverseTransformedValue:@"^%)$(@yoDog$!@$)!#(~"] should equal(@"^%)$(@yodog$!@$)!#(~");
            });
        });

        it(@"should convert camel case to snake case", ^{
            [transformer transformedValue:@"fooBar"] should equal(@"foo_bar");
            [transformer transformedValue:@"fooBarLol"] should equal(@"foo_bar_lol");
            [transformer transformedValue:@"yoDog"] should equal(@"yo_dog");
            [transformer transformedValue:@"YoDog"] should equal(@"yo_dog");
            [transformer transformedValue:@"#@!)($*%)!*#%$yoDog@*#%(&!)*(@#"] should equal(@"#@!)($*%)!*#%$yo_dog@*#%(&!)*(@#");
            [transformer transformedValue:@"yodog"] should equal(@"yodog");
        });
    });

    context(@"parsing a non-string", ^{
        it(@"should return nil", ^{
            [transformer reverseTransformedValue:[NSDate date]] should be_nil;
        });

        it(@"should return nil for its reverse transformation", ^{
            [transformer transformedValue:[NSDate date]] should be_nil;
        });
    });
});

SPEC_END
