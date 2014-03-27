#import "HYDProperty.h"
#import <objc/runtime.h>


@interface HYDProperty ()

@property (strong, nonatomic) NSString *encodingType;
@property (strong, nonatomic) NSString *ivarName;
@property (strong, nonatomic) NSString *encodingTypeObjCDeclaration;
@property (strong, nonatomic) Class classType;
@property (assign, nonatomic, getter = isObjCObjectType) BOOL objCObjectType;

@end


@implementation HYDProperty

- (id)initWithName:(NSString *)name attributes:(NSDictionary *)attributes
{
    if (self = [super init]) {
        self.name = name;
        self.attributes = attributes;
        self.encodingType = attributes[@"T"];
        self.ivarName = attributes[@"V"];
        self.objCObjectType = [self.encodingType characterAtIndex:0] == '@';
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ name=%@ attributes=%@>", NSStringFromClass([self class]), self.name, self.attributes];
}

- (NSString *)encodingTypeObjCDeclaration
{
    if (self.isObjCObjectType && !_encodingTypeObjCDeclaration) {
        NSString *encodingType = self.encodingType;
        if (encodingType.length > 3 &&
            [encodingType characterAtIndex:1] == '"' &&
            [encodingType characterAtIndex:encodingType.length-1] == '"') {
            return [encodingType substringWithRange:NSMakeRange(2, encodingType.length - 3)];
        }
        _encodingTypeObjCDeclaration = @"NSObject";
    }
    return _encodingTypeObjCDeclaration;
}

- (Class)classType
{
    if (self.isObjCObjectType && !_classType) {
        NSString *declaration = [self encodingTypeObjCDeclaration];
        NSString *className = @"";
        NSRange protocolStart = [declaration rangeOfString:@"<"];
        if (protocolStart.location == NSNotFound){
            className = declaration;
        } else {
            className = [declaration substringToIndex:protocolStart.location];
        }
        _classType = NSClassFromString(className);
    }
    return _classType;
}

- (BOOL)isEncodingType:(const char *)encoding
{
    return strcmp(self.encodingType.UTF8String, encoding) == 0;
}

@end
