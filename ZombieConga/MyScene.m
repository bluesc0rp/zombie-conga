//
//  MyScene.m
//  ZombieConga
//
//  Created by Aaron Vasquez on 3/8/14.
//  Copyright (c) 2014 Spud Cannon LLC. All rights reserved.
//

#import "MyScene.h"

#define ARC4RANDOM_MAX 0x100000000
static inline CGFloat ScalarRandomRange(CGFloat min, CGFloat max)
{
    return floorf(((double)arc4random() / ARC4RANDOM_MAX) * (max - min) + min);
}

static inline CGPoint CGPointAdd(const CGPoint a,
                                 const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointSubtract(const CGPoint a,
                                      const CGPoint b)
{
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a,
                                            const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

static inline CGFloat CGPointLength(const CGPoint a)
{
    return sqrtf(a.x * a.x + a.y * a.y);
}

static inline CGPoint CGPointNormalize(const CGPoint a)
{
    CGFloat length = CGPointLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

static inline CGFloat CGPointToAngle(const CGPoint a)
{
    return atan2f(a.y, a.x);
}

static inline CGFloat ScalarSign(CGFloat a)
{
    return a >= 0 ? 1 : -1;
}

// Returns shortest angle between two angles,
// between -M_PI and M_PI
static inline CGFloat ScalarShortestAngleBetween(
                                                 const CGFloat a, const CGFloat b)
{
    CGFloat difference = b - a;
    CGFloat angle = fmodf(difference, M_PI * 2);
    if (angle >= M_PI) {
        angle -= M_PI * 2;
    }
    return angle;
}

static const float ZOMBIE_MOVE_POINTS_PER_SEC = 120.0;
static const float ZOMBIE_ROTATE_RADIANS_PER_SEC = 4 * M_PI;

@implementation MyScene
{
    SKSpriteNode *_zombie;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    CGPoint _velocity;
    CGPoint _lastTouchLocation;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        SKSpriteNode *bg =
        [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        bg.position =
        CGPointMake(self.size.width/2, self.size.height/2);
        bg.position =
        CGPointMake(self.size.width / 2, self.size.height / 2);
        bg.anchorPoint = CGPointMake(0.5, 0.5); // same as default
        //bg.zRotation = M_PI / 8;
        [self addChild:bg];
        
        _zombie = [SKSpriteNode spriteNodeWithImageNamed:@"zombie1"];
        _zombie.position = CGPointMake(100, 100);
        [self addChild:_zombie];
        
        [self runAction:[SKAction repeatActionForever:
                         [SKAction sequence:@[
                            [SKAction performSelector:@selector(spawnEnemy) onTarget:self], [SKAction waitForDuration:2.0]
                            ]
                          ]
                         ]
         ];
        
    }
    return self;
}

//// Gesture recognizer example
//// Uncomment this, and comment the touchesBegan/Moved/Ended methods to test
//- (void)didMoveToView:(SKView *)view
//{
//  UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//  [self.view addGestureRecognizer:tapRecognizer];
//}
//
//- (void)handleTap:(UITapGestureRecognizer *)recognizer {
//  CGPoint touchLocation = [recognizer locationInView:self.view];
//  touchLocation = [self convertPointFromView:touchLocation];
//  [self moveZombieToward:touchLocation];
//}

- (void)update:(NSTimeInterval)currentTime
{
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    
    CGPoint offset = CGPointSubtract(_lastTouchLocation, _zombie.position);
    float distance = CGPointLength(offset);
    if (distance < ZOMBIE_MOVE_POINTS_PER_SEC * _dt) {
        _zombie.position = _lastTouchLocation;
        _velocity = CGPointZero;
    } else {
        [self moveSprite:_zombie velocity:_velocity];
        [self boundsCheckPlayer];
        [self rotateSprite:_zombie toFace:_velocity rotateRadiansPerSec:ZOMBIE_ROTATE_RADIANS_PER_SEC];
    }
}

- (void)moveSprite:(SKSpriteNode *)sprite
          velocity:(CGPoint)velocity
{
    // 1
    CGPoint amountToMove = CGPointMultiplyScalar(velocity, _dt);
    
    // 2
    sprite.position = CGPointAdd(sprite.position, amountToMove);
}

- (void)moveZombieToward:(CGPoint)location
{
    _lastTouchLocation = location;
    CGPoint offset = CGPointSubtract(location, _zombie.position);
    
    CGPoint direction = CGPointNormalize(offset);
    _velocity = CGPointMultiplyScalar(direction, ZOMBIE_MOVE_POINTS_PER_SEC);
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self.scene];
    [self moveZombieToward:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self.scene];
    [self moveZombieToward:touchLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self.scene];
    [self moveZombieToward:touchLocation];
}

- (void)boundsCheckPlayer
{
    // 1
    CGPoint newPosition = _zombie.position;
    CGPoint newVelocity = _velocity;
    
    // 2
    CGPoint bottomLeft = CGPointZero;
    CGPoint topRight = CGPointMake(self.size.width,
                                   self.size.height);
    
    // 3
    if (newPosition.x <= bottomLeft.x) {
        newPosition.x = bottomLeft.x;
        newVelocity.x = -newVelocity.x;
    }
    if (newPosition.x >= topRight.x) {
        newPosition.x = topRight.x;
        newVelocity.x = -newVelocity.x;
    }
    if (newPosition.y <= bottomLeft.y) {
        newPosition.y = bottomLeft.y;
        newVelocity.y = -newVelocity.y;
    }
    if (newPosition.y >= topRight.y) {
        newPosition.y = topRight.y;
        newVelocity.y = -newVelocity.y;
    }
    
    // 4
    _zombie.position = newPosition;
    _velocity = newVelocity;
}

- (void)rotateSprite:(SKSpriteNode *)sprite
              toFace:(CGPoint)velocity
 rotateRadiansPerSec:(CGFloat)rotateRadiansPerSec
{
    float targetAngle = CGPointToAngle(velocity);
    float shortest = ScalarShortestAngleBetween(sprite.zRotation, targetAngle);
    float amtToRotate = rotateRadiansPerSec * _dt;
    if (ABS(shortest) < amtToRotate) {
        amtToRotate = ABS(shortest);
    }
    sprite.zRotation += ScalarSign(shortest) * amtToRotate;
}

- (void)spawnEnemy
{
    SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithImageNamed:@"enemy"];
    enemy.position = CGPointMake(self.size.width+enemy.size.width/2, ScalarRandomRange(self.size.height/2, self.size.height-enemy.size.height/2));
    [self addChild:enemy];
    SKAction *actionMove = [SKAction moveToX:-enemy.size.width/2 duration:2.0];
    [enemy runAction:actionMove];
    
//    [self addChild:enemy];
//    SKAction *actionMidMove = [SKAction moveByX:-self.size.width/2-enemy.size.width/2
//                                              y:-self.size.height/2+enemy.size.height/2
//                                       duration:1.0];
////    SKAction *actionMidMove = [SKAction moveTo:CGPointMake(self.size.width/2, enemy.size.height/2) duration:1.0];
//    SKAction *waitAction = [SKAction waitForDuration:0.25f];
//    SKAction *logMessage = [SKAction runBlock:^{ NSLog(@"you take my breath away"); }];
//    SKAction *actionMove = [SKAction moveByX:-self.size.width/2-enemy.size.width/2
//                                           y:self.size.height/2+enemy.size.height/2
//                                    duration:1.0];
////    SKAction *actionMove = [SKAction moveTo:CGPointMake(-enemy.size.width/2, enemy.position.y) duration:1.0];
//    SKAction *sequence = [SKAction sequence:@[actionMidMove, waitAction, logMessage, actionMove]];
//    sequence = [SKAction sequence:@[sequence, [sequence reversedAction]]];
//    
//    [enemy runAction:[SKAction repeatActionForever:sequence]];
}

@end
