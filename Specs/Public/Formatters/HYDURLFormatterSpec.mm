// DO NOT any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDURLFormatterSpec)

describe(@"HYDURLFormatter", ^{
    __block HYDURLFormatter *formatter;
    __block id sourceObject;
    __block id parsedObject;
    __block NSString *errorDescription;
    __block BOOL success;

    beforeEach(^{
        formatter = [[HYDURLFormatter alloc] init];
    });

    describe(@"converting an NSURL into a string", ^{
        subjectAction(^{
            parsedObject = [formatter stringForObjectValue:sourceObject];
        });

        context(@"when a valid NSURL is given without any scheme validation", ^{
            beforeEach(^{
                sourceObject = [NSURL URLWithString:@"http://google.com"];
            });

            it(@"should return the absolute url", ^{
                parsedObject should equal(@"http://google.com");
            });
        });

        context(@"when a valid NSURL is given with any scheme validation", ^{
            beforeEach(^{
                formatter = [[HYDURLFormatter alloc] initWithAllowedSchemes:[NSSet setWithArray:@[@"http"]]];
                sourceObject = [NSURL URLWithString:@"HTTP://google.com"];
            });

            it(@"should return the absolute url", ^{
                parsedObject should equal(@"HTTP://google.com");
            });
        });

        context(@"when a valid NSURL is given but an invalid scheme", ^{
            beforeEach(^{
                formatter = [[HYDURLFormatter alloc] initWithAllowedSchemes:[NSSet setWithArray:@[@"http"]]];
                sourceObject = [NSURL URLWithString:@"ftp://example.com"];
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when a non NSURL is given", ^{
            beforeEach(^{
                sourceObject = @1;
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

    describe(@"converting a string into an NSURL", ^{
        subjectAction(^{
            success = [formatter getObjectValue:&parsedObject
                                      forString:sourceObject
                               errorDescription:&errorDescription];
        });

        context(@"when a valid url string is given without any scheme validation", ^{
            beforeEach(^{
                sourceObject = @"http://jeffhui.net/example.html";
            });

            it(@"should return an NSURL", ^{
                parsedObject should equal([NSURL URLWithString:sourceObject]);
            });

            it(@"should not error", ^{
                success should be_truthy;
                errorDescription should be_nil;
            });
        });

        context(@"when a valid url string is given with scheme validation", ^{
            beforeEach(^{
                formatter = [[HYDURLFormatter alloc] initWithAllowedSchemes:[NSSet setWithArray:@[@"http"]]];
                sourceObject = @"HTTP://jeffhui.net/example.html";
            });

            it(@"should return an NSURL", ^{
                parsedObject should equal([NSURL URLWithString:sourceObject]);
            });

            it(@"should not error", ^{
                success should be_truthy;
                errorDescription should be_nil;
            });
        });

        context(@"when a valid NSURL is given but an invalid scheme", ^{
            beforeEach(^{
                formatter = [[HYDURLFormatter alloc] initWithAllowedSchemes:[NSSet setWithArray:@[@"http", @"lol"]]];
                sourceObject = @"ftp://example.com";
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should report an error", ^{
                success should_not be_truthy;
                errorDescription should equal(@"The value 'ftp://example.com' is not a valid URL with an accepted scheme: lol, http");
            });
        });

        context(@"when an invalid url string is given", ^{
            beforeEach(^{
                sourceObject = @"!!";
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should report an error", ^{
                success should_not be_truthy;
                errorDescription should equal(@"The value '!!' is not a valid URL");
            });
        });
    });
});

SPEC_END
