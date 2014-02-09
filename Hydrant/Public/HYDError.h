#import "HYDBase.h"
#import "HYDConstants.h"


@protocol HYDMapper;
@protocol HYDAccessor;

/*! The NSError subclass object that all hydrant mappers emit.
 *
 *  Unlike normal NSErrors, mappers can do one of the following:
 *
 *  - Return nil, indicating no errors parsing the source object.
 *  - Return a non-fatal error, indicating some fallback strategy was used
 *    when parsing the source object.
 *  - Return a fatal error, indicating the source object could not be parsed.
 *
 *  The safest way to determine if a mapper's result is safe to use is to use
 *  the -[HYDError isFatal] method. Or read it from the user info, userInfo[HYDIsFatalKey].
 *
 *  In addition, HYDErrors may contain multiple errors. Use -[underlyingErrors] to
 *  get all the errors (or HYDUnderlyingErrors key). For convenience, there is
 *  an -[underlyingFatalErrors] to quickly fetch fatal errors that occurred.
 *
 *  Since mappers can be arbitrarily nested, HYDErrors can too. And it is not safe
 *  to assume the tree of errors are always HYDErrors. For example, NSFormatter-based,
 *  mappers will also store the original NSFormatter errors inside a HYDError.
 *
 *  A small set of helper constructors are provided for when you build your own mappers
 *  to allow you to capture and handle errors that bubble up from child mappers.
 *
 *  Codes that HYDError can return are:
 *
 *  - HYDErrorInvalidSourceObjectValue to indicate the source object was invalid
 *  - HYDErrorInvalidSourceObjectType to indicate the source object's type was incorrect
 *  - HYDErrorInvalidResultingObjectType to indicate the resulting object produced was an invalid type
 *  - HYDErrorMultipleErrors to indicate multiple parsing errors have occurred
 *
 */
@interface HYDError : NSError

/*! Constructs a new HYDError to report a mapping error occurred.
 *
 *  Every parameter, but code and isFatal are optional. Although the more information you
 *  provide will help other developers diagnose parse errors.
 *
 *  @param code The NSError code that this error represents. Please use one of the Hydrant error codes.
 *  @param sourceObject the source object that produced this mapping error. Return nil if not known.
 *  @param sourceAccessor the origin property/key that this source object originated from. Return nil if not known.
 *  @param destinationAccessor the target property/key that this resulting object would be store in. Return nil if not known.
 *  @param isFatal the bool that indicates if this error is fatal. It is still the mapper's responsibility to
 *                 return a nil resulting object if the error was fatal.
 *  @param underlyingErrors An error of any kind of NSErrors that contributed to this error. Return nil if there
 *                          are no underlying errors.
 *  @returns a new HYDError instance
 */
+ (instancetype)errorWithCode:(NSInteger)code
                 sourceObject:(id)sourceObject
               sourceAccessor:(id<HYDAccessor>)sourceAccessor
            destinationObject:(id)destinationObject
          destinationAccessor:(id<HYDAccessor>)destinationAccessor
                      isFatal:(BOOL)isFatal
             underlyingErrors:(NSArray *)underlyingErrors;

/*! Constructs a new HYDError based on the provided HYDError.
 *  This is used to reduce the total number of errors returned to the end-user by simply
 *  tweaking the errors raised with the necessary information a parent mapper may know.
 *
 *  All but error and isFatal parameters are optional.
 *
 *  @param error The HYDError to base the new error on.
 *  @param sourceAccessor The source key to prepend to the original error's source key. Return nil if none.
 *  @param destinationAccessor The destination key to present to the original error's destination key. Return nil if none.
 *  @param sourceObject A new source object to replace the original error's source object. Return nil if not known.
 *  @param isFatal A boolean to indicate if the new error is fatal or not. It is still the responsibility of the
 *                 mapper to return a nil resulting object when a fatal error occurs.
 *  @returns a new HYDError instance
 */
+ (instancetype)errorFromError:(HYDError *)error
      prependingSourceAccessor:(id<HYDAccessor>)sourceAccessor
        andDestinationAccessor:(id<HYDAccessor>)destinationAccessor
       replacementSourceObject:(id)sourceObject
                       isFatal:(BOOL)isFatal;

/*! Constructs a new HYDError from an array of underlying errors. This is commonly used for mappers that
 *  use a collection of child mappers and emits an error that reports all the underlying errors.
 *
 *  Currently, this is an alias to
 *  +[errorWithCode:sourceObject:sourceAccessor:destinationObject:destinationAccessor:isFatal:underlyingErrors:]
 *  with the error code already set correctly.
 *
 *  @param sourceObject the source object that produced this mapping error. Return nil if not known.
 *  @param sourceAccessor the origin property/key that this source object originated from. Return nil if not known.
 *  @param destinationAccessor the target property/key that this resulting object would be store in. Return nil if not known.
 *  @param isFatal the bool that indicates if this error is fatal. It is still the mapper's responsibility to
 *                 return a nil resulting object if the error was fatal.
 *  @param underlyingErrors An error of any kind of NSErrors that contributed to this error. Return nil if there
 *                          are no underlying errors.
 *  @returns a new HYDError instance
 */
+ (instancetype)errorFromErrors:(NSArray *)errors
                   sourceObject:(id)sourceObject
                 sourceAccessor:(id<HYDAccessor>)sourceAccessor
              destinationObject:(id)destinationObject
            destinationAccessor:(id<HYDAccessor>)destinationAccessor
                        isFatal:(BOOL)isFatal;

/*! Returns a boolean indicating if the error is fatal.
 *  Fatal errors failed the parse the source object and the resulting object returned should not
 *  be trusted.
 */
- (BOOL)isFatal;

/*! Returns the source key that the source object was extracted from if known. Returns nil otherwise.
 */
- (id<HYDAccessor>)sourceAccessor;

/*! Returns the destination key that resulting object created from the source object would be set into.
 *  Returns nil if not known.
 */
- (id<HYDAccessor>)destinationAccessor;

/*! Returns the source object that the mapping error occurred on. Returns nil if not known.
 *
 *  May contain sensitive information if you're using hydrant to map sensitive information.
 */
- (id)sourceObject;
/*! Returns the destination object that the mapper produced. Usually is nil because most mappers return
 *  errors because of the failure to produce a destination or resulting object.
 */
- (id)destinationObject;
/*! Returns an array of errors that helped contribute to the generation of this error.
 *  This array may contain HYDErrors or other NSErrors.
 */
- (NSArray *)underlyingErrors;
/*! Returns an array of fatal errors that helped contribute to the generation of this error.
 *  This array may contain HYDErrors or other NSErrors.
 */
- (NSArray *)underlyingFatalErrors;

@end
