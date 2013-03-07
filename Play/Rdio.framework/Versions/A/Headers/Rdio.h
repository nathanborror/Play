/*
 *  Rdio.h
 *  Rdio iOS SDK
 *  Copyright 2011 Rdio Inc. All rights reserved.
 */

#import "RDPlayer.h"
#import "RDAPIRequest.h"

@protocol RdioDelegate;
@class RDSession;
@class RDAuthViewController;

////////////////////////////////////////////////////////////////////////////////

/** @mainpage
 * The Rdio iOS SDK lets developers call the web service API, authenticate users,
 * and play full song streams or 30 second samples.
 * <br/><br/>
 * To get started:
 * <ul>
 *  <li>Visit http://developer.rdio.com to register a developer account and apply for a key</li>
 *  <li>Try the <a href="http://itunes.apple.com/us/app/music-quiz-for-rdio/id434015378">sample app</a> and get the source from https://github.com/rdio/rdioquiz-ios</li>
 *  <li>Download the <a href="http://www.rdio.com/media/static/developer/ios/rdio-ios.tar.gz">framework</a></li>
 *  <li>Drag the Rdio framework into your XCode project</li>
 *  <li><b>Add CoreGraphics.framework, CFNetwork.framework, SystemConfiguration.framework, AudioToolbox.framework and Security.framework</b></li>
 *  <li><b>Add <a href="http://developer.apple.com/library/mac/#qa/qa1490/_index.html">-all_load</a> under Other Linker Flags in the project build info</b></li>
 *  <li>Try the following code in your app delegate:</li>
 * </ul>
 * \code
 *   #import <Rdio/Rdio.h>
 *   Rdio *rdio = [[Rdio alloc] initWithConsumerKey:@"YOUR KEY" andSecret:@"YOUR SECRET" delegate:nil];
 *   [rdio.player playSource:@"t2742133"];
 * \endcode
 *
 * This is a beta release. Please direct feature requests and bug reports to 
 * <a href="http://twitter.com/rdioapi">\@RdioAPI</a> or the 
 * <a href="http://groups.google.com/group/rdio-api">Rdio API Google Group</a>.
 */

////////////////////////////////////////////////////////////////////////////////

/**
 * Façade for interacting with the Rdio API.
 * Supports server API calls and track playback for anonymous and authorized users.
 */
@interface Rdio : NSObject {
  RDPlayer *player_;
  RDSession *session_;
  RDAuthViewController *authViewController_;
  UIViewController *currentController_;
  id<RdioDelegate> delegate_;
}

/**
 * Initializes the Rdio API with your consumer key and secret.
 * Visit http://developer.rdio.com/ to register and apply for a key.
 * @param key Your consumer key
 * @param secret Your secret
 * @param delegate Delegate for receiving state changes, or nil
 */
- (id)initWithConsumerKey:(NSString *)key andSecret:(NSString *)secret delegate:(id<RdioDelegate>)delegate;

/**
 * Presents a modal login dialog and attempts to get an authorized Rdio user.
 * @param currentController Controller from which the login view should be launched
 */
- (void)authorizeFromController:(UIViewController *)currentController;

/**
 * Attempts to reauthorize using an access token from a previous session.
 * If this process fails the user is presented with a modal login dialog.
 * @param accessToken A token received from a previous <code>rdioDidAuthorizeUser:withAccessToken:</code> delegate call
 * @param currentController Controller from which a login view might be launched
 */
- (void)authorizeUsingAccessToken:(NSString *)accessToken 
                   fromController:(UIViewController *)currentController;

/**
 * Logs out the current user.  Calls <code>rdioDidLogout</code> on delegate on completion.  Clients are responsible
 * for clearing any application-persisted state (user data, access token, etc).
 */
- (void)logout;

/**
 * Calls an Rdio Web Service API method with the given parameters.
 * @param method Name of the method to call. See http://developer.rdio.com/docs/read/rest/Methods for available methods.
 * @param params A dictionary of parameters as required for the method
 * @param delegate An object implementing the RDAPIRequestDelegate protocol or an instance of the RDAPIRequestDelegate class, to be notified on request complete.
 */
- (RDAPIRequest *)callAPIMethod:(NSString *)method 
                 withParameters:(NSDictionary *)params 
                       delegate:(id<RDAPIRequestDelegate>)delegate;

/**
 * Delegate used to receive Rdio API state changes.
 */
@property (nonatomic, assign) id<RdioDelegate> delegate;

/**
 * A dictionary describing the current user, or nil if no user is logged in.
 * See http://developer.rdio.com/docs/read/rest/types
 */
@property (nonatomic, readonly) NSDictionary *user;

/**
 * The playback interface.
 */
@property (nonatomic, readonly) RDPlayer *player;

@end

////////////////////////////////////////////////////////////////////////////////

/**
 * Delegate used to receive Rdio API state changes.
 */
@protocol RdioDelegate
@optional

/**
 * Called when an authorize request finishes successfully. 
 * @param user A dictionary containing information about the user that was authorized. See http://developer.rdio.com/docs/read/rest/types
 * @param accessToken A token that can be used to automatically reauthorize the current user in subsequent sessions
 */
- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken;

/**
 * Called if authorization cannot be completed due to network or server problems.
 * The user will be notified from the login view before this method is called.
 * @param error A message describing what went wrong.
 */
- (void)rdioAuthorizationFailed:(NSString *)error;

/**
 * Called if the user aborts the authorization process.
 */
- (void)rdioAuthorizationCancelled;

/**
 * Called when logout completes.
 */
-(void)rdioDidLogout;

@end
