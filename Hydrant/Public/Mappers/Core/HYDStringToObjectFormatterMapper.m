#import "HYDStringToObjectFormatterMapper.h"
#import "HYDError.h"
#import "HYDFunctions.h"
#import "HYDObjectToStringFormatterMapper.h"
#import "HYDIdentityMapper.h"
#import "HYDThreadMapper.h"


@interface HYDStringToObjectFormatterMapper : NSObject <HYDMapper>

@property (strong, nonatomic) NSFormatter *formatter;

- (id)initWithFormatter:(NSFormatter *)formatter;

@end


@implementation HYDStringToObjectFormatterMapper

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


#pragma mark - HYDMapper

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    BOOL success = NO;
    id resultingObject = nil;
    NSString *errorDescription = nil;

    if ([sourceObject isKindOfClass:[NSString class]]) {
        success = [self.formatter getObjectValue:&resultingObject
                                       forString:sourceObject
                                errorDescription:&errorDescription];
    }

    if (success) {
        HYDSetObjectPointer(error, nil);
    } else {
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
    return HYDMapObjectToStringByFormatter(self.formatter);
}

@end

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToObjectByFormatter(NSFormatter *formatter)
{
    return [[HYDStringToObjectFormatterMapper alloc] initWithFormatter:formatter];
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToObjectByFormatter(id<HYDMapper> innerMapper, NSFormatter *formatter)
{
    return HYDMapThread(innerMapper, HYDMapStringToObjectByFormatter(formatter));
}
