//
//  NBReorderableCollectionViewLayout.m
//
//  Created by Stan Chang Khin Boon on 1/10/12.
//  Modified by Nathan Borror on 10/12/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "NBReorderableCollectionViewLayout.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define SCROLL_DIRECTION_KEYPATH @"NBScrollingDirection"
#define COLLECTION_VIEW_KEYPATH @"collectionView"

static const CGFloat kFramesPerSecond = 60.0;

CGPoint CGPointAdd(CGPoint point1, CGPoint point2) {
  return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

typedef NS_ENUM(NSInteger, NBScrollingDirection) {
  NBScrollingDirectionUnknown = 0,
  NBScrollingDirectionUp,
  NBScrollingDirectionDown,
  NBScrollingDirectionLeft,
  NBScrollingDirectionRight
};


@interface CADisplayLink (userInfo)

@property (nonatomic, copy) NSDictionary *userInfo;

@end


@implementation CADisplayLink (userInfo)

- (void)setUserInfo:(NSDictionary *)userInfo
{
  objc_setAssociatedObject(self, "userInfo", userInfo, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)userInfo {
  return objc_getAssociatedObject(self, "userInfo");
}

@end


@interface UICollectionViewCell (ReorderableCollectionViewLayout)

- (UIImage *)rasterizedImage;

@end


@implementation UICollectionViewCell (ReorderableCollectionViewLayout)

- (UIImage *)rasterizedImage {
  UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0f);
  [self.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

@end


@implementation NBReorderableCollectionViewLayout {
  NSIndexPath *_selectedItemIndexPath;
  UIView *_currentView;
  CGPoint _currentViewCenter;
  CGPoint _panTranslationInCollectionView;
  CADisplayLink *_displayLink;
}

- (id)init {
  if (self = [super init]) {
    _scrollingSpeed = 300.0f;
    _scrollingTriggerEdgeInsets = UIEdgeInsetsMake(50.0f, 50.0f, 50.0f, 50.0f);

    [self addObserver:self forKeyPath:COLLECTION_VIEW_KEYPATH options:NSKeyValueObservingOptionNew context:nil];
  }
  return self;
}

- (void)setupCollectionView {
  _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
  _longPressGestureRecognizer.delegate = self;

  // Links the default long press gesture recognizer to the custom long press gesture recognizer we are creating now
  // by enforcing failure dependency so that they doesn't clash.
  for (UIGestureRecognizer *gestureRecognizer in self.collectionView.gestureRecognizers) {
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
      [gestureRecognizer requireGestureRecognizerToFail:_longPressGestureRecognizer];
    }
  }

  [self.collectionView addGestureRecognizer:_longPressGestureRecognizer];

  _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
  _panGestureRecognizer.delegate = self;
  [self.collectionView addGestureRecognizer:_panGestureRecognizer];

  // Useful in multiple scenarios: one common scenario being when the Notification Center drawer is pulled down
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillResignActive:) name: UIApplicationWillResignActiveNotification object:nil];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
  if ([layoutAttributes.indexPath isEqual:_selectedItemIndexPath]) {
    layoutAttributes.hidden = YES;
  }
}

- (id<NBReorderableCollectionViewDataSource>)dataSource {
  return (id<NBReorderableCollectionViewDataSource>)self.collectionView.dataSource;
}

- (id<NBReorderableCollectionViewDelegateFlowLayout>)delegate {
  return (id<NBReorderableCollectionViewDelegateFlowLayout>)self.collectionView.delegate;
}

- (void)invalidateLayoutIfNecessary {
  NSIndexPath *newIndexPath = [self.collectionView indexPathForItemAtPoint:_currentView.center];
  NSIndexPath *previousIndexPath = _selectedItemIndexPath;

  if ((newIndexPath == nil) || [newIndexPath isEqual:previousIndexPath]) {
    return;
  }

  if ([self.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:canMoveToIndexPath:)] &&
      ![self.dataSource collectionView:self.collectionView itemAtIndexPath:previousIndexPath canMoveToIndexPath:newIndexPath]) {
    return;
  }

  _selectedItemIndexPath = newIndexPath;

  if ([self.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:willMoveToIndexPath:)]) {
    [self.dataSource collectionView:self.collectionView itemAtIndexPath:previousIndexPath willMoveToIndexPath:newIndexPath];
  }

  [self.collectionView performBatchUpdates:^{
    [self.collectionView deleteItemsAtIndexPaths:@[previousIndexPath]];
    [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
  } completion:^(BOOL finished) {
    if ([self.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:didMoveToIndexPath:)]) {
      [self.dataSource collectionView:self.collectionView itemAtIndexPath:previousIndexPath didMoveToIndexPath:newIndexPath];
    }
  }];
}

