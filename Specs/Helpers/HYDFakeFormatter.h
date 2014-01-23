#import <Foundation/Foundation.h>

@interface HYDFakeFormatter : NSFormatter

@property (strong, nonatomic) NSString *stringToReturn;
@property (strong, nonatomic) id objectToReturn;
@property (strong, nonatomic) NSString *errorDescriptionToReturn;
@property (assign, nonatomic) BOOL returnSuccess;

@property (assign, nonatomic) BOOL didReceiveObject;
@property (assign, nonatomic) BOOL didReceiveString;

@property (strong, nonatomic) NSString *stringReceived;
@property (strong, nonatomic) id objectReceived;

@end
