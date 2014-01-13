#import "JKSDateMapper.h"
#import "JKSError.h"

// TODO: convert this class into two classes
// date->string and string->date
@interface JKSDateMapper ()
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation JKSDateMapper

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
    id value = nil;
    if (self.convertsToDate){
        value = [self.dateFormatter dateFromString:[sourceObject description]];
    } else {
        value = [self.dateFormatter stringFromDate:sourceObject];
    }

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

- (instancetype)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    JKSDateMapper *reversedMapper = [[JKSDateMapper alloc] initWithDestinationKey:destinationKey dateFormatter:self.dateFormatter];
    reversedMapper.convertsToDate = !self.convertsToDate;
    return reversedMapper;
}

@end


JKSDateMapper* JKSDate(NSString *dstKey, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    return [[JKSDateMapper alloc] initWithDestinationKey:dstKey dateFormatter:dateFormatter];
}