- (void)invalidatesScrollTimer {
  if (!_displayLink.paused) {
    [_displayLink invalidate];
  }
  _displayLink = nil;
}

- (void)setupScrollTimerInDirection:(NBScrollingDirection)direction {
  if (!_displayLink.paused) {
    NBScrollingDirection oldDirection = [_displayLink.userInfo[SCROLL_DIRECTION_KEYPATH] integerValue];
    if (direction == oldDirection) {
      return;
    }
  }

  [self invalidatesScrollTimer];

  _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleScroll:)];
  _displayLink.userInfo = @{SCROLL_DIRECTION_KEYPATH: @(direction)};
  [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

// Tight loop, allocate memory sparely, even if they are stack allocation.
- (void)handleScroll:(CADisplayLink *)aDisplayLink {
  NBScrollingDirection direction = (NBScrollingDirection)[aDisplayLink.userInfo[SCROLL_DIRECTION_KEYPATH] integerValue];
  if (direction == NBScrollingDirectionUnknown) {
    return;
  }

  CGSize frameSize = self.collectionView.bounds.size;
  CGSize contentSize = self.collectionView.contentSize;
  CGPoint contentOffset = self.collectionView.contentOffset;
  CGFloat distance = _scrollingSpeed / kFramesPerSecond;
  CGPoint translation = CGPointZero;

  switch(direction) {
    case NBScrollingDirectionUp: {
      distance = -distance;
      CGFloat minY = 0.0f;
      if ((contentOffset.y + distance) <= minY) {
        distance = -contentOffset.y;
      }
      translation = CGPointMake(0.0f, distance);
    } break;
    case NBScrollingDirectionDown: {
      CGFloat maxY = MAX(contentSize.height, frameSize.height) - frameSize.height;
      if ((contentOffset.y + distance) >= maxY) {
        distance = maxY - contentOffset.y;
      }
      translation = CGPointMake(0.0f, distance);
    } break;
    case NBScrollingDirectionLeft: {
      distance = -distance;
      CGFloat minX = 0.0f;
      if ((contentOffset.x + distance) <= minX) {
        distance = -contentOffset.x;
      }
      translation = CGPointMake(distance, 0.0f);
    } break;
    case NBScrollingDirectionRight: {
      CGFloat maxX = MAX(contentSize.width, frameSize.width) - frameSize.width;
      if ((contentOffset.x + distance) >= maxX) {
        distance = maxX - contentOffset.x;
      }
      translation = CGPointMake(distance, 0.0f);
    } break;
    default:
      break;
  }

  _currentViewCenter = CGPointAdd(_currentViewCenter, translation);
  _currentView.center = CGPointAdd(_currentViewCenter, _panTranslationInCollectionView);
  self.collectionView.contentOffset = CGPointAdd(contentOffset, translation);
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
  switch(gestureRecognizer.state) {
    case UIGestureRecognizerStateBegan: {
      NSIndexPath *currentIndexPath = [self.collectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:self.collectionView]];

      if ([self.dataSource respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:)] && ![self.dataSource collectionView:self.collectionView canMoveItemAtIndexPath:currentIndexPath]) {
        return;
      }

      _selectedItemIndexPath = currentIndexPath;

      if ([self.delegate respondsToSelector:@selector(collectionView:layout:willBeginDraggingItemAtIndexPath:)]) {
        [self.delegate collectionView:self.collectionView layout:self willBeginDraggingItemAtIndexPath:_selectedItemIndexPath];
      }

      UICollectionViewCell *collectionViewCell = [self.collectionView cellForItemAtIndexPath:_selectedItemIndexPath];

      _currentView = [[UIView alloc] initWithFrame:collectionViewCell.frame];

      collectionViewCell.highlighted = YES;
      UIImageView *highlightedImageView = [[UIImageView alloc] initWithImage:[collectionViewCell rasterizedImage]];
      highlightedImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      highlightedImageView.alpha = 1.0f;

      collectionViewCell.highlighted = NO;
      UIImageView *imageView = [[UIImageView alloc] initWithImage:[collectionViewCell rasterizedImage]];
      imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      imageView.alpha = 0.0f;

      [_currentView addSubview:imageView];
      [_currentView addSubview:highlightedImageView];
      [self.collectionView addSubview:_currentView];

      _currentViewCenter = _currentView.center;

      highlightedImageView.alpha = 0;
      imageView.alpha = 1;

      [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:.4 initialSpringVelocity:.1 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _currentView.transform = CGAffineTransformMakeScale(1.1, 1.1);
      } completion:^(BOOL finished) {
        [highlightedImageView removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:didBeginDraggingItemAtIndexPath:)]) {
          [self.delegate collectionView:self.collectionView layout:self didBeginDraggingItemAtIndexPath:_selectedItemIndexPath];
        }
      }];

      [self invalidateLayout];
    } break;
    case UIGestureRecognizerStateCancelled:
    case UIGestureRecognizerStateEnded: {
      NSIndexPath *currentIndexPath = _selectedItemIndexPath;

      if (currentIndexPath) {
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:willEndDraggingItemAtIndexPath:)]) {
          [self.delegate collectionView:self.collectionView layout:self willEndDraggingItemAtIndexPath:currentIndexPath];
        }

        _selectedItemIndexPath = nil;
        _currentViewCenter = CGPointZero;

        UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:currentIndexPath];

        [UIView animateWithDuration:.7 delay:0 usingSpringWithDamping:.5 initialSpringVelocity:.2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
          _currentView.transform = CGAffineTransformMakeScale(1, 1);
          _currentView.center = layoutAttributes.center;
        } completion:^(BOOL finished) {
          [_currentView removeFromSuperview];
          _currentView = nil;
          [self invalidateLayout];
          if ([self.delegate respondsToSelector:@selector(collectionView:layout:didEndDraggingItemAtIndexPath:)]) {
            [self.delegate collectionView:self.collectionView layout:self didEndDraggingItemAtIndexPath:currentIndexPath];
          }
        }];
      }
    } break;
    default:
      break;
  }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
  switch (gestureRecognizer.state) {
    case UIGestureRecognizerStateBegan:
    case UIGestureRecognizerStateChanged: {
      _panTranslationInCollectionView = [gestureRecognizer translationInView:self.collectionView];
      CGPoint viewCenter = _currentView.center = CGPointAdd(_currentViewCenter, _panTranslationInCollectionView);

      [self invalidateLayoutIfNecessary];

      switch (self.scrollDirection) {
        case UICollectionViewScrollDirectionVertical: {
          if (viewCenter.y < (CGRectGetMinY(self.collectionView.bounds) + _scrollingTriggerEdgeInsets.top)) {
            [self setupScrollTimerInDirection:NBScrollingDirectionUp];
          } else {
            if (viewCenter.y > (CGRectGetMaxY(self.collectionView.bounds) - _scrollingTriggerEdgeInsets.bottom)) {
              [self setupScrollTimerInDirection:NBScrollingDirectionDown];
            } else {
              [self invalidatesScrollTimer];
            }
          }
        } break;
        case UICollectionViewScrollDirectionHorizontal: {
          if (viewCenter.x < (CGRectGetMinX(self.collectionView.bounds) + _scrollingTriggerEdgeInsets.left)) {
            [self setupScrollTimerInDirection:NBScrollingDirectionLeft];
          } else {
            if (viewCenter.x > (CGRectGetMaxX(self.collectionView.bounds) - _scrollingTriggerEdgeInsets.right)) {
              [self setupScrollTimerInDirection:NBScrollingDirectionRight];
            } else {
              [self invalidatesScrollTimer];
            }
          }
        } break;
      }
    } break;
    case UIGestureRecognizerStateCancelled:
    case UIGestureRecognizerStateEnded: {
      [self invalidatesScrollTimer];
    } break;
    default:
      break;
  }
}

