//
//  MyScene.m
//  ZombieConga
//
//  Created by Aaron Vasquez on 3/8/14.
//  Copyright (c) 2014 Spud Cannon LLC. All rights reserved.
//

#import "MyScene.h"

// math helpers
static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b){
    return CGPointMake(a.x + b.x, a.y + b.y);
}
static inline CGPoint CGPointSubtract(const CGPoint a, const CGPoint b){
    return CGPointMake(a.x - b.x, a.y - b.y);
}
static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b){
    return CGPointMake(a.x * b, a.y * b);
}
static inline CGFloat CGPointLength(const CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}
static inline CGPoint CGPointNormalize(const CGPoint a) {
    CGFloat length = CGPointLength(a);
    return CGPointMake(a.x / length, a.y / length);
}
static inline CGFloat CGPointToAngle(const CGPoint a) {
    return atan2f(a.y, a.x);
}

static CGFloat const kZombieMovePointsPerSec = 120;

@interface MyScene()
@property (weak, nonatomic) SKSpriteNode *zombie; // views should be weak because self.subviews points to them
@property (weak, nonatomic) SKSpriteNode *bg;
@property (nonatomic) NSTimeInterval lastUpdateTime;
@property (nonatomic) NSTimeInterval deltaTime;
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
    [self rotatoSprite:self.zombie toFace:self.velocity];
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
    CGPoint amountToMove = CGPointMultiplyScalar(velocity, self.deltaTime);
    sprite.position = CGPointAdd(sprite.position, amountToMove);
}

- (void)rotatoSprite:(SKSpriteNode *)sprite toFace:(CGPoint)direction
{
    sprite.zRotation = CGPointToAngle(direction);
}

- (void)moveZombieToward:(CGPoint)location
{
    
    CGPoint offset = CGPointSubtract(location, self.zombie.position);;// direction with rando velocity
    CGPoint direction = CGPointNormalize(offset); // normalized vector...use unit of 1
    self.velocity = CGPointMultiplyScalar(direction, kZombieMovePointsPerSec); // apply velocity scaler
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
