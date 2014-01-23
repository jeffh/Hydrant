#import "HYDProperty.h"
#import <objc/runtime.h>

@implementation HYDProperty

- (id)initWithName:(NSString *)name attributes:(NSDictionary *)attributes
{
    if (self = [super init]) {
        self.name = name;
        self.attributes = attributes;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ name=%@ attributes=%@>", NSStringFromClass([self class]), self.name, self.attributes];
}

- (NSString *)encodingType
{
    return self.attributes[@"T"];
}

- (NSString *)ivarName
{
    return self.attributes[@"V"];
}

- (NSString *)encodingTypeObjCDeclaration
{
    NSString *encodingType = self.encodingType;
    if (self.isObjCObjectType) {
        if (encodingType.length > 3 &&
            [encodingType characterAtIndex:1] == '"' &&
            [encodingType characterAtIndex:encodingType.length-1] == '"') {
            return [encodingType substringWithRange:NSMakeRange(2, encodingType.length - 3)];
        }
        return @"NSObject";
    }
    return nil;
}

- (Class)classType
{
    if (!self.isObjCObjectType) {
        return nil;
    }
    NSString *declaration = [self encodingTypeObjCDeclaration];
    NSString *className = @"";
    NSRange protocolStart = [declaration rangeOfString:@"<"];
    if (protocolStart.location == NSNotFound){
        className = declaration;
    } else {
        className = [declaration substringToIndex:protocolStart.location];
    }
    return NSClassFromString(className);
}

- (BOOL)isEncodingType:(const char *)encoding
{
    return strcmp(self.encodingType.UTF8String, encoding) == 0;
}

- (BOOL)isObjCObjectType
{
    return [self.encodingType characterAtIndex:0] == '@';
}

- (BOOL)isWeak
{
    return self.attributes[@"W"] != nil;
}

- (BOOL)isNonAtomic
{
    return self.attributes[@"N"] != nil;
}

- (BOOL)isReadOnly
{
    return self.attributes[@"R"] != nil;
}

@end