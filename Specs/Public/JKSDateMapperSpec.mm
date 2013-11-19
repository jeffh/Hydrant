#import "JKSDateMapper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKSDateMapperSpec)

describe(@"JKSDateMapper", ^{
    __block JKSDateMapper *mapper;
    __block NSDate *date;
    __block NSString *dateString;

    beforeEach(^{
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.year = 2012;
        components.month = 2;
        components.day = 1;
        components.hour = 12;
        components.minute = 30;
        components.second = 45;
        components.calendar = [NSCalendar currentCalendar];
        components.timeZone = [NSTimeZone defaultTimeZone];
        date = [components date];
        dateString = @"2012-02-01 at 12:30:45";

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

        context(@"when given a string is given", ^{
            beforeEach(^{
                sourceObject = dateString;
            });

            it(@"should produce a date", ^{
                parsedObject should equal(date);
            });
        });

        context(@"when given a nil source object", ^{
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

            context(@"when a date is provided", ^{
                beforeEach(^{
                    sourceObject = date;
                });

                it(@"should produce a string", ^{
                    parsedObject should equal(dateString);
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
