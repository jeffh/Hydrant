// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDPerson.h"
#import "HYDFakeMapper.h"
#import "HYDError+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDKeyValueMapperSpec)

describe(@"HYDKeyValueMapper", ^{
    __block HYDKeyValueMapper *mapper;
    __block HYDError *error;
    __block HYDPerson *expectedPerson;
    __block NSDictionary *validSourceObject;
    __block id sourceObject;
    __block id parsedObject;
    __block HYDFakeMapper *childMapper1;
    __block HYDFakeMapper *childMapper2;

    beforeEach(^{
        expectedPerson = [[HYDPerson alloc] initWithFixtureData];
        validSourceObject = @{@"first_name": @"John",
                              @"last_name": @"Doe",
                              @"age": @23,
                              @"identifier": @"transforms"};

        childMapper1 = [[HYDFakeMapper alloc] initWithDestinationKey:@"identifier"];
        childMapper1.objectsToReturn = @[@5];
        childMapper2 = [[HYDFakeMapper alloc] initWithDestinationKey:@"firstName"];
        childMapper2.objectsToReturn = @[@"John"];

        mapper = HYDMapObject(@"destinationAccessor",
                              [NSDictionary class],
                              [HYDPerson class],
                              @{@"first_name" : childMapper2,
                                @"last_name" : @"lastName",
                                @"age" : @"age",
                                @"identifier" : childMapper1});
    });

    it(@"should return the same destination key it was provided", ^{
        mapper.destinationAccessor should equal(HYDAccessKey(@"destinationAccessor"));
    });

    describe(@"parsing the source object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when a valid source object is given", ^{
            beforeEach(^{
                sourceObject = validSourceObject;
            });

            it(@"should not have any error", ^{
                error should be_nil;
            });

            it(@"should produce an instance of the class given", ^{
                parsedObject should be_instance_of([HYDPerson class]);
            });

            it(@"should set all the properties on the parsed object based on the mapping provided", ^{
                parsedObject should equal(expectedPerson);
            });
        });

        context(@"when a NSNull is given", ^{
            beforeEach(^{
                sourceObject = @{@"first_name": @"John",
                                 @"last_name": [NSNull null],
                                 @"age": @23,
                                 @"identifier": @"transforms"};
            });

            it(@"should not have any error", ^{
                error should be_nil;
            });

            it(@"should produce an instance of the class given", ^{
                parsedObject should be_instance_of([HYDPerson class]);
            });

            it(@"should set all the properties on the parsed object based on the mapping provided", ^{
                HYDPerson *personWithOutLastName = [[HYDPerson alloc] initWithFixtureData];
                personWithOutLastName.lastName = nil;
                parsedObject should equal(personWithOutLastName);
            });
        });

        context(@"when child mappers returns fatal errors", ^{
            __block HYDError *childMapperError1;
            __block HYDError *childMapperError2;

            beforeEach(^{
                sourceObject = validSourceObject;
                childMapperError1 = [HYDError fatalError];
                childMapperError2 = [HYDError fatalError];
                childMapper1.objectsToReturn = nil;
                childMapper1.errorsToReturn = @[childMapperError1];
                childMapper2.objectsToReturn = nil;
                childMapper2.errorsToReturn = @[childMapperError2];

                childMapperError1 = [HYDError errorFromError:childMapperError1
                                    prependingSourceAccessor:HYDAccessKey(@"identifier")
                                      andDestinationAccessor:nil
                                     replacementSourceObject:@"transforms"
                                                     isFatal:YES];
                childMapperError2 = [HYDError errorFromError:childMapperError2
                                    prependingSourceAccessor:HYDAccessKey(@"first_name")
                                      andDestinationAccessor:nil
                                     replacementSourceObject:@"John"
                                                     isFatal:YES];
            });

            it(@"should wrap all the emitted errors in a fatal error", ^{
                error should be_a_fatal_error.with_code(HYDErrorMultipleErrors);
                [error.userInfo[HYDUnderlyingErrorsKey] count] should equal(2);
                error.userInfo[HYDUnderlyingErrorsKey] should contain(childMapperError1);
                error.userInfo[HYDUnderlyingErrorsKey] should contain(childMapperError2);
            });
        });

        context(@"when child mappers returns non-fatal errors", ^{
            __block HYDError *childMapperError1;
            __block HYDError *childMapperError2;

            beforeEach(^{
                sourceObject = validSourceObject;
                childMapperError1 = [HYDError nonFatalError];
                childMapperError2 = [HYDError nonFatalError];
                childMapper1.objectsToReturn = @[@1];
                childMapper1.errorsToReturn = @[childMapperError1];
                childMapper2.objectsToReturn = @[@"James"];
                childMapper2.errorsToReturn = @[childMapperError2];

                childMapperError1 = [HYDError errorFromError:childMapperError1
                                    prependingSourceAccessor:HYDAccessKey(@"identifier")
                                      andDestinationAccessor:nil
                                     replacementSourceObject:@"transforms"
                                                     isFatal:NO];
                childMapperError2 = [HYDError errorFromError:childMapperError2
                                    prependingSourceAccessor:HYDAccessKey(@"first_name")
                                      andDestinationAccessor:nil
                                     replacementSourceObject:@"John"
                                                     isFatal:NO];
            });

            it(@"should wrap all the emitted errors in a non-fatal error", ^{
                error should be_a_non_fatal_error.with_code(HYDErrorMultipleErrors);
                [error.userInfo[HYDUnderlyingErrorsKey] count] should equal(2);
                error.userInfo[HYDUnderlyingErrorsKey] should contain(childMapperError1);
                error.userInfo[HYDUnderlyingErrorsKey] should contain(childMapperError2);
            });

            it(@"should return a parsed object", ^{
                expectedPerson.firstName = @"James";
                expectedPerson.identifier = 1;
                parsedObject should equal(expectedPerson);
            });
        });

        context(@"when a field is missing in the provided source object", ^{
            beforeEach(^{
                sourceObject = @{@"age": @23,
                                 @"identifier": @"transforms"};
                childMapper2.objectsToReturn = @[[NSNull null]];
            });

            it(@"should pass nil to the child mappers", ^{
                childMapper2.sourceObjectsReceived should equal(@[[NSNull null]]);
            });

            it(@"should have an error", ^{
                error should be_a_fatal_error.with_code(HYDErrorMultipleErrors);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when the source object is nil", ^{
            beforeEach(^{
                sourceObject = nil;
            });

            it(@"should not have a parse error", ^{
                error should be_nil;
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });
    });

    describe(@"reverse mapping", ^{
        __block id<HYDMapper> reverseMapper;
        __block HYDFakeMapper *reverseChildMapper1;
        __block HYDFakeMapper *reverseChildMapper2;

        beforeEach(^{
            reverseChildMapper1 = [[HYDFakeMapper alloc] initWithDestinationKey:@"identifier"];
            reverseChildMapper1.objectsToReturn = @[@"transforms"];
            childMapper1.reverseMapperToReturn = reverseChildMapper1;

            reverseChildMapper2 = [[HYDFakeMapper alloc] initWithDestinationKey:@"first_name"];
            reverseChildMapper2.objectsToReturn = @[@"John"];
            childMapper2.reverseMapperToReturn = reverseChildMapper2;

            reverseMapper = [mapper reverseMapperWithDestinationAccessor:HYDAccessKey(@"otherKey")];
        });

        it(@"should set the reverse mapper's destinationAccessor", ^{
            reverseMapper.destinationAccessor should equal(HYDAccessKey(@"otherKey"));
        });

        it(@"should produce the original mapper's source object", ^{
            id result = [reverseMapper objectFromSourceObject:expectedPerson error:&error];
            result should be_instance_of([NSDictionary class]).or_any_subclass();
            error should be_nil;
        });

        it(@"should be the inverse of the original mapper", ^{
            id result = [mapper objectFromSourceObject:validSourceObject error:&error];
            error should be_nil;
            id derivedSource = [reverseMapper objectFromSourceObject:result error:&error];
            derivedSource should equal(validSourceObject);
            error should be_nil;
        });
    });
});

SPEC_END
