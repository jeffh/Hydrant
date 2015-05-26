#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDUUIDFormatterSpec)

describe(@"HYDUUIDFormatter", ^{
    __block HYDUUIDFormatter *formatter;
    __block id sourceObject;
    __block id parsedObject;
    __block NSString *errorDescription;
    __block BOOL success;

    beforeEach(^{
        formatter = [[HYDUUIDFormatter alloc] init];
    });

    describe(@"converting an NSUUID into a string", ^{
        subjectAction(^{
            parsedObject = [formatter stringForObjectValue:sourceObject];
        });

        context(@"when a valid NSUUID is given", ^{
            beforeEach(^{
                sourceObject = [NSUUID UUID];
            });

            it(@"should return a string of the UUID", ^{
                parsedObject should equal([sourceObject UUIDString]);
            });
        });

        context(@"when NSNull is given", ^{
            beforeEach(^{
                sourceObject = [NSNull null];
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when nil is given", ^{
            beforeEach(^{
                sourceObject = nil;
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });
    });

    describe(@"converting a string into an NSUUID", ^{
        subjectAction(^{
            success = [formatter getObjectValue:&parsedObject forString:sourceObject errorDescription:&errorDescription];
        });

        context(@"when a string is a valid UUID", ^{
            __block NSUUID *uuid;

            beforeEach(^{
                uuid = [NSUUID UUID];
                sourceObject = [uuid UUIDString];
            });

            it(@"should return an NSUUID", ^{
                parsedObject should equal(uuid);
            });

            it(@"should not return an error", ^{
                success should be_truthy;
                errorDescription should be_nil;
            });
        });

        context(@"when the string is not a valid UUID", ^{
            beforeEach(^{
                sourceObject = @"I am not a valid UUID";
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should return an error", ^{
                success should_not be_truthy;
                errorDescription should equal(@"The value 'I am not a valid UUID' is not a valid UUID");
            });
        });

        context(@"when the input is not a string", ^{
            beforeEach(^{
                sourceObject = [NSNull null];
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should return an error", ^{
                success should_not be_truthy;
                errorDescription should equal(@"The value '<null>' is not a valid string");
            });
        });

        context(@"when given nil", ^{
            beforeEach(^{
                sourceObject = nil;
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should return an error", ^{
                success should_not be_truthy;
                errorDescription should equal(@"The value '(null)' is not a valid string");
            });
        });
    });
});

SPEC_END
