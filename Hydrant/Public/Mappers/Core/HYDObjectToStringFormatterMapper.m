#import "HYDObjectToStringFormatterMapper.h"
#import "HYDFunctions.h"
#import "HYDError.h"
#import "HYDStringToObjectFormatterMapper.h"
#import "HYDThreadMapper.h"


@interface HYDObjectToStringFormatterMapper : NSObject <HYDMapper>

@property (strong, nonatomic) NSFormatter *formatter;

- (id)initWithFormatter:(NSFormatter *)formatter;

@end


@implementation HYDObjectToStringFormatterMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithFormatter:(NSFormatter *)formatter
{
    self = [super init];
    if (self) {
        self.formatter = formatter;
    }
    return self;
}

#pragma mark - <NSObject>

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@>",
            NSStringFromClass(self.class),
            self.formatter];
}

#pragma mark - HYDMapper

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    id resultingObject = nil;
    if (sourceObject) {
        resultingObject = [self.formatter stringForObjectValue:sourceObject];
    }

    if (resultingObject) {
        HYDSetObjectPointer(error, nil);
    } else {
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
    return HYDMapStringToObjectByFormatter(self.formatter);
}

@end


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapObjectToStringByFormatter(NSFormatter *formatter)
{
    return [[HYDObjectToStringFormatterMapper alloc] initWithFormatter:formatter];
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapObjectToStringByFormatter(id<HYDMapper> innerMapper, NSFormatter *formatter)
{
    return HYDMapThread(innerMapper, HYDMapObjectToStringByFormatter(formatter));
}
