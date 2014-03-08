//
//  ViewController.m
//  ZombieConga
//
//  Created by Aaron Vasquez on 3/8/14.
//  Copyright (c) 2014 Spud Cannon LLC. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"

@implementation ViewController

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    SKView *skView = (SKView *)self.view;
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        
        // create the scene
        SKScene *scene = [MyScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFit;
        
        // present the scene
        [skView presentScene:scene];
    }
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}


@end
