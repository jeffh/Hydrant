#import "JKSDateMapper.h"

@interface JKSDateMapper ()
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation JKSDateMapper

- (id)initWithDestinationKey:(NSString *)destinationKey dateFormatter:(NSDateFormatter *)dateFormatter
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.dateFormatter = dateFormatter;
    }
    return self;
}

- (id)objectFromSourceObject:(id)sourceObject serializer:(id<JKSSerializer>)serializer
{
    if (self.convertsToString){
        return [self.dateFormatter stringFromDate:sourceObject];
    } else {
        return [self.dateFormatter dateFromString:sourceObject];
    }
}

- (instancetype)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    JKSDateMapper *reversedMapper = [[JKSDateMapper alloc] initWithDestinationKey:destinationKey dateFormatter:self.dateFormatter];
    reversedMapper.convertsToString = !self.convertsToString;
    return reversedMapper;
}

@end


JKSDateMapper* JKSDate(NSString *dstKey, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    return [[JKSDateMapper alloc] initWithDestinationKey:dstKey dateFormatter:dateFormatter];
}