// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDMappingOptionalSpec)

describe(@"HYDMappingArraysOptional", ^{
    __block id<HYDMapper> mapper;
    __block HYDError *error;
    __block id sourceObject;

    beforeEach(^{
        mapper = HYDMapArrayOf(HYDMapObjectPath(HYDRootMapper, [NSDictionary class], [NSDictionary class],
                                                @{@"Color": @"name",
                                                  @"Url": HYDMapStringToURL(@"previewImageURL"),
                                                  @"ZoomImageUrl": HYDMapOptionally(HYDMapStringToURL(@"zoomImageURL"))}));
        sourceObject = @[@{@"Url": @"http://google.com/cats.jpeg",
                           @"Color": @"BLACK"}];
    });

    describe(@"mapping", ^{
        it(@"should work", ^{
            id resultingObject = [mapper objectFromSourceObject:sourceObject error:&error];
            resultingObject should equal(@[@{@"name": @"BLACK",
                                             @"previewImageURL": [NSURL URLWithString:@"http://google.com/cats.jpeg"]}]);
        });
    });
});

SPEC_END
