//
//  MyScene.m
//  ZombieConga
//
//  Created by Aaron Vasquez on 3/8/14.
//  Copyright (c) 2014 Spud Cannon LLC. All rights reserved.
//

#import "MyScene.h"

static CGFloat const kZombieMovePointsPerSec = 120;

@interface MyScene()
// sprite nodes
@property (weak, nonatomic) SKSpriteNode *zombie; // views should be weak because self.subviews points to them
@property (weak, nonatomic) SKSpriteNode *bg;
// time intervals
@property (nonatomic) NSTimeInterval lastUpdateTime;
@property (nonatomic) NSTimeInterval deltaTime;
// velocity
@property (nonatomic) CGPoint velocity; // point representing a vector
@end

@implementation MyScene

# pragma mark - lazy getters and setters

- (SKSpriteNode *)zombie
{
    if (!_zombie) {
        _zombie = [SKSpriteNode spriteNodeWithImageNamed:@"zombie1"];
        _zombie.position = CGPointMake(100, 100);
//        [_zombie setScale:2.0f];
    }
    return _zombie;
}

- (SKSpriteNode *)bg
{
    if (!_bg) {
        _bg = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        _bg.position = CGPointMake(self.size.width/2, self.size.height/2);
    }
    return _bg;
}

# pragma mark - view lifecycle

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        [self setup];
    }
    return self;
}

# pragma mark - touch handlers

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    [self moveZombieToward:touchLocation];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    [self moveZombieToward:touchLocation];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    [self moveZombieToward:touchLocation];
}

# pragma mark - SpriteKit frame updates

- (void)update:(NSTimeInterval)currentTime
{
    // update timers
    self.deltaTime = self.lastUpdateTime ? currentTime-self.lastUpdateTime : 0;
    self.lastUpdateTime = currentTime;
    
    // move zombay
    [self moveSprite:self.zombie withVelocity:self.velocity];
    [self boundsCheckPlayer];
}

# pragma mark - helpers

- (void)setup
{
    self.backgroundColor = [SKColor whiteColor];
    [self addChild:self.bg];
    [self addChild:self.zombie];
}

- (void)moveSprite:(SKSpriteNode *)sprite withVelocity:(CGPoint)velocity
{
    // position = dx/dt * deltatime
    CGPoint amountToMove = CGPointMake(velocity.x*self.deltaTime, velocity.y*self.deltaTime);
    sprite.position = CGPointMake(sprite.position.x+amountToMove.x, sprite.position.y+amountToMove.y);
}

- (void)moveZombieToward:(CGPoint)location
{
    CGPoint offset = CGPointMake(location.x-self.zombie.position.x, location.y-self.zombie.position.y);// direction with rando velocity
    CGFloat magnitude = sqrtf(offset.x*offset.x + offset.y*offset.y); // rando velocity
    CGPoint direction = CGPointMake(offset.x/magnitude, offset.y/magnitude); // normalized vector
    self.velocity = CGPointMake(direction.x*kZombieMovePointsPerSec, direction.y*kZombieMovePointsPerSec); // apply velocity
}

- (void)boundsCheckPlayer
{
    CGPoint newVelocity = self.velocity;
    if (self.zombie.position.x>=self.size.width || self.zombie.position.x<=0) {
        newVelocity.x = -newVelocity.x;
    }
    if (self.zombie.position.y>=self.size.height || self.zombie.position.y<=0) {
        newVelocity.y = -newVelocity.y;
    }
    self.velocity = newVelocity;
    // also hold zombie to position?
}

@end
