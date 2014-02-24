// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDError+Spec.h"
#import "HYDSFakeMapper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDTypedMapperSpec)

describe(@"HYDTypedMapper", ^{
    __block HYDTypedMapper *mapper;
    __block HYDSFakeMapper *innerMapper;
    __block HYDError *error;
    __block id sourceObject;
    __block id parsedObject;

    beforeEach(^{
        error = nil;
        sourceObject = @"SOURCE";
        innerMapper = [[HYDSFakeMapper alloc] initWithDestinationKey:@"mah-key"];

        mapper = HYDMapTypes(innerMapper,
                @[[NSString class], [NSArray class]],
                @[[NSNumber class], [NSArray class]]);
    });

    it(@"should pass through to the inner mapper for the destination key", ^{
        mapper.destinationAccessor should equal(HYDAccessDefault(@"mah-key"));
    });

    describe(@"parsing an object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when the expected class is nil", ^{
            beforeEach(^{
                sourceObject = [NSString string];
                innerMapper.objectsToReturn = @[@[@1]];
                mapper = HYDMapTypes(innerMapper, nil, nil);
            });

            it(@"should not error", ^{
                error should be_nil;
            });

            it(@"should return the inner mapper's value", ^{
                parsedObject should equal(@[@1]);
            });
        });

        context(@"when the type is a subclass", ^{
            beforeEach(^{
                sourceObject = [NSMutableArray array];
                innerMapper.objectsToReturn = @[@[@1]];
            });

            it(@"should not error", ^{
                error should be_nil;
            });

            it(@"should return the inner mapper's value", ^{
                parsedObject should equal(@[@1]);
            });
        });

        context(@"when the source object is invalid type for the inner mapper", ^{
            beforeEach(^{
                sourceObject = @2;
            });

            it(@"should not invoke the inner mapper", ^{
                innerMapper.sourceObjectsReceived should be_empty;
            });

            it(@"should produce a fatal type error", ^{
                error should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectType);
            });
        });

        context(@"when the object is valid to the inner mapper and is the correct type", ^{
            beforeEach(^{
                innerMapper.objectsToReturn = @[@1];
            });

            it(@"should not error", ^{
                error should be_nil;
            });

            it(@"should return the object the inner mapper returned", ^{
                parsedObject should equal(@1);
            });
        });

        context(@"when the inner mapper returns nil from a nil source object", ^{
            beforeEach(^{
                innerMapper.objectsToReturn = @[[NSNull null]];
            });

            it(@"should not error", ^{
                error should be_nil;
            });

            it(@"should return the object the inner mapper returned", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when the object is valid to the inner mapper but is the incorrect return type", ^{
            beforeEach(^{
                sourceObject = nil;
                innerMapper.objectsToReturn = @[@"Cheese"];
            });

            it(@"should produce a fatal error with invalid return type", ^{
                error should be_a_fatal_error.with_code(HYDErrorInvalidResultingObjectType);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when the object causes a fatal error to the inner mapper", ^{
            __block NSError *innerMapperError;
            beforeEach(^{
                innerMapperError = [HYDError fatalError];
                innerMapper.errorsToReturn = @[innerMapperError];
            });

            it(@"should bubble up the error", ^{
                error should be_same_instance_as(innerMapperError);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when the object causes a non-fatal error to the inner mapper with the correct return type", ^{
            __block NSError *innerMapperError;
            beforeEach(^{
                innerMapperError = [HYDError nonFatalError];
                innerMapper.objectsToReturn = @[@[@1]];
                innerMapper.errorsToReturn = @[innerMapperError];
            });

            it(@"should bubble up the error", ^{
                error should be_same_instance_as(innerMapperError);
            });

            it(@"should return the inner mapper's object", ^{
                parsedObject should equal(@[@1]);
            });
        });
    });

    describe(@"errornously parsing an object without an error pointer", ^{
        it(@"should not explode", ^{
            innerMapper.objectsToReturn = @[@"Cheese"];
            [mapper objectFromSourceObject:@[] error:nil];
        });
    });

    describe(@"reverse mapper", ^{
        __block HYDSFakeMapper *innerReverseMapper;
        __block HYDTypedMapper *reverseMapper;

        beforeEach(^{
            innerReverseMapper = [[HYDSFakeMapper alloc] initWithDestinationKey:@"KEY"];
            innerReverseMapper.objectsToReturn = @[sourceObject];
            innerMapper.objectsToReturn = @[@1];
            innerMapper.reverseMapperToReturn = innerReverseMapper;

            reverseMapper = [mapper reverseMapperWithDestinationAccessor:HYDAccessKey(@"KEY")];
        });

        it(@"should pass along the destination key to the inner mapper", ^{
            innerMapper.reverseMapperDestinationAccessorReceived should equal(HYDAccessKey(@"KEY"));
        });

        it(@"should use be reverse-compatible with the current mapper", ^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
            error should be_nil;

            id result = [reverseMapper objectFromSourceObject:parsedObject error:&error];
            error should be_nil;

            result should equal(sourceObject);
        });
    });
});

SPEC_END
