#import <Foundation/Foundation.h>


@interface HYDURLFormatter : NSFormatter

@property (strong, nonatomic) NSSet *allowedSchemes;

- (id)init;
- (id)initWithAllowedSchemes:(NSSet *)allowedSchemes;

@end