#pragma mark - UICollectionViewLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
  NSArray *layoutAttributesForElementsInRect = [super layoutAttributesForElementsInRect:rect];

  for (UICollectionViewLayoutAttributes *layoutAttributes in layoutAttributesForElementsInRect) {
    if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
      [self applyLayoutAttributes:layoutAttributes];
    }
  }
  return layoutAttributesForElementsInRect;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewLayoutAttributes *layoutAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];

  if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
    [self applyLayoutAttributes:layoutAttributes];
  }
  return layoutAttributes;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  if ([_panGestureRecognizer isEqual:gestureRecognizer]) {
    return (_selectedItemIndexPath != nil);
  }
  return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  if ([_longPressGestureRecognizer isEqual:gestureRecognizer]) {
    return [_panGestureRecognizer isEqual:otherGestureRecognizer];
  }

  if ([_panGestureRecognizer isEqual:gestureRecognizer]) {
    return [_longPressGestureRecognizer isEqual:otherGestureRecognizer];
  }
  return NO;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if ([keyPath isEqualToString:COLLECTION_VIEW_KEYPATH]) {
    if (self.collectionView != nil) {
      [self setupCollectionView];
    } else {
      [self invalidatesScrollTimer];
    }
  }
}

#pragma mark - Notifications

- (void)handleApplicationWillResignActive:(NSNotification *)notification {
  _panGestureRecognizer.enabled = NO;
  _panGestureRecognizer.enabled = YES;
}

@end
