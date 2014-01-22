// DO NOT any other library headers here to simulate an API user.
#import "JOM.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JOMNumberToStringMapperSpec)

describe(@"JOMNumberToStringMapper", ^{
    __block JOMNumberToStringMapper *mapper;
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

        mapper = JOMNumberToStringByFormat(@"numberKey", NSNumberFormatterDecimalStyle);
    });

    it(@"should preserve its destination key", ^{
        mapper.destinationKey should equal(@"numberKey");
    });

    describe(@"parsing the source object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when a number is provided", ^{
            beforeEach(^{
                sourceObject = number;
            });

            it(@"should produce a string object", ^{
                parsedObject should equal(numberString);
            });
        });

        context(@"when another type of object is provided", ^{
            beforeEach(^{
                sourceObject = [NSDate date];
            });

            it(@"should provide a fatal error", ^{
                error should be_a_fatal_error().with_code(JOMErrorInvalidSourceObjectValue);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when nil is provided", ^{
            beforeEach(^{
                sourceObject = nil;
            });

            it(@"should produce nil", ^{
                parsedObject should be_nil;
            });
        });
    });

    describe(@"reverse mapper", ^{
        __block id<JOMMapper> reverseMapper;

        beforeEach(^{
            reverseMapper = [mapper reverseMapperWithDestinationKey:@"anotherKey"];
        });

        it(@"should return the given key", ^{
            reverseMapper.destinationKey should equal(@"anotherKey");
        });

        it(@"should be the inverse of the current mapper", ^{
            sourceObject = number;
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
            error should be_nil;

            id result = [reverseMapper objectFromSourceObject:parsedObject error:&error];
            error should be_nil;
            result should equal(sourceObject);
        });
    });
});

SPEC_END
