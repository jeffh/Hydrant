#import "JKSNumberMapper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKSNumberMapperSpec)

describe(@"JKSNumberMapper", ^{
    __block JKSNumberMapper *mapper;
    __block NSString *numberString;
    __block NSNumber *number;
    __block NSError *error;

    beforeEach(^{
        error = nil;

        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        number = @(1235555);
        numberString = [formatter stringFromNumber:number];

        mapper = JKSNumberStyle(@"numberKey", NSNumberFormatterDecimalStyle);
    });

    it(@"should preserve its destination key", ^{
        mapper.destinationKey should equal(@"numberKey");
    });

    describe(@"parsing the source object", ^{
        __block id sourceObject;
        __block id parsedObject;

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

        context(@"when nil is provided", ^{
            beforeEach(^{
                sourceObject = nil;
            });

            it(@"should produce nil", ^{
                parsedObject == nil should be_truthy;
            });
        });
    });

    describe(@"reverse mapper", ^{
        __block JKSNumberMapper *reverseMapper;

        beforeEach(^{
            reverseMapper = [mapper reverseMapperWithDestinationKey:@"anotherKey"];
        });

        it(@"should return the given key", ^{
            reverseMapper.destinationKey should equal(@"anotherKey");
        });

        describe(@"parsing the source object", ^{
            __block id sourceObject;
            __block id parsedObject;

            subjectAction(^{
                parsedObject = [reverseMapper objectFromSourceObject:sourceObject error:&error];
            });

            context(@"when a string is provided", ^{
                beforeEach(^{
                    sourceObject = numberString;
                });

                it(@"should produce a number object", ^{
                    parsedObject should equal(number);
                });
            });

            context(@"when nil is provided", ^{
                beforeEach(^{
                    sourceObject = nil;
                });

                it(@"should produce nil", ^{
                    parsedObject == nil should be_truthy;
                });
            });
        });
    });
});

SPEC_END
