#import "JKSNumberToStringMapper.h"
#import "JKSError.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKSNumberToStringMapperSpec)

describe(@"JKSNumberToStringMapper", ^{
    __block JKSNumberToStringMapper *mapper;
    __block NSString *numberString;
    __block NSNumber *number;
    __block NSError *error;
    __block id sourceObject;
    __block id parsedObject;

    beforeEach(^{
        error = nil;

        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        number = @(1235555);
        numberString = [formatter stringFromNumber:number];

        mapper = JKSNumberToString(@"numberKey", NSNumberFormatterDecimalStyle);
    });

    it(@"should preserve its destination key", ^{
        mapper.destinationKey should equal(@"numberKey");
    });

    void (^itShouldConvertNumbersToStrings)() = ^{
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

            it(@"should provide an error", ^{
                error.domain should equal(JKSErrorDomain);
                error.code should equal(JKSErrorInvalidSourceObjectValue);
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
    };

    describe(@"parsing the source object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        itShouldConvertNumbersToStrings();
    });

    describe(@"parsing the source object with type checking", ^{
        __block Class type;

        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject toClass:type error:&error];
        });

        context(@"when the expected return type is NSString", ^{
            beforeEach(^{
                type = [NSString class];
            });

            itShouldConvertNumbersToStrings();
        });

        context(@"when the expected return type is something else", ^{
            beforeEach(^{
                sourceObject = number;
                type = [NSDate class];
            });

            it(@"should provide an error", ^{
                error.domain should equal(JKSErrorDomain);
                error.code should equal(JKSErrorInvalidResultingObjectType);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });
    });

    describe(@"reverse mapper", ^{
        __block JKSNumberToStringMapper *reverseMapper;

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
