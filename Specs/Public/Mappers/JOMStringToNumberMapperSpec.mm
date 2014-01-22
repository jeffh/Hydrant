// DO NOT any other library headers here to simulate an API user.
#import "JOM.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JOMStringToNumberMapperSpec)

describe(@"JOMStringToNumberMapper", ^{
    __block JOMStringToNumberMapper *mapper;
    __block NSString *numberString;
    __block NSNumber *number;
    __block JOMError *error;
    __block id sourceObject;
    __block id parsedObject;

    beforeEach(^{
        error = nil;

        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        number = @(1235555);
        numberString = [formatter stringFromNumber:number];

        mapper = JOMStringToNumberByFormat(@"destKey", NSNumberFormatterDecimalStyle);
    });

    it(@"should preserve its destination key", ^{
        mapper.destinationKey should equal(@"destKey");
    });

    void (^itShouldConvertStringsToNumbers)() = ^{
        context(@"when a numeric string is provided", ^{
            beforeEach(^{
                sourceObject = numberString;
            });

            it(@"should not provide an error", ^{
                error should be_nil;
            });

            it(@"should return the numeric value", ^{
                parsedObject should equal(number);
            });
        });

        context(@"when another value is provided", ^{
            beforeEach(^{
                sourceObject = @"LULZ";
            });

            it(@"should provide a fatal error", ^{
                error should be_a_fatal_error().with_code(JOMErrorInvalidSourceObjectValue);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when the source object is nil", ^{
            beforeEach(^{
                sourceObject = nil;
            });

            it(@"should not provide an error", ^{
                error should be_nil;
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });
    };

    describe(@"parsing the source object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        itShouldConvertStringsToNumbers();
    });

    describe(@"reverse mapper", ^{
        __block JOMNumberToStringMapper *reverseMapper;

        beforeEach(^{
            reverseMapper = [mapper reverseMapperWithDestinationKey:@"key"];
        });

        it(@"should return the given destination key", ^{
            reverseMapper.destinationKey should equal(@"key");
        });

        it(@"should be the inverse of the current mapper", ^{
            sourceObject = numberString;
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
            error should be_nil;

            id result = [reverseMapper objectFromSourceObject:parsedObject error:&error];
            error should be_nil;
            result should equal(sourceObject);
        });
    });
});

SPEC_END
