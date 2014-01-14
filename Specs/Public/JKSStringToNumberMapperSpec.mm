#import "JKSStringToNumberMapper.h"
#import "JKSError.h"
#import "JKSNumberToStringMapper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKSStringToNumberMapperSpec)

describe(@"JKSStringToNumberMapper", ^{
    __block JKSStringToNumberMapper *mapper;
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

        mapper = JKSStringToNumber(@"destKey", NSNumberFormatterDecimalStyle);
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

            it(@"should provide an error", ^{
                error.domain should equal(JKSErrorDomain);
                error.code should equal(JKSErrorInvalidSourceObjectValue);
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

    describe(@"parsing the source object with type checking", ^{
        __block Class type;

        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject toClass:type error:&error];
        });

        context(@"when the expected return type is NSNumber", ^{
            beforeEach(^{
                type = [NSNumber class];
            });

            itShouldConvertStringsToNumbers();
        });

        context(@"when the expected return type is not an NSNumber", ^{
            beforeEach(^{
                sourceObject = numberString;
                type = [NSString class];
            });

            it(@"should produce an error", ^{
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
