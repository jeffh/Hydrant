// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSPerson.h"
#import "HYDSFakeAccesor.h"
#import "HYDSFakeMapper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDReflectiveMapperSpec)

describe(@"HYDReflectiveMapper", ^{
    __block HYDReflectiveMapper *mapper;
    __block HYDSFakeAccesor *fakeAccessor;
    __block HYDSFakeMapper *childMapper1;
    __block HYDSFakeMapper *childMapper2;
    __block HYDSPerson *expectedPerson;
    __block NSDictionary *validSourceObject;

    beforeEach(^{
        fakeAccessor = [[HYDSFakeAccesor alloc] init];
        fakeAccessor.valuesToReturn = @[@23];
        fakeAccessor.fieldNames = @[@"age"];

        expectedPerson = [[HYDSPerson alloc] initWithFixtureData];
        expectedPerson.birthDate = [NSDate dateWithTimeIntervalSince1970:140645];
        expectedPerson.homepage = [NSURL URLWithString:@"http://google.com"];
        validSourceObject = @{@"identifier": @"transforms",
                              @"first_name": @"John",
                              @"last_name": @"Doe",
                              @"age": @23,
                              @"birth_date": @"1970-01-02T15:04:05Z",
                              @"homepage": @"http://google.com",
                              @"siblings": @[], // never gets parsed since keyTransform doesn't specify it
                              @"parent": @{}};

        childMapper1 = [[HYDSFakeMapper alloc] initWithDestinationKey:@"identifier"];
        childMapper1.objectsToReturn = @[@5];
        childMapper2 = [[HYDSFakeMapper alloc] initWithDestinationKey:@"firstName"];
        childMapper2.objectsToReturn = @[@"John"];

        mapper = ({
            HYDMapReflectively(@"someKey", [HYDSPerson class])
            .optional(@[@"birthDate", @"homepage", @"siblings"])
            .excluding(@[@"parent"])
            .overriding(@{@"first_name": childMapper2,
                          fakeAccessor: @"age",
                          @"identifier": childMapper1})
            .keyTransform(^(NSString *property){
                NSDictionary *mapping = @{@"lastName": @"last_name",
                                          @"homepage": @"homepage",
                                          @"birthDate": @"birth_date",
                                          @"parent": @"parent"};
                return mapping[property];
            });
        });
    });

    it(@"should return the same destination key it was provided", ^{
        [mapper destinationAccessor] should equal(HYDAccessDefault(@"someKey"));
    });

    describe(@"parsing a source object", ^{
        __block id parsedObject;
        __block id sourceObject;
        __block HYDError *error;

        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when the source object is valid without any missing fields", ^{
            beforeEach(^{
                sourceObject = validSourceObject;
            });

            it(@"should parse the object into a valid person", ^{
                parsedObject should equal(expectedPerson);
            });

            it(@"should not return an error", ^{
                error should be_nil;
            });
        });

        context(@"when the source object is missing required fields", ^{
            beforeEach(^{
                sourceObject = @{};
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should return a fatal error", ^{
                error should be_a_fatal_error.with_code(HYDErrorMultipleErrors);
            });
        });

        context(@"when the source object is missing optional fields", ^{
            beforeEach(^{
                NSMutableDictionary *source = [validSourceObject mutableCopy];
                [source removeObjectForKey:@"homepage"];
                sourceObject = source;

                expectedPerson.homepage = nil;
            });

            it(@"should parse the object into a valid person", ^{
                parsedObject should equal(expectedPerson);
            });

            it(@"should not return a fatal error", ^{
                error should be_a_non_fatal_error.with_code(HYDErrorMultipleErrors);
            });
        });

        context(@"when the source object is an incorrect type", ^{
            beforeEach(^{
                sourceObject = @"No Beef here";
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should return a fatal type error", ^{
                error should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectType);
            });
        });
    });

    describe(@"reverse mapping", ^{
    });
});

SPEC_END
