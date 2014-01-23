// DO NOT any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDPerson.h"
#import "HYDFakeMapper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDKeyValuePathMapperSpec)

describe(@"HYDKeyValuePathMapper", ^{
    __block HYDKeyValuePathMapper *mapper;
    __block HYDError *error;
    __block HYDPerson *expectedPerson;
    __block NSDictionary *validSourceObject;
    __block id sourceObject;
    __block id parsedObject;
    __block HYDFakeMapper *childMapper;

    beforeEach(^{
        expectedPerson = [[HYDPerson alloc] initWithFixtureData];
        validSourceObject = @{@"name": @{@"first": @"John",
                                         @"last": @"Doe"},
                              @"age": @23,
                              @"identifier": @"transforms"};

        childMapper = [[HYDFakeMapper alloc] initWithDestinationKey:@"identifier"];
        childMapper.objectsToReturn = @[@5];

        mapper = HYDMapObjectPath(@"destinationKey",
                [NSDictionary class],
                [HYDPerson class],
                @{@"name.first" : @"firstName",
                        @"name.last" : @"lastName",
                        @"age" : @"age",
                        @"identifier" : childMapper});
    });

    it(@"should return the same destination key it was provided", ^{
        mapper.destinationKey should equal(@"destinationKey");
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

        context(@"when a field is missing in the provided source object", ^{
            beforeEach(^{
                sourceObject = @{@"first_name": @"John",
                        @"age": @23,
                        @"id": @5};
            });

            it(@"should have a fatal error", ^{
                error should be_a_fatal_error().with_code(HYDErrorMultipleErrors);
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
        __block HYDFakeMapper *reverseChildMapper;

        beforeEach(^{
            reverseChildMapper = [[HYDFakeMapper alloc] initWithDestinationKey:@"identifier"];
            childMapper.reverseMapperToReturn = reverseChildMapper;
            reverseChildMapper.objectsToReturn = @[@"transforms"];

            reverseMapper = [mapper reverseMapperWithDestinationKey:@"otherKey"];
        });

        it(@"should set the reverse mapper's destinationKey", ^{
            reverseMapper.destinationKey should equal(@"otherKey");
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
