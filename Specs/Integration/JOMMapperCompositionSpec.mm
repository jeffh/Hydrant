// DO NOT any other library headers here to simulate an API user.
#import "JOM.h"
#import "JOMPerson.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JOMMapperCompositionSpec)

describe(@"Mapper Composition", ^{
    __block id<JOMMapper> mapper;
    __block JOMPerson *expectedObjectGraph;
    __block NSDictionary *expectedObjectStructure;
    __block JOMError *error;
    __block id parsedObject;

    beforeEach(^{
        JOMDotNetDateFormatter *dotNetDateFormatter = [[JOMDotNetDateFormatter alloc] init];

        mapper = JOMMapObject(nil, [NSDictionary class], [JOMPerson class],
                @{@"person" : JOMMapObjectPath(@"parent", [NSDictionary class], [JOMPerson class],
                        @{@"id" : @"identifier",
                                @"name.first" : @"firstName",
                                @"name.last" : @"lastName",
                                @"age" : JOMStringToNumber(@"age"),
                                @"birth_date" : JOMStringToDateWithFormatter(@"birthDate", dotNetDateFormatter)}),
                        @"identifier" : JOMOptional(JOMIdentity(@"identifier")),
                        @"gender" : JOMEnum(@"gender", @{@"unknown" : @(JOMPersonGenderUnknown),
                        @"male" : @(JOMPersonGenderMale),
                        @"female" : @(JOMPersonGenderFemale)})});
        expectedObjectStructure = @{@"person": @{@"id": @1,
                                                 @"name": @{@"first": @"John",
                                                            @"last": @"Doe"},
                                                 @"age": @"22",
                                                 @"birth_date": @"/Date(1390186634595)/"},
                                    @"identifier": @42,
                                    @"gender": @"male"};
        expectedObjectGraph = [[JOMPerson alloc] init];
        expectedObjectGraph.identifier = 42;
        expectedObjectGraph.gender = JOMPersonGenderMale;
        expectedObjectGraph.parent = ({
            JOMPerson *parent = [[JOMPerson alloc] init];
            parent.identifier = 1;
            parent.firstName = @"John";
            parent.lastName = @"Doe";
            parent.age = 22;
            parent.birthDate = [NSDate dateWithTimeIntervalSince1970:1390186634.595];
            parent;
        });
    });

    describe(@"mapping from dictionaries to an object graph", ^{
        beforeEach(^{
            parsedObject = [mapper objectFromSourceObject:expectedObjectStructure error:&error];
        });

        it(@"should not error", ^{
            error should be_nil;
        });

        it(@"should build the object graph correctly", ^{
            parsedObject should equal(expectedObjectGraph);
        });
    });

    describe(@"mapping from object graph to dictionaries using the reverse mapper", ^{
        beforeEach(^{
            id<JOMMapper> reverseMapper = [mapper reverseMapperWithDestinationKey:nil];
            parsedObject = [reverseMapper objectFromSourceObject:expectedObjectGraph error:&error];
        });

        it(@"should not error", ^{
            error should be_nil;
        });

        it(@"should build the json correctly", ^{
            parsedObject should equal(expectedObjectStructure);
        });
    });
    
});

SPEC_END
