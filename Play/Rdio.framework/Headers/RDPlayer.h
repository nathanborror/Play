/**
 *  @file RDPlayer.h
 *  Rdio Playback Interface
 *  Copyright 2011 Rdio Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////

/**
 * Playback status
 */
typedef enum {
  RDPlayerStateInitializing, /**< Player is not ready yet */
  RDPlayerStatePaused, /**< Playback is paused */
  RDPlayerStatePlaying, /**< Currently playing (or buffering) */
  RDPlayerStateStopped /**< Playback is stopped */
} RDPlayerState;

////////////////////////////////////////////////////////////////////////////////

/**
 * Player delegate
 */
@protocol RDPlayerDelegate

/**
 * Notification that the current user has started playing with Rdio from 
 * another location, and playback here must stop.
 * @return <code>YES</code> if you handle letting the user know, or <code>NO</code> to have the SDK display a dialog.
 */
-(BOOL)rdioIsPlayingElsewhere;

/**
 * Notification that the player has changed states. See <code>RDPlayerState</code>.
 */
-(void)rdioPlayerChangedFromState:(RDPlayerState)oldState toState:(RDPlayerState)newState;

/**
 * Notification that the play queue has been updated.
 *
 * For example, when new tracks are added using the queueSource and queueSources
 * methods.
 */
@optional
-(void)rdioPlayerQueueDidChange;

@end

////////////////////////////////////////////////////////////////////////////////

@class AudioStreamer;
@class RDUserEventLog;
@class RDSession;

/**
 * Responsible for playback. Handles playing and enqueueing track sources, 
 * advancing to the next track, logging plays with the server, etc.
 *
 * To observe track changes, position changes, etc., use KVO. For example:
 * \code
 *  [player addObserver:self forKeyPath:@"currentTrack" options:NSKeyValueObservingOptionNew context:nil];
 * \endcode
 */
@interface RDPlayer : NSObject {
@private
  RDPlayerState state_;
  double position_;
  
  RDSession *session_;
  
  int currentTrackIndex_;
  NSString *currentTrack_;
  AudioStreamer *audioStream_;
  
  NSString *nextTrack_;
  AudioStreamer *nextAudioStream_;
  
  RDUserEventLog *log_;
  
  BOOL sentPlayEvent_;
  BOOL sentTimedPlayEvent_;
  BOOL sendSkipEvent_;
  BOOL sentSkipEvent_;
  
  BOOL checkingPlayingElsewhere_;
  
  NSTimer *pauseTimer_;
  NSString *playerName_;
  
  NSArray *trackKeys_;
  
  id<RDPlayerDelegate> delegate_;
}

/**
 * Starts playing a source key, such as "t1232".
 *
 * Supported source keys include tracks, albums, playlists, and artist stations.
 *
 * Track keys can be found by calling web service API methods.
 * Objects such as Album contain a 'trackKeys' property.
 *
 * @param sourceKey a source key such as "t1232"
 */
-(void)playSource:(NSString *)sourceKey;

/**
 * Play through a list of track keys, pre-buffering and automatically advancing
 * between songs.
 *
 * Supported source keys include tracks, albums, playlists, and artist stations.
 *
 * @param sourceKeys list of source keys
 */
-(void)playSources:(NSArray *)sourceKeys;

/**
 * Advances to the next track in the \ref RDPlayer::trackKeys "trackKeys" array.
 * This method only works within the array passed to the RDPlayer::playSources: method.
 */
-(void)next;

/**
 * Play the previous track in the \ref RDPlayer::trackKeys "trackKeys" array.
 * This method only works within a list passed to the <code>playSources:</code> method.
 */
-(void)previous;

/**
 * Continues playing the current track
 *
 * This is the same as calling RDPlayer::playAndRestart:YES
 */
- (void)play;

/**
 * Continues playing the current track with an option to restart the track if
 * it's already playing
 *
 * If the player is already playing, setting shouldRestart to YES will restart
 * the track from the begining.
 *
 * @param shouldRestart if the player should restart the currently playing track
 */
- (void)playAndRestart:(BOOL)shouldRestart;

/**
 * Toggles paused state.
 */
- (void)togglePause;

/**
 * Stops playback and releases resources.
 */
- (void)stop;

/**
 * Seeks to the given position.
 * @param positionInSeconds position to seek to, in seconds
 */
- (void)seekToPosition:(double)positionInSeconds;

/**
 * Add a source key to the end of the existing play queue
 *
 * Supported source keys include tracks, albums, playlists, and artist stations.
 *
 * @param sourceKey A source key, such as "t1232"
 */
- (void)queueSource:(NSString*)sourceKey;

/**
 * Add the list of source keys to the end of the existing play queue
 *
 * Supported source keys include tracks, albums, playlists, and artist stations.
 *
 * @param sourceKeys List of source keys, such as "t1232"
 */
- (void)queueSources:(NSArray*)sourceKeys;

/**
 * Replace the play queue with a different list of track keys.
 *
 * This method replaces the entire play queue much like RDPlayer::playSources:.
 * Unlike RDPlayer::playSources:, this method does not stop playback of the
 * current track.
 *
 * If the index does not point at the currently playing track, the method will
 * not update the queue and will return NO.
 *
 * @param sourceKeys List of track keys, such as "t1232"
 * @param index Index of the currently playing track
 * @return NO if the queue was not updated
 */
- (BOOL)updateQueue:(NSArray*)sourceKeys withCurrentTrackIndex:(int)index;

/**
 * Current playback state.
 */
@property (nonatomic, readonly) RDPlayerState state;

/**
 * Current position in seconds.
 */
@property (nonatomic, readonly) double position;

/**
 * Duration of the current track, in seconds.
 */
@property (nonatomic, readonly) double duration;

/**
 * The key of the current track.
 */
@property (nonatomic, readonly) NSString *currentTrack;

/**
 * Index in the \ref RDPlayer::trackKeys "trackKeys" array that is currently playing.
 */
@property (nonatomic, readonly) int currentTrackIndex;

/**
 * List of track keys that represents the play queue
 */
@property (nonatomic, readonly) NSArray *trackKeys;

/**
 * Delegate used to receive player state changes.
 */
@property (nonatomic, assign) id<RDPlayerDelegate> delegate;

@end

