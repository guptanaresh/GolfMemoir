//
//  TransitionView.h
//  GolfMemoir
//
//  Created by naresh gupta on 9/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// A protocol to inform a delegate of transition events.
// The delegate is not used in this example, but it may be useful for you in your own projects.

@class TransitionView;

@protocol TransitionViewDelegate <NSObject>
@optional
- (void)transitionViewDidStart:(TransitionView *)view;
- (void)transitionViewDidFinish:(TransitionView *)view;
- (void)transitionViewDidCancel:(TransitionView *)view;
@end


// This class uses the built-in Core Animation transitions to animate the replacement of a given subview by a new one.

@interface TransitionView : UIView
{
@private
	BOOL transitioning, wasEnabled;
	id<TransitionViewDelegate> delegate;
}

@property (assign) id<TransitionViewDelegate> delegate;
@property (readonly, getter=isTransitioning) BOOL transitioning;

- (void)replaceSubview:(UIView *)oldView withSubview:(UIView *)newView transition:(NSString *)transition direction:(NSString *)direction duration:(NSTimeInterval)duration;
- (void)startAnimationWithTransition:(NSString *)transition direction:(NSString *)direction duration:(NSTimeInterval)duration;
- (void)cancelTransition;

@end
