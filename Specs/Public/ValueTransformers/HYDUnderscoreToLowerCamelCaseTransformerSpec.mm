// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDUnderscoreToLowerCamelCaseTransformerSpec)

describe(@"HYDUnderscoreToLowerCamelCaseTransformer", ^{
    __block HYDUnderscoreToLowerCamelCaseTransformer *transformer;

    beforeEach(^{
        transformer = [[HYDUnderscoreToLowerCamelCaseTransformer alloc] init];
    });

    it(@"should indicate its reversability", ^{
        [HYDUnderscoreToLowerCamelCaseTransformer allowsReverseTransformation] should be_truthy;
    });

    context(@"parsing a string", ^{
        it(@"should lower camel-case underscored text", ^{
            [transformer transformedValue:@"foo_bar"] should equal(@"fooBar");
            [transformer transformedValue:@"foo_bar_lol"] should equal(@"fooBarLol");
            [transformer transformedValue:@"Yo_Dog"] should equal(@"yoDog");
            [transformer transformedValue:@"_yoDog"] should equal(@"yodog");
            [transformer transformedValue:@"yoDog_"] should equal(@"yodog");
            [transformer transformedValue:@"^%)$(@yoDog$!@$)!#(~"] should equal(@"yodog");
        });

        it(@"should convert underscored into lower camel-cased", ^{
            [transformer reverseTransformedValue:@"fooBar"] should equal(@"foo_bar");
            [transformer reverseTransformedValue:@"fooBarLol"] should equal(@"foo_bar_lol");
            [transformer reverseTransformedValue:@"yoDog"] should equal(@"yo_dog");
            [transformer reverseTransformedValue:@"YoDog"] should equal(@"yo_dog");
            [transformer reverseTransformedValue:@"#@!)($*%)!*#%$yoDog@*#%(&!)*(@#"] should equal(@"yo_dog");
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
