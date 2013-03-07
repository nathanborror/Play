/*
 *  RDAPIRequest.h
 *  Rdio Web Service API Requests
 *  Copyright 2011 Rdio Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

////////////////////////////////////////////////////////////////////////////////

@class RDAPIRequest;

/**
 * Delegate protocol used to receive responses from Rdio Web Service API calls.
 */
@protocol RDAPIRequestDelegate

/**
 * Called when a request succeeds (request completes and 'status' is 'ok').
 * @param request The request that completed
 * @param data The 'result' field from the service response JSON, which can be an NSDictionary, NSArray, 
 *  or NSString etc. depending on the call.
 */
- (void)rdioRequest:(RDAPIRequest *)request didLoadData:(id)data;

/**
 * Called when a request fails, either with a transport error, or the service JSON status field 'status' is 'error'.
 * @param request The request that failed
 * @param error If it is an NSHTTPURLResponse error the HTTP status code will be used as the error code. 
 *  If it is an Rdio API error the localizedDescription will contain the 'message' response.
 */
- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError *)error;

@end

////////////////////////////////////////////////////////////////////////////////

/**
 * A helper object implementing the
 * \ref RDAPIRequestDelegate-p "&lt;RDAPIRequestDelegate&gt;" protocol, used to
 * direct the load and fail calls to specific selectors.
 *
 * This class is useful if you want to make multiple requests from within 
 * a single object.
 *
 * Example:
 * \code
 * [rdio callAPIMethod:@"get" 
 *      withParameters:[NSDictionary dictionaryWithObject:@"t2932642,t132645" forKey:@"keys"] 
 *            delegate:[RDAPIRequestDelegate delegateToTarget:self 
 *                                               loadedAction:@selector(getRequest:didLoad:) 
 *                                               failedAction:@selector(getRequest:didFailWithError:)]]; 
 * \endcode
 */
@interface RDAPIRequestDelegate : NSObject <RDAPIRequestDelegate> {
  id target_;
  SEL loadedAction_;
  SEL failedAction_;
  id userInfo_;
}

/**
 * Instantiates a delegate that will call loadedAction with the request and result NSDictionary/NSArray
 * or call failedAction with the request and an NSError.
 * 
 * See the RDAPIRequestDelegate-p protocol for more information.
 *
 * Note that if the userInfo property is set it will be passed as a final third param
 * to loadedAction and failedAction
 *
 * @param target The object to which the given selectors should be applied
 * @param load A selector like rdioRequest:didLoadData: to be called when load completes
 * @param fail A selector like rdioRequest:didFailWithError: to be called when load completes
 */
+ (id)delegateToTarget:(id)target loadedAction:(SEL)load failedAction:(SEL)fail;

/**
 * Callback with action that takes the request and the result NSDictionary or NSArray, and ignores all errors
 */
- (id)initWithTarget:(id)target action:(SEL)action;

/**
 * Callback with a loadedAction that takes request and result NSDictionary/NSArray
 * and a failedAction that takes the request and an NSError.
 */
- (id)initWithTarget:(id)target loadedAction:(SEL)load failedAction:(SEL)fail;

/**
 * Used to tack extra information onto the delegate.
 * If not nil will be given as an additional final param to load and fail selectors.
 */
@property (nonatomic, retain) id userInfo;
@end

////////////////////////////////////////////////////////////////////////////////

@class RD_OAConsumer;
@class RD_OAToken;

/**
 * A request to the Rdio Web Service API. See Rdio::callAPIMethod:withParameters:delegate:
 */
@interface RDAPIRequest : NSObject {
  id<RDAPIRequestDelegate> delegate_;
  BOOL expectJSON_;
  NSDictionary *params_;
  NSURL *url_;
  RD_OAConsumer *consumer_;
  RD_OAToken *token_;
  int numRetries_;
}

/**
 * Cancels the Rdio API request
 */
 - (void)cancel;

/**
 * The parameter dictionary passed to the request. Includes a "method" value
 * indicating which web service API was called.
 */
@property (nonatomic, readonly) NSDictionary *parameters;
@end

////////////////////////////////////////////////////////////////////////////////
