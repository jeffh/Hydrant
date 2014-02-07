#import <Foundation/Foundation.h>


/*! A formatter that wraps +[NSURL URLWithString:] to convert strings to NSURLs and vice versa.
 *
 * Optionally, a set of allowed schemes can be provide to restrict the URLs to the given set.
 *
 */
@interface HYDURLFormatter : NSFormatter

@property (strong, nonatomic) NSSet *allowedSchemes;

/*! Constructs a URLFormatter that accepts any url that NSURL can accept.
 *  Given an NSURL, it can produce the corresponding string via -[absoluteString]
 */
- (id)init;
/*! Constructs a URLFormatter that accepts any url that NSURL can accept AND belongs a given scheme.
 *  Given an NSURL, it will call -[absoluteString] if and only if it belongs to the given scheme.
 */
- (id)initWithAllowedSchemes:(NSSet *)allowedSchemes;

@end
