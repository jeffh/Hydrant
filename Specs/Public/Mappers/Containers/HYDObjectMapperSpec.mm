#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSPerson.h"
#import "HYDSFakeMapper.h"
#import "HYDSFakeAccessor.h"
#import "HYDError+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDObjectMapperSpec)

describe(@"HYDObjectMapper", ^{
    __block HYDObjectMapper *mapper;
    __block HYDError *error;
    __block HYDSPerson *expectedPerson;
    __block NSDictionary *validSourceObject;
    __block id sourceObject;
    __block id parsedObject;
    __block HYDSFakeMapper *childMapper1;
    __block HYDSFakeMapper *childMapper2;
    __block HYDSFakeMapper *innerMapper;
    __block HYDSFakeAccessor *fakeGetter;
    __block HYDSFakeAccessor *fakeSetter;

    beforeEach(^{
        fakeGetter = [[HYDSFakeAccessor alloc] init];
        fakeGetter.valuesToReturn = @[@23];
        fakeGetter.fieldNames = @[@"age"];

        fakeSetter = [[HYDSFakeAccessor alloc] init];
        fakeSetter.fieldNames = @[@"age"];

        expectedPerson = [[HYDSPerson alloc] initWithFixtureData];
        expectedPerson.fullName = @[@"John", @"James", @"Doe"];
        validSourceObject = @{@"identifier": @"transforms",
                              @"first_name": @"John",
                              @"last_name": @"Doe",
                              @"middle_name": @"James",
                              @"age": @23};

        innerMapper = [[HYDSFakeMapper alloc] init];
        childMapper1 = [[HYDSFakeMapper alloc] init];
        childMapper1.objectsToReturn = @[@5];
        childMapper2 = [[HYDSFakeMapper alloc] init];
        childMapper2.objectsToReturn = @[@"John"];

        mapper = HYDMapKVCObject(innerMapper, [NSDictionary class], [HYDSPerson class],
                                 @{@"first_name" : @[childMapper2, @"firstName"],
                                   @"last_name" : @"lastName",
                                   @[@"first_name", @"middle_name", @"last_name"]: @"fullName",
                                   fakeGetter : @[HYDMapIdentity(), fakeSetter],
                                   @"identifier" : HYDMap(childMapper1, @"identifier")});
    });

    describe(@"parsing the source object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject
                                                    error:&error];
        });

        context(@"when a valid source object is given", ^{
            beforeEach(^{
                sourceObject = @1;
                innerMapper.objectsToReturn = @[validSourceObject];
            });

            it(@"should not have any error", ^{
                error should be_nil;
            });

            it(@"should use the custom set accessor", ^{
                fakeSetter.valuesToSetReceived should equal(@[@23]);
            });

            it(@"should produce an instance of the class given", ^{
                parsedObject should be_instance_of([HYDSPerson class]);
            });

            it(@"should set all the properties on the parsed object based on the mapping provided", ^{
                parsedObject should equal(expectedPerson);
            });
        });

        context(@"when the inner child mapper returns a nonfatal error", ^{
            beforeEach(^{
                sourceObject = @1;
                innerMapper.errorsToReturn = @[[HYDError nonFatalError]];
            });

            it(@"should return the error", ^{
                error should equal([HYDError nonFatalError]);
            });
        });

        context(@"when a NSNull is given", ^{
            beforeEach(^{
                sourceObject = @1;
                NSDictionary *object = @{@"first_name": @"John",
                                         @"last_name": [NSNull null],
                                         @"middle_name": @"James",
                                         @"age": @23,
                                         @"identifier": @"transforms"};
                innerMapper.objectsToReturn = @[object];
            });

            it(@"should not have any error", ^{
                error should be_nil;
            });

            it(@"should produce an instance of the class given", ^{
                parsedObject should be_instance_of([HYDSPerson class]);
            });

            it(@"should set all the properties on the parsed object based on the mapping provided", ^{
                HYDSPerson *personWithOutLastName = [[HYDSPerson alloc] initWithFixtureData];
                personWithOutLastName.lastName = nil;
                personWithOutLastName.fullName = @[@"John", @"James", [NSNull null]];
                parsedObject should equal(personWithOutLastName);
            });
        });

        context(@"when the getter accessor fails", ^{
            beforeEach(^{
                sourceObject = @1;
                innerMapper.objectsToReturn = @[validSourceObject];
                fakeGetter.sourceErrorToReturn = [HYDError errorWithCode:HYDErrorGetViaAccessorFailed
                                                            sourceObject:sourceObject
                                                          sourceAccessor:fakeGetter
                                                       destinationObject:nil
                                                     destinationAccessor:fakeSetter
                                                                 isFatal:YES
                                                        underlyingErrors:nil];
            });

            it(@"should return the setter error", ^{
                error should be_a_fatal_error.with_code(HYDErrorMultipleErrors);
                error.userInfo[HYDUnderlyingErrorsKey] should equal(@[fakeGetter.sourceErrorToReturn]);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when the setter accessor fails", ^{
            beforeEach(^{
                sourceObject = @1;
                innerMapper.objectsToReturn = @[validSourceObject];
                fakeSetter.setValuesErrorToReturn = [HYDError errorWithCode:HYDErrorSetViaAccessorFailed
                                                               sourceObject:validSourceObject
                                                             sourceAccessor:fakeGetter
                                                          destinationObject:@23
                                                        destinationAccessor:fakeSetter
                                                                    isFatal:YES
                                                           underlyingErrors:nil];
            });

            it(@"should return the setter error", ^{
                error should be_a_fatal_error.with_code(HYDErrorMultipleErrors);
                error.userInfo[HYDUnderlyingErrorsKey] should equal(@[fakeSetter.setValuesErrorToReturn]);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when the inner child mapper returns a fatal error", ^{
            beforeEach(^{
                sourceObject = @1;
                innerMapper.errorsToReturn = @[[HYDError fatalError]];
            });

            it(@"should return the error", ^{
                error should equal([HYDError fatalError]);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when child mappers returns fatal errors", ^{
            __block HYDError *childMapperError1;
            __block HYDError *childMapperError2;

            beforeEach(^{
                sourceObject = validSourceObject;
                innerMapper.objectsToReturn = @[validSourceObject];
                childMapperError1 = [HYDError fatalError];
                childMapperError2 = [HYDError fatalError];
                childMapper1.objectsToReturn = nil;
                childMapper1.errorsToReturn = @[childMapperError1];
                childMapper2.objectsToReturn = nil;
                childMapper2.errorsToReturn = @[childMapperError2];

                childMapperError1 = [HYDError errorFromError:childMapperError1
                                    prependingSourceAccessor:HYDAccessKey(@"identifier")
                                      andDestinationAccessor:HYDAccessKey(@"identifier")
                                     replacementSourceObject:@"transforms"
                                                     isFatal:YES];
                childMapperError2 = [HYDError errorFromError:childMapperError2
                                    prependingSourceAccessor:HYDAccessKey(@"first_name")
                                      andDestinationAccessor:HYDAccessKey(@"firstName")
                                     replacementSourceObject:@"John"
                                                     isFatal:YES];
            });

            it(@"should wrap all the emitted errors in a fatal error", ^{
                error should be_a_fatal_error.with_code(HYDErrorMultipleErrors);
                [error.userInfo[HYDUnderlyingErrorsKey] count] should equal(2);
                error.userInfo[HYDUnderlyingErrorsKey] should contain(childMapperError1);
                error.userInfo[HYDUnderlyingErrorsKey] should contain(childMapperError2);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when child mappers returns non-fatal errors", ^{
            __block HYDError *childMapperError1;
            __block HYDError *childMapperError2;

            beforeEach(^{
                sourceObject = @1;
                innerMapper.objectsToReturn = @[validSourceObject];
                childMapperError1 = [HYDError nonFatalError];
                childMapperError2 = [HYDError nonFatalError];
                childMapper1.objectsToReturn = @[@1];
                childMapper1.errorsToReturn = @[childMapperError1];
                childMapper2.objectsToReturn = @[@"James"];
                childMapper2.errorsToReturn = @[childMapperError2];

                childMapperError1 = [HYDError errorFromError:childMapperError1
                                    prependingSourceAccessor:HYDAccessKey(@"identifier")
                                      andDestinationAccessor:HYDAccessKey(@"identifier")
                                     replacementSourceObject:@"transforms"
                                                     isFatal:NO];
                childMapperError2 = [HYDError errorFromError:childMapperError2
                                    prependingSourceAccessor:HYDAccessKey(@"first_name")
                                      andDestinationAccessor:HYDAccessKey(@"firstName")
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
                sourceObject = @1;
                innerMapper.objectsToReturn = @[@{@"age": @23,
                                                  @"identifier": @"transforms"}];
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
        __block HYDSFakeMapper *reverseChildMapper1;
        __block HYDSFakeMapper *reverseChildMapper2;

        beforeEach(^{
            innerMapper.objectsToReturn = @[validSourceObject];
            innerMapper.reverseMapperToReturn = HYDMapIdentity();

            reverseChildMapper1 = [[HYDSFakeMapper alloc] init];
            reverseChildMapper1.objectsToReturn = @[@"transforms"];
            childMapper1.reverseMapperToReturn = reverseChildMapper1;

            reverseChildMapper2 = [[HYDSFakeMapper alloc] init];
            reverseChildMapper2.objectsToReturn = @[@"John"];
            childMapper2.reverseMapperToReturn = reverseChildMapper2;

            reverseMapper = [mapper reverseMapper];

            fakeSetter.valuesToReturn = @[@23];
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
