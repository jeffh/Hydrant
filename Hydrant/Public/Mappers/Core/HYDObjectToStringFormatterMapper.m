#import "HYDObjectToStringFormatterMapper.h"
#import "HYDFunctions.h"
#import "HYDError.h"
#import "HYDStringToObjectFormatterMapper.h"
#import "HYDURLFormatter.h"
#import "HYDUUIDFormatter.h"
#import "HYDKeyAccessor.h"
#import "HYDIdentityMapper.h"



@interface HYDObjectToStringFormatterMapper : NSObject <HYDMapper>

@property (strong, nonatomic) NSFormatter *formatter;
@property (strong, nonatomic) id<HYDMapper> innerMapper;

- (id)initWithMapper:(id<HYDMapper>)mapper formatter:(NSFormatter *)formatter;

@end


@implementation HYDObjectToStringFormatterMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithMapper:(id<HYDMapper>)mapper formatter:(NSFormatter *)formatter
{
    self = [super init];
    if (self) {
        self.innerMapper = mapper;
        self.formatter = formatter;
    }
    return self;
}

#pragma mark - <NSObject>

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@ with %@>",
            NSStringFromClass(self.class),
            self.formatter,
            self.innerMapper];
}

#pragma mark - HYDMapper

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    HYDError *err = nil;
    sourceObject = [self.innerMapper objectFromSourceObject:sourceObject error:&err];

    HYDSetObjectPointer(error, err);
    if ([err isFatal]) {
        return nil;
    }

    id resultingObject = nil;
    if (sourceObject) {
        resultingObject = [self.formatter stringForObjectValue:sourceObject];
    }

    if (!resultingObject) {
        HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorInvalidSourceObjectValue
                                              sourceObject:sourceObject
                                            sourceAccessor:nil
                                         destinationObject:nil
                                       destinationAccessor:nil
                                                   isFatal:YES
                                          underlyingErrors:nil]);
    }
    return resultingObject;
}

- (id<HYDMapper>)reverseMapper
{
    id<HYDMapper> reverseInnerMapper = [self.innerMapper reverseMapper];
    return HYDMapStringToObjectByFormatter(reverseInnerMapper, self.formatter);
}

@end


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapObjectToStringByFormatter(NSFormatter *formatter)
{
    return HYDMapObjectToStringByFormatter(HYDMapIdentity(), formatter);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapObjectToStringByFormatter(id<HYDMapper> mapper, NSFormatter *formatter)
{
    return [[HYDObjectToStringFormatterMapper alloc] initWithMapper:mapper formatter:formatter];
}
