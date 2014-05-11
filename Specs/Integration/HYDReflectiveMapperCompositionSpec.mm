// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSPerson.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDReflectiveMapperCompositionSpec)

describe(@"HYDReflectiveMapperComposition", ^{
    __block HYDReflectiveMapper *mapper;
    __block HYDReflectiveMapper *parentMapper;
    __block HYDSPerson *expectedObjectGraph;
    __block NSDictionary *expectedObjectStructure;
    __block HYDError *error;
    __block id parsedObject;

    beforeEach(^{
        parentMapper = HYDMapReflectively([HYDSPerson class])
            .keyTransformer([HYDCamelToSnakeCaseValueTransformer new])
            .only(@[@"identifier", @"firstName", @"lastName", @"birthDate"]);

        mapper = HYDMapReflectively([HYDSPerson class])
            .keyTransformer([HYDCamelToSnakeCaseValueTransformer new])
            .except(@[@"fullName", @"firstName", @"lastName", @"birthDate", @"age"])
            .optional(@[@"identifier", @"siblings"])
            .customMapping(@{@"gender": @[HYDMapEnum(@{@"unknown" : @(HYDSPersonGenderUnknown),
                                                       @"male" : @(HYDSPersonGenderMale),
                                                       @"female" : @(HYDSPersonGenderFemale)}),
                                          @"gender"],
                             @"human_age": @[HYDMapStringToDecimalNumber(), @"age"],
                             @"parent": @[parentMapper, @"parent"]});

        expectedObjectStructure = @{@"parent": @{@"identifier": @1,
                                                 @"first_name": @"John",
                                                 @"last_name": @"Doe",
                                                 @"birth_date": @"/Date(1390186634595)/"},
                                    @"income_in_thousands": @(65.5),
                                    @"homepage": @"http://google.com",
                                    @"identifier": @42,
                                    @"human_age": @"12",
                                    @"gender": @"male"};
        expectedObjectGraph = [[HYDSPerson alloc] init];
        expectedObjectGraph.identifier = 42;
        expectedObjectGraph.gender = HYDSPersonGenderMale;
        expectedObjectGraph.homepage = [NSURL URLWithString:@"http://google.com"];
        expectedObjectGraph.age = 12;
        expectedObjectGraph.incomeInThousands = 65.5;
        expectedObjectGraph.parent = ({
            HYDSPerson *parent = [[HYDSPerson alloc] init];
            parent.identifier = 1;
            parent.firstName = @"John";
            parent.lastName = @"Doe";
            parent.birthDate = [NSDate dateWithTimeIntervalSince1970:1390186634.595];
            parent;
        });
    });

    describe(@"mapping from dictionaries to an object graph", ^{
        beforeEach(^{
            parsedObject = [mapper objectFromSourceObject:expectedObjectStructure error:&error];
        });

        it(@"should not produce a fatal error", ^{
            error should be_a_non_fatal_error;
        });

        it(@"should build the object graph correctly", ^{
            parsedObject should equal(expectedObjectGraph);
        });
    });

    describe(@"mapping from object graph to dictionaries using the reverse mapper", ^{
        beforeEach(^{
            parentMapper = parentMapper.customMapping(@{@"birth_date": @[HYDMapStringToDate([HYDDotNetDateFormatter new]), @"birthDate"]});
            mapper = mapper.customMapping(@{@"parent": @[parentMapper, @"parent"]});
            id<HYDMapper> reverseMapper = [mapper reverseMapper];
            parsedObject = [reverseMapper objectFromSourceObject:expectedObjectGraph error:&error];
        });

        it(@"should not fatally error", ^{
            error should_not be_a_fatal_error;
        });

        it(@"should build the json correctly", ^{
            parsedObject should equal(expectedObjectStructure);
        });
    });
});

SPEC_END
