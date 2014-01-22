// DO NOT any other library headers here to simulate an API user.
#import "JOM.h"
#import "JOMPerson.h"
#import "JOMFakeMapper.h"
#import "JOMError+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JOMKeyValueMapperSpec)

describe(@"JOMKeyValueMapper", ^{
    __block JOMKeyValueMapper *mapper;
    __block JOMError *error;
    __block JOMPerson *expectedPerson;
    __block NSDictionary *validSourceObject;
    __block id sourceObject;
    __block id parsedObject;
    __block JOMFakeMapper *childMapper1;
    __block JOMFakeMapper *childMapper2;

    beforeEach(^{
        expectedPerson = [[JOMPerson alloc] initWithFixtureData];
        validSourceObject = @{@"first_name": @"John",
                              @"last_name": @"Doe",
                              @"age": @23,
                              @"identifier": @"transforms"};

        childMapper1 = [[JOMFakeMapper alloc] initWithDestinationKey:@"identifier"];
        childMapper1.objectsToReturn = @[@5];
        childMapper2 = [[JOMFakeMapper alloc] initWithDestinationKey:@"firstName"];
        childMapper2.objectsToReturn = @[@"John"];

        mapper = JOMMapObject(@"destinationKey",
                [NSDictionary class],
                [JOMPerson class],
                @{@"first_name" : childMapper2,
                        @"last_name" : @"lastName",
                        @"age" : @"age",
                        @"identifier" : childMapper1});
    });

    it(@"should return the same destination key it was provided", ^{
        mapper.destinationKey should equal(@"destinationKey");
    });

    describe(@"parsing the source object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"as the root mapper", ^{
            context(@"when a valid source object is given", ^{
                beforeEach(^{
                    sourceObject = validSourceObject;
                });

                it(@"should setup child mappers with itself as the root mapper", ^{
                    childMapper1.rootMapperReceived should be_same_instance_as(mapper);
                    childMapper1.factoryReceived should conform_to(@protocol(JOMFactory));
                    childMapper2.rootMapperReceived should be_same_instance_as(mapper);
                    childMapper2.factoryReceived should conform_to(@protocol(JOMFactory));
                });

                it(@"should not have any error", ^{
                    error should be_nil;
                });

                it(@"should produce an instance of the class given", ^{
                    parsedObject should be_instance_of([JOMPerson class]);
                });

                it(@"should set all the properties on the parsed object based on the mapping provided", ^{
                    parsedObject should equal(expectedPerson);
                });
            });

            context(@"when child mappers returns fatal errors", ^{
                __block JOMError *childMapperError1;
                __block JOMError *childMapperError2;

                beforeEach(^{
                    childMapperError1 = [JOMError fatalError];
                    childMapperError2 = [JOMError fatalError];
                    childMapper1.objectsToReturn = nil;
                    childMapper1.errorsToReturn = @[childMapperError1];
                    childMapper2.objectsToReturn = nil;
                    childMapper2.errorsToReturn = @[childMapperError2];

                    childMapperError1 = [JOMError errorFromError:childMapperError1
                                             prependingSourceKey:@"identifier"
                                               andDestinationKey:nil
                                         replacementSourceObject:@"transforms"
                                                         isFatal:YES];
                    childMapperError2 = [JOMError errorFromError:childMapperError2
                                             prependingSourceKey:@"first_name"
                                               andDestinationKey:nil
                                         replacementSourceObject:@"John"
                                                         isFatal:YES];
                });

                it(@"should wrap all the emitted errors in a fatal error", ^{
                    error should be_a_fatal_error().with_code(JOMErrorMultipleErrors);
                    [error.userInfo[JOMUnderlyingErrorsKey] count] should equal(2);
                    error.userInfo[JOMUnderlyingErrorsKey] should contain(childMapperError1);
                    error.userInfo[JOMUnderlyingErrorsKey] should contain(childMapperError2);
                });
            });

            context(@"when child mappers returns non-fatal errors", ^{
                __block JOMError *childMapperError1;
                __block JOMError *childMapperError2;

                beforeEach(^{
                    childMapperError1 = [JOMError nonFatalError];
                    childMapperError2 = [JOMError nonFatalError];
                    childMapper1.objectsToReturn = nil;
                    childMapper1.errorsToReturn = @[childMapperError1];
                    childMapper2.objectsToReturn = nil;
                    childMapper2.errorsToReturn = @[childMapperError2];

                    childMapperError1 = [JOMError errorFromError:childMapperError1
                                             prependingSourceKey:@"identifier"
                                               andDestinationKey:nil
                                         replacementSourceObject:@"transforms"
                                                         isFatal:NO];
                    childMapperError2 = [JOMError errorFromError:childMapperError2
                                             prependingSourceKey:@"first_name"
                                               andDestinationKey:nil
                                         replacementSourceObject:@"John"
                                                         isFatal:NO];
                });

                it(@"should wrap all the emitted errors in a non-fatal error", ^{
                    error should be_a_non_fatal_error().with_code(JOMErrorMultipleErrors);
                    [error.userInfo[JOMUnderlyingErrorsKey] count] should equal(2);
                    error.userInfo[JOMUnderlyingErrorsKey] should contain(childMapperError1);
                    error.userInfo[JOMUnderlyingErrorsKey] should contain(childMapperError2);
                });

                it(@"should return a parsed object", ^{
                    expectedPerson.firstName = nil;
                    expectedPerson.identifier = nil;
                    parsedObject should equal(expectedPerson);
                });
            });

            context(@"when a field is missing in the provided source object", ^{
                beforeEach(^{
                    sourceObject = @{@"first_name": @"John",
                                     @"age": @23,
                                     @"id": @5};
                });

                it(@"should have a fatal error", ^{
                    error should be_a_fatal_error().with_code(JOMErrorMultipleErrors);
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

        context(@"as a child mapper", ^{
            __block id<JOMMapper> parentMapper;
            __block id<JOMFactory> factory;

            beforeEach(^{
                parentMapper = nice_fake_for(@protocol(JOMMapper));
                factory = [[JOMObjectFactory alloc] init];
                [mapper setupAsChildMapperWithMapper:parentMapper factory:factory];
            });

            context(@"when a valid source object is given", ^{
                beforeEach(^{
                    sourceObject = validSourceObject;
                });

                it(@"should propagate the mapping to its children", ^{
                    childMapper1.rootMapperReceived should be_same_instance_as(parentMapper);
                    childMapper1.factoryReceived should be_same_instance_as(factory);
                });

                it(@"should not have any error", ^{
                    error should be_nil;
                });

                it(@"should produce an instance of the class given", ^{
                    parsedObject should be_instance_of([JOMPerson class]);
                });

                it(@"should set all the properties on the parsed object based on the mapping provided", ^{
                    parsedObject should equal(expectedPerson);
                });
            });

            context(@"when a field is missing in the provided source object", ^{
                beforeEach(^{
                    sourceObject = @{@"first_name" : @"John",
                            @"age" : @23,
                            @"id" : @5};
                });

                it(@"should have a parse error", ^{
                    error should_not be_nil;
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
    });

    describe(@"reverse mapping", ^{
        __block id<JOMMapper> reverseMapper;
        __block JOMFakeMapper *reverseChildMapper1;
        __block JOMFakeMapper *reverseChildMapper2;

        beforeEach(^{
            reverseChildMapper1 = [[JOMFakeMapper alloc] initWithDestinationKey:@"identifier"];
            reverseChildMapper1.objectsToReturn = @[@"transforms"];
            childMapper1.reverseMapperToReturn = reverseChildMapper1;

            reverseChildMapper2 = [[JOMFakeMapper alloc] initWithDestinationKey:@"first_name"];
            reverseChildMapper2.objectsToReturn = @[@"John"];
            childMapper2.reverseMapperToReturn = reverseChildMapper2;

            reverseMapper = [mapper reverseMapperWithDestinationKey:@"otherKey"];
        });

        it(@"should set the reverse mapper's destinationKey", ^{
            reverseMapper.destinationKey should equal(@"otherKey");
        });

        it(@"should produce the original mapper's source object", ^{
            id result = [reverseMapper objectFromSourceObject:expectedPerson
                                                        error:&error];
            result should be_instance_of([NSDictionary class]).or_any_subclass();
            error should be_nil;
        });

        it(@"should be the inverse of the original mapper", ^{
            id result = [mapper objectFromSourceObject:validSourceObject
                                                 error:&error];
            error should be_nil;
            id derivedSource = [reverseMapper objectFromSourceObject:result error:&error];
            derivedSource should equal(validSourceObject);
            error should be_nil;
        });
    });
});

SPEC_END
