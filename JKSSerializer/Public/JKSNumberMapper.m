#import "JKSNumberMapper.h"

@interface JKSNumberMapper ()
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@end

@implementation JKSNumberMapper

- (id)initWithDestinationKey:(NSString *)destinationKey numberFormatter:(NSNumberFormatter *)numberFormatter
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.numberFormatter = numberFormatter;
    }
    return self;
}

- (id)objectFromSourceObject:(id)sourceObject serializer:(id<JKSSerializer>)serializer
{
    if (self.convertsToString) {
        return [self.numberFormatter stringFromNumber:sourceObject];
    } else {
        return [self.numberFormatter numberFromString:sourceObject];
    }
}

- (id<JKSMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    JKSNumberMapper *reverseMapper = [[JKSNumberMapper alloc] initWithDestinationKey:destinationKey numberFormatter:self.numberFormatter];
    reverseMapper.convertsToString = !reverseMapper.convertsToString;
    return reverseMapper;
}

@end


JKS_EXTERN
JKSNumberMapper* JKSNumberStyle(NSString *destKey, NSNumberFormatterStyle numberFormatStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormatStyle;
    return [[JKSNumberMapper alloc] initWithDestinationKey:destKey numberFormatter:numberFormatter];
}