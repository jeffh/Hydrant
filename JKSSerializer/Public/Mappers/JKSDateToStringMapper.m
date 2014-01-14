#import "JKSDateToStringMapper.h"
#import "JKSError.h"
#import "JKSStringToDateMapper.h"

@interface JKSDateToStringMapper ()
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation JKSDateToStringMapper

#pragma mark - <JKSMapper>

- (id)initWithDestinationKey:(NSString *)destinationKey dateFormatter:(NSDateFormatter *)dateFormatter
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.dateFormatter = dateFormatter;
    }
    return self;
}

- (id)objectFromSourceObject:(id)sourceObject error:(NSError *__autoreleasing *)error
{
    id value = [self.dateFormatter stringFromDate:sourceObject];

    if (!value && sourceObject) {
        *error = [JKSError mappingErrorWithCode:JKSErrorInvalidSourceObjectValue
                                   sourceObject:sourceObject
                                       byMapper:self];
    }
    return value;
}

- (id)objectFromSourceObject:(id)sourceObject toClass:(Class)dstClass error:(NSError *__autoreleasing *)error
{
    id value = [self objectFromSourceObject:sourceObject error:error];
    if (*error) {
        return nil;
    }

    if (value && ![[value class] isSubclassOfClass:dstClass]) {
        *error = [JKSError mappingErrorWithCode:JKSErrorInvalidResultingObjectType
                                   sourceObject:sourceObject
                                       byMapper:self];
        return nil;
    }
    return value;
}

- (void)setupAsChildMapperWithMapper:(id<JKSMapper>)mapper factory:(id<JKSFactory>)factory
{
}

- (id<JKSMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[JKSStringToDateMapper alloc] initWithDestinationKey:destinationKey dateFormatter:self.dateFormatter];
}

@end


JKSDateToStringMapper *JKSDateToString(NSString *dstKey, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    return [[JKSDateToStringMapper alloc] initWithDestinationKey:dstKey dateFormatter:dateFormatter];
}