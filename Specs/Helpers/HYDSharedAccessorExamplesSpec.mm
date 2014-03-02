// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSPerson.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SHARED_EXAMPLE_GROUPS_BEGIN(HYDSharedAccessorExamplesSpec)

sharedExamplesFor(@"an accessor", ^(NSDictionary *scope) {
    __block id<HYDAccessor> accessor;
    __block id validSourceObject;
    __block id validSourceObjectWithNulls;
    __block id invalidSourceObject;
    __block NSArray *expectedValues;
    __block NSArray *expectedValuesWithNulls;
    __block NSArray *expectedFieldNames;

    beforeEach(^{
        accessor = scope[@"accessor"];
        validSourceObject = scope[@"validSourceObject"];
        validSourceObjectWithNulls = scope[@"validSourceObjectWithNulls"];
        invalidSourceObject = scope[@"invalidSourceObject"];
        expectedValues = scope[@"expectedValues"];
        expectedFieldNames = scope[@"expectedFieldNames"];
        expectedValuesWithNulls = scope[@"expectedValuesWithNulls"];
    });

    __block NSArray *values;
    __block HYDError *error;
    __block id target;

    it(@"should list all the fields it was given", ^{
        [accessor fieldNames] should equal(expectedFieldNames);
    });

    describe(@"getting values from a source object", ^{
        subjectAction(^{
            values = [accessor valuesFromSourceObject:target error:&error];
        });

        context(@"when the source object is valid", ^{
            beforeEach(^{
                target = validSourceObject;
            });

            it(@"should return the given value in an array", ^{
                values should equal(expectedValues);
            });

            it(@"should not return an error", ^{
                error should be_nil;
            });
        });

        context(@"when the source object requires NSNull", ^{
            beforeEach(^{
                target = validSourceObjectWithNulls;
            });

            it(@"should return the given value in an array with nils as NSNulls", ^{
                values should equal(expectedValuesWithNulls);
            });

            it(@"should not return an error", ^{
                error should be_nil;
            });
        });

        context(@"when the source object is invalid", ^{
            beforeEach(^{
                target = invalidSourceObject;
            });

            it(@"should return NSNull in the array", ^{
                values should be_nil;
            });

            it(@"should not return an error", ^{
                values should be_nil;
            });

            xcontext(@"(changes for the next major release)", ^{
                it(@"should return nil", ^{
                    values should be_nil;
                });

                it(@"should return a fatal error", ^{
                    error should be_a_fatal_error.with_code(HYDErrorGetViaAccessorFailed);
                });
            });
        });

        context(@"when the source object is nil", ^{
            beforeEach(^{
                target = nil;
            });

            it(@"should return nil", ^{
                values should be_nil;
            });

            it(@"should return a fatal error", ^{
                error should be_a_fatal_error.with_code(HYDErrorGetViaAccessorFailed);
            });
        });
    });

    describe(@"setting values to a given object", ^{
        subjectAction(^{
            error = [accessor setValues:values onObject:target];
        });

        xcontext(@"for the next major release", ^{
            context(@"when the destination class requires NSNull and everything else is valid", ^{
                beforeEach(^{
                    target = [NSMutableDictionary dictionary];
                    values = expectedValuesWithNulls;
                });

                it(@"should update the given object with nulls", ^{
                    target should equal(expectedValuesWithNulls);
                });

                it(@"should not return an error", ^{
                    error should be_nil;
                });
            });
        });

        context(@"when the destination object is valid and it allows nil fields", ^{
            beforeEach(^{
                target = [[HYDSPerson alloc] init];
            });

            context(@"and given values are valid", ^{
                beforeEach(^{
                    values = expectedValues;
                });

                it(@"should update the given object", ^{
                    target should equal(validSourceObject);
                });

                it(@"should not return an error", ^{
                    error should be_nil;
                });
            });

            context(@"but an incorrect number of values are given (too many)", ^{
                beforeEach(^{
                    values = @[@1, @2, @3, @4, @5, @6];
                });

                it(@"should not update the given object", ^{
                    target should equal([[HYDSPerson alloc] init]);
                });

                it(@"should return a fatal error", ^{
                    error should be_a_fatal_error.with_code(HYDErrorSetViaAccessorFailed);
                });
            });

            context(@"but an incorrect number of values are given (too few)", ^{
                beforeEach(^{
                    values = @[];
                });

                it(@"should not update the given object", ^{
                    target should equal([[HYDSPerson alloc] init]);
                });

                it(@"should return a fatal error", ^{
                    error should be_a_fatal_error.with_code(HYDErrorSetViaAccessorFailed);
                });
            });
        });

        context(@"when the destination object is nil", ^{
            beforeEach(^{
                target = nil;
            });

            it(@"should return a fatal error", ^{
                error should be_a_fatal_error.with_code(HYDErrorSetViaAccessorFailed);
            });
        });
    });
});

SHARED_EXAMPLE_GROUPS_END
