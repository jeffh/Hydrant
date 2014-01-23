// DO NOT any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDError+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDStringToURLMapperSpec)

describe(@"HYDStringToURLMapper", ^{
    __block HYDStringToURLMapper *mapper;
    __block HYDError *error;
    __block id sourceObject;
    __block id parsedObject;

    sharedExamplesFor(@"a mapper that converts strings to URLs", ^(NSDictionary *scope) {
        context(@"when the object is valid", ^{
            beforeEach(^{
                sourceObject = @"http://jeffhui.net";
            });

            it(@"should return the parsed object", ^{
                parsedObject should equal([NSURL URLWithString:@"http://jeffhui.net"]);
            });

            it(@"should not return an error", ^{
                error should be_nil;
            });
        });

        context(@"when the object is an invalid type", ^{
            beforeEach(^{
                sourceObject = [NSNull null];
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should return a fatal error", ^{
                error should be_a_fatal_error().with_code(HYDErrorInvalidSourceObjectValue);
            });
        });

        context(@"when the object is nil", ^{
            beforeEach(^{
                sourceObject = nil;
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should not return an error", ^{
                error should be_nil;
            });
        });
    });

    context(@"without any allowed schemes", ^{
        beforeEach(^{
            mapper = HYDStringToURL(@"destinationKey");
        });

        it(@"should report the same destination key", ^{
            [mapper destinationKey] should equal(@"destinationKey");
        });

        describe(@"parsing an object", ^{
            subjectAction(^{
                parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
            });

            itShouldBehaveLike(@"a mapper that converts strings to URLs");
        });
    });

    context(@"with allowed schemes", ^{
        beforeEach(^{
            mapper = HYDStringToURLOfScheme(@"destinationKey", @[@"http", @"HTTPS"]);
        });

        it(@"should report the same destination key", ^{
            [mapper destinationKey] should equal(@"destinationKey");
        });

        describe(@"parsing an object", ^{
            subjectAction(^{
                parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
            });

            context(@"when given a scheme not allowed", ^{
                beforeEach(^{
                    sourceObject = @"ftp://google.com";
                });

                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });

                it(@"should raise a fatal error", ^{
                    error should be_a_fatal_error().with_code(HYDErrorInvalidSourceObjectValue);
                });
            });

            context(@"when given a scheme allowed, but different cased", ^{
                beforeEach(^{
                    sourceObject = @"https://google.com";
                });

                it(@"should return the url", ^{
                    parsedObject should equal([NSURL URLWithString:@"https://google.com"]);
                });

                it(@"should not return an error", ^{
                    error should be_nil;
                });
            });

            itShouldBehaveLike(@"a mapper that converts strings to URLs");
        });
    });

    xdescribe(@"reverse mapper", ^{
        beforeEach(^{
            [SpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
            [SpecHelper specHelper].sharedExampleContext[@"sourceObject"] = @"http://jeffhui.net";
        });

        itShouldBehaveLike(@"a mapper that does the inverse of the original");
    });
});

SPEC_END
