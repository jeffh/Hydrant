// DO NOT any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDDotNetDateFormatterSpec)

describe(@"HYDDotNetDateFormatter", ^{
    __block HYDDotNetDateFormatter *formatter;
    __block id sourceObject;
    __block id parsedObject;
    __block NSString *errorDescription;
    __block BOOL success;

    beforeEach(^{
        formatter = [[HYDDotNetDateFormatter alloc] init];
    });

    void (^itShouldSucceedAsDate)(NSDate *) = ^(NSDate *expectedDate) {
        it(@"should work", ^{
            parsedObject should equal(expectedDate);
        });

        it(@"should be successful", ^{
            success should be_truthy;
        });

        it(@"should no emit any error", ^{
            errorDescription should be_nil;
        });
    };

    void (^itShouldSucceedAsString)(NSString *) = ^(NSString *expectedString) {
        it(@"should work", ^{
            parsedObject should equal(expectedString);
        });

        it(@"should be successful", ^{
            success should be_truthy;
        });

        it(@"should no emit any error", ^{
            errorDescription should be_nil;
        });
    };

    describe(@"converting from JSON.Net date strings to NSDate (NSFormatter method)", ^{
        subjectAction(^{
            success = [formatter getObjectValue:&parsedObject
                                      forString:sourceObject
                               errorDescription:&errorDescription];
        });

        context(@"with an invalid string", ^{
            beforeEach(^{
                sourceObject = @"lol";
            });

            it(@"should fail", ^{
                success should_not be_truthy;
            });

            it(@"should report an error description", ^{
                errorDescription should equal(@"The value 'lol' is not a valid .net date");
            });
        });

        context(@"with a positive, timezone-less string", ^{
            beforeEach(^{
                sourceObject = @"/Date(1390186634595)/";
            });

            itShouldSucceedAsDate([NSDate dateWithTimeIntervalSince1970:1390186634.595]);
        });

        context(@"with a negative, timezone-less string", ^{
            beforeEach(^{
                sourceObject = @"/Date(-5000)/";
            });

            itShouldSucceedAsDate([NSDate dateWithTimeIntervalSince1970:-5]);
        });

        context(@"with a positive, with positive timezone string", ^{
            beforeEach(^{
                sourceObject = @"/Date(1390186634595+0800)/";
            });

            itShouldSucceedAsDate([NSDate dateWithTimeIntervalSince1970:1390186634.595]);
        });

        context(@"with a positive, with negative timezone string", ^{
            beforeEach(^{
                sourceObject = @"/Date(1390186634595-0800)/";
            });

            itShouldSucceedAsDate([NSDate dateWithTimeIntervalSince1970:1390186634.595]);
        });
    });

    describe(@"converting from NSDate to JSON.Net date strings (NSFormatter method)", ^{
        subjectAction(^{
            parsedObject = [formatter stringForObjectValue:sourceObject];
        });

        context(@"when not given a date", ^{
            beforeEach(^{
                sourceObject = @1;
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"with a positive, timezone-less string", ^{
            beforeEach(^{
                sourceObject = [NSDate dateWithTimeIntervalSince1970:1390186634.595];
            });

            itShouldSucceedAsString(@"/Date(1390186634595)/");
        });

        context(@"with a negative, timezone-less string", ^{
            beforeEach(^{
                sourceObject = [NSDate dateWithTimeIntervalSince1970:-5];
            });

            itShouldSucceedAsString(@"/Date(-5000)/");
        });

        context(@"with a positive, with positive timezone string", ^{
            beforeEach(^{
                formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:28800];
                sourceObject = [NSDate dateWithTimeIntervalSince1970:1390186634.595];
            });

            itShouldSucceedAsString(@"/Date(1390186634595+0800)/");
        });

        context(@"with a positive, with negative timezone string", ^{
            beforeEach(^{
                formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-28800];
                sourceObject = [NSDate dateWithTimeIntervalSince1970:1390186634.595];
            });

            itShouldSucceedAsString(@"/Date(1390186634595-0800)/");
        });
    });

    describe(@"converting from JSON.Net date strings to NSDate (NSDateFormatter method)", ^{
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

    describe(@"converting from NSDate to JSON.Net date strings (NSDateFormatter method)", ^{
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
