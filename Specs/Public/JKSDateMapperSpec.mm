#import "JKSDateMapper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKSDateMapperSpec)

describe(@"JKSDateMapper", ^{
    __block JKSDateMapper *mapper;
    __block NSDate *date;
    __block NSString *dateString;

    beforeEach(^{
        NSDateComponents *referenceDateComponents = [[NSDateComponents alloc] init];
        referenceDateComponents.year = 2012;
        referenceDateComponents.month = 2;
        referenceDateComponents.day = 1;
        referenceDateComponents.hour = 14;
        referenceDateComponents.minute = 30;
        referenceDateComponents.second = 45;
        referenceDateComponents.calendar = [NSCalendar currentCalendar];
        referenceDateComponents.timeZone = [NSTimeZone defaultTimeZone];
        date = [referenceDateComponents date];
        dateString = @"2012-02-01 at 14:30:45";

        mapper = JKSDate(@"dateKey", @"yyyy-MM-dd 'at' HH:mm:ss");
    });

    it(@"should have the same destination key it was given", ^{
        mapper.destinationKey should equal(@"dateKey");
    });

    describe(@"parsing the source object", ^{
        __block id sourceObject;
        __block id parsedObject;

        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject serializer:nil];
        });

        context(@"when given a date", ^{
            beforeEach(^{
                sourceObject = date;
            });

            it(@"should produce a string", ^{
                parsedObject should equal(dateString);
            });
        });

        context(@"when given nil", ^{
            beforeEach(^{
                sourceObject = nil;
            });

            it(@"should produce nil", ^{
                parsedObject == nil should be_truthy;
            });
        });
    });

    describe(@"reverse mapper", ^{
        __block JKSDateMapper *reverseMapper;
        beforeEach(^{
            reverseMapper = [mapper reverseMapperWithDestinationKey:@"otherKey"];
        });

        it(@"should have the given key as its new destination key", ^{
            reverseMapper.destinationKey should equal(@"otherKey");
        });


        describe(@"parsing the source object", ^{
            __block id sourceObject;
            __block id parsedObject;

            subjectAction(^{
                parsedObject = [reverseMapper objectFromSourceObject:sourceObject serializer:nil];
            });

            context(@"when a string is provided", ^{
                beforeEach(^{
                    sourceObject = dateString;
                });

                it(@"should produce a date", ^{
                    parsedObject should equal(date);
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
