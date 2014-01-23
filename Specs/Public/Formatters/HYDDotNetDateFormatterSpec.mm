#import "HYDDotNetDateFormatter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDDotNetDateFormatterSpec)

describe(@"HYDDotNetDateFormatter", ^{
    __block HYDDotNetDateFormatter *formatter;
    __block id sourceObject;
    __block id parsedObject;

    beforeEach(^{
        formatter = [[HYDDotNetDateFormatter alloc] init];
    });

    it(@"should support NSFormatter methods", PENDING);

    describe(@"converting from JSON.Net date strings to NSDate", ^{
        subjectAction(^{
            parsedObject = [formatter dateFromString:sourceObject];
        });

        context(@"with a positive, timezone-less string", ^{
            beforeEach(^{
                sourceObject = @"/Date(1390186634595)/";
            });

            it(@"should work", ^{
                parsedObject should equal([NSDate dateWithTimeIntervalSince1970:1390186634.595]);
            });
        });

        context(@"with a negative, timezone-less string", ^{
            beforeEach(^{
                sourceObject = @"/Date(-5000)/";
            });

            it(@"should work", ^{
                parsedObject should equal([NSDate dateWithTimeIntervalSince1970:-5]);
            });
        });

        context(@"with a positive, with positive timezone string", ^{
            beforeEach(^{
                sourceObject = @"/Date(1390186634595+0800)/";
            });

            it(@"should work", ^{
                parsedObject should equal([NSDate dateWithTimeIntervalSince1970:1390186634.595]);
            });
        });

        context(@"with a positive, with negative timezone string", ^{
            beforeEach(^{
                sourceObject = @"/Date(1390186634595-0800)/";
            });

            it(@"should work", ^{
                parsedObject should equal([NSDate dateWithTimeIntervalSince1970:1390186634.595]);
            });
        });
    });

    describe(@"converting from NSDate to JSON.Net date strings", ^{
        subjectAction(^{
            parsedObject = [formatter stringFromDate:sourceObject];
        });

        context(@"with a positive, timezone-less string", ^{
            beforeEach(^{
                sourceObject = [NSDate dateWithTimeIntervalSince1970:1390186634.595];
            });

            it(@"should work", ^{
                parsedObject should equal(@"/Date(1390186634595)/");
            });
        });

        context(@"with a negative, timezone-less string", ^{
            beforeEach(^{
                sourceObject = [NSDate dateWithTimeIntervalSince1970:-5];
            });

            it(@"should work", ^{
                parsedObject should equal(@"/Date(-5000)/");
            });
        });

        context(@"with a positive, with positive timezone string", ^{
            beforeEach(^{
                formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:28800];
                sourceObject = [NSDate dateWithTimeIntervalSince1970:1390186634.595];
            });

            it(@"should work", ^{
                parsedObject should equal(@"/Date(1390186634595+0800)/");
            });
        });

        context(@"with a positive, with negative timezone string", ^{
            beforeEach(^{
                formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-28800];
                sourceObject = [NSDate dateWithTimeIntervalSince1970:1390186634.595];
            });

            it(@"should work", ^{
                parsedObject should equal(@"/Date(1390186634595-0800)/");
            });
        });
    });
});

SPEC_END
