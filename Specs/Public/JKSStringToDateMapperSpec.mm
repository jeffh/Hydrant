#import "JKSStringToDateMapper.h"
#import "JKSError.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKSStringToDateMapperSpec)

describe(@"JKSStringToDateMapper", ^{
    __block JKSStringToDateMapper *mapper;
    __block NSString *dateString;
    __block NSDate *date;
    __block id parsedObject;
    __block id sourceObject;
    __block NSError *error;

    beforeEach(^{
        error = nil;

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

        mapper = JKSStringToDate(@"destinationKey", @"yyyy-MM-dd 'at' HH:mm:ss");
    });

    it(@"should have the same destination key it was given", ^{
        mapper.destinationKey should equal(@"destinationKey");
    });

    describe(@"when parsing the source object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when given a date string", ^{
            beforeEach(^{
                sourceObject = dateString;
            });

            it(@"should not produce an error", ^{
                error should be_nil;
            });

            it(@"should produce a date", ^{
                parsedObject should equal(date);
            });
        });

        context(@"when a non-string is provided", ^{
            beforeEach(^{
                sourceObject = [NSDate date];
            });

            it(@"should produe an error", ^{
                error.domain should equal(JKSErrorDomain);
                error.code should equal(JKSErrorInvalidSourceObjectValue);
            });
        });

        context(@"when given nil", ^{
            beforeEach(^{
                sourceObject = nil;
            });

            it(@"should not produce an error", ^{
                error should be_nil;
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });
    });
});

SPEC_END
