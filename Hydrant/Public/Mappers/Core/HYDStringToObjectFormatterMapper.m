#import "HYDStringToObjectFormatterMapper.h"
#import "HYDError.h"
#import "HYDFunctions.h"
#import "HYDObjectToStringFormatterMapper.h"
#import "HYDURLFormatter.h"
#import "HYDUUIDFormatter.h"
#import "HYDKeyAccessor.h"
#import "HYDIdentityMapper.h"


@interface HYDStringToObjectFormatterMapper : NSObject <HYDMapper>

@property (strong, nonatomic) id<HYDMapper> innerMapper;
@property (strong, nonatomic) NSFormatter *formatter;

- (id)initWithMapper:(id<HYDMapper>)mapper formatter:(NSFormatter *)formatter;

@end


@implementation HYDStringToObjectFormatterMapper

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


#pragma mark - HYDMapper

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    HYDError *err = nil;

    sourceObject = [self.innerMapper objectFromSourceObject:sourceObject error:&err];
    HYDSetObjectPointer(error, err);
    if ([err isFatal]) {
        return nil;
    }

    BOOL success = NO;
    id resultingObject = nil;
    NSString *errorDescription = nil;

    if ([sourceObject isKindOfClass:[NSString class]]) {
        success = [self.formatter getObjectValue:&resultingObject
                                       forString:sourceObject
                                errorDescription:&errorDescription];
    }

    if (!success) {
        if (!errorDescription) {
            errorDescription = HYDLocalizedStringFormat(@"Failed to format string into object: %@",
                                                        sourceObject);
        }

        NSError *originalError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                     code:NSFormattingError
                                                 userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
        HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorInvalidSourceObjectValue
                                              sourceObject:sourceObject
                                            sourceAccessor:nil
                                         destinationObject:nil
                                       destinationAccessor:nil
                                                   isFatal:YES
                                          underlyingErrors:@[originalError]]);
        resultingObject = nil;
    }
    return resultingObject;
}

- (id<HYDMapper>)reverseMapper
{
    id<HYDMapper> reverseInnerMapper = [self.innerMapper reverseMapper];
    return HYDMapObjectToStringByFormatter(reverseInnerMapper, self.formatter);
}

@end

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToObjectByFormatter(NSFormatter *formatter)
{
    return HYDMapStringToObjectByFormatter(HYDMapIdentity(), formatter);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToObjectByFormatter(id<HYDMapper> mapper, NSFormatter *formatter)
{
    return [[HYDStringToObjectFormatterMapper alloc] initWithMapper:mapper formatter:formatter];
}
