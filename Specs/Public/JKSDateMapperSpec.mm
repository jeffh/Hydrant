#import "JKSDateMapper.h"
#import "JKSError.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKSDateMapperSpec)

describe(@"JKSDateMapper", ^{
    __block JKSDateMapper *mapper;
    __block NSDate *date;
    __block NSString *dateString;
    __block NSError *error;
    __block id sourceObject;
    __block id parsedObject;

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

        mapper = JKSDate(@"dateKey", @"yyyy-MM-dd 'at' HH:mm:ss");
    });

    it(@"should have the same destination key it was given", ^{
        mapper.destinationKey should equal(@"dateKey");
    });

    void (^itShouldConvertDatesToStrings)() = ^{
        context(@"when given a date", ^{
            beforeEach(^{
                sourceObject = date;
            });

            it(@"should not produce an error", ^{
                error should be_nil;
            });

            it(@"should produce a string", ^{
                parsedObject should equal(dateString);
            });
        });

        context(@"when given another object", ^{
            beforeEach(^{
                sourceObject = @"Yo";
            });

            it(@"should produce an error", ^{
                error.domain should equal(JKSErrorDomain);
                error.code should equal(JKSErrorInvalidSourceObjectValue);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when given nil", ^{
            beforeEach(^{
                sourceObject = nil;
            });

            it(@"should not produce an error", ^{
                error should be_nil;
            });

            it(@"should produce nil", ^{
                parsedObject should be_nil;
            });
        });
    };

    describe(@"parsing the source object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        itShouldConvertDatesToStrings();
    });

    describe(@"parsing the source object with type checking", ^{
        __block Class type;
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject toClass:type error:&error];
        });

        context(@"when the type is NSString", ^{
            beforeEach(^{
                type = [NSString class];
            });

            itShouldConvertDatesToStrings();
        });

        context(@"when it is any other type", ^{
            beforeEach(^{
                type = [NSDate class];
                sourceObject = [NSDate date];
            });

            it(@"should return an error", ^{
                error.domain should equal(JKSErrorDomain);
                error.code should equal(JKSErrorInvalidResultingObjectType);
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

        void (^itShouldConvertStringsToDates)() = ^{
            context(@"when a string is provided", ^{
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

            context(@"when given another object", ^{
                beforeEach(^{
                    sourceObject = [NSDate date];
                });

                it(@"should produce an error with the original error", ^{
                    error.domain should equal(JKSErrorDomain);
                    error.code should equal(JKSErrorInvalidSourceObjectValue);
                });

                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });
            });

            context(@"when nil is provided", ^{
                beforeEach(^{
                    sourceObject = nil;
                });

                it(@"should not produce an error", ^{
                    error should be_nil;
                });

                it(@"should produce nil", ^{
                    parsedObject should be_nil;
                });
            });
        };

        describe(@"parsing the source object", ^{
            subjectAction(^{
                parsedObject = [reverseMapper objectFromSourceObject:sourceObject error:&error];
            });

            itShouldConvertStringsToDates();
        });

        describe(@"parsing the source object with type checking", ^{
            __block Class type;

            subjectAction(^{
                parsedObject = [reverseMapper objectFromSourceObject:sourceObject toClass:type error:&error];
            });

            context(@"when the type is NSDate", ^{
                beforeEach(^{
                    type = [NSDate class];
                });

                itShouldConvertStringsToDates();
            });

            context(@"when it is any other type", ^{
                beforeEach(^{
                    type = [NSString class];
                    sourceObject = dateString;
                });

                it(@"should return an error", ^{
                    error.domain should equal(JKSErrorDomain);
                    error.code should equal(JKSErrorInvalidResultingObjectType);
                });
            });
        });
    });
});

SPEC_END
