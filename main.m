//
//  main.m
//  GolfMemoir
//
//  Created by naresh gupta on 5/5/08.
//  Copyright JAJSoftware 2008. All rights reserved.
//

/*
 Golf Memoir records your golf games on the iPhone. You can savor the memories forever or share it with your friends. 
 As you play the game, you will be able to record score data automatically. After the game is over, you can replay the game stroke by stroke. 
 You can also sign up to upload your game memories to our website. 
 This is your golf legacy. Go, play  a game and build your memoirs. Hope you enjoy it!
*/

#import <UIKit/UIKit.h>
static void _mcleanup(void);
int main(int argc, char *argv[]) {
	//atexit(_mcleanup);
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, nil);
	[pool release];
	return retVal;
}

static
void
_mcleanup(
		  void)
{
	NSLog(@"test");
}