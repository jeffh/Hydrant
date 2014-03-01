// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDSnakeToCamelCaseValueTransformerSpec)

describe(@"HYDSnakeToCamelCaseValueTransformer", ^{
    __block HYDSnakeToCamelCaseValueTransformer *transformer;

    beforeEach(^{
        transformer = [[HYDSnakeToCamelCaseValueTransformer alloc] init];
    });

    context(@"parsing a string", ^{
        context(@"when converting to lower camel cased", ^{
            it(@"should convert snake case", ^{
                [transformer transformedValue:@"foo_bar"] should equal(@"fooBar");
                [transformer transformedValue:@"foo_bar_lol"] should equal(@"fooBarLol");
                [transformer transformedValue:@"Yo__Dog"] should equal(@"yoDog");
                [transformer transformedValue:@"_yoDog"] should equal(@"Yodog");
                [transformer transformedValue:@"yoDog_"] should equal(@"yodog");
                [transformer transformedValue:@"^%)$(@yoDog$!@$)!#(~"] should equal(@"^%)$(@yodog$!@$)!#(~");
            });
        });

        context(@"when converting to upper camel cased", ^{
            beforeEach(^{
                transformer = [[HYDSnakeToCamelCaseValueTransformer alloc] initWithCamelCaseStyle:HYDCamelCaseUpperStyle];
            });

            it(@"should convert snake case", ^{
                [transformer transformedValue:@"foo_bar"] should equal(@"FooBar");
                [transformer transformedValue:@"foo_bar_lol"] should equal(@"FooBarLol");
                [transformer transformedValue:@"Yo__Dog"] should equal(@"YoDog");
                [transformer transformedValue:@"_yoDog"] should equal(@"Yodog");
                [transformer transformedValue:@"yoDog_"] should equal(@"Yodog");
                [transformer transformedValue:@"^%)$(@yoDog$!@$)!#(~"] should equal(@"^%)$(@yodog$!@$)!#(~");
            });
        });

        it(@"should convert camel case to snake case", ^{
            [transformer reverseTransformedValue:@"fooBar"] should equal(@"foo_bar");
            [transformer reverseTransformedValue:@"fooBarLol"] should equal(@"foo_bar_lol");
            [transformer reverseTransformedValue:@"yoDog"] should equal(@"yo_dog");
            [transformer reverseTransformedValue:@"YoDog"] should equal(@"yo_dog");
            [transformer reverseTransformedValue:@"#@!)($*%)!*#%$yoDog@*#%(&!)*(@#"] should equal(@"#@!)($*%)!*#%$yo_dog@*#%(&!)*(@#");
            [transformer reverseTransformedValue:@"yodog"] should equal(@"yodog");
        });
    });

    context(@"parsing a non-string", ^{
        it(@"should return nil", ^{
            [transformer transformedValue:[NSDate date]] should be_nil;
        });

        it(@"should return nil for its reverse transformation", ^{
            [transformer reverseTransformedValue:[NSDate date]] should be_nil;
        });
    });
});

SPEC_END
