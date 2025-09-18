# Pico-8 Pong

A simple Pico-8 implementation of the classic Pong game with player vs CPU gameplay.

## Spin Simulation Concept

### Overview
The spin simulation concept adds realistic paddle physics by making the paddle's movement at the moment of collision affect the ball's trajectory. This simulates how a moving paddle would "impart spin" or momentum to the ball.

### Core Mechanics

**1. Track Paddle Velocity**
- Store the paddle's previous position each frame
- Calculate velocity as `current_y - previous_y`
- This gives you both speed and direction of paddle movement

**2. Apply Spin at Collision**
- When ball hits paddle, check the paddle's current velocity
- Modify the ball's vertical component based on this velocity
- Moving paddle up = ball deflects more upward
- Moving paddle down = ball deflects more downward
- Stationary paddle = normal bounce

**3. Spin Intensity**
- Scale the effect based on paddle speed (faster movement = more spin)
- Add a multiplier to control how dramatic the effect is
- Consider capping maximum spin to prevent extreme angles

### Implementation Approach

**For each paddle, track:**
```lua
paddle.prev_y = paddle.y  -- store previous frame position
paddle.velocity = 0       -- calculated each frame
```

**Each frame, calculate velocity:**
```lua
paddle.velocity = paddle.y - paddle.prev_y
paddle.prev_y = paddle.y
```

**At collision, apply spin:**
```lua
-- Base horizontal reflection (your existing logic)
ball.direction = 0.5 - ball.direction

-- Apply spin based on paddle velocity
local spin_factor = 0.3  -- adjust for effect intensity
local spin_influence = paddle.velocity * spin_factor
ball.direction = ball.direction + spin_influence
```

### Benefits

- **Intuitive**: Players naturally expect moving paddles to affect ball direction
- **Skill-based**: Rewards timing paddle movement with ball contact
- **Consistent**: Same paddle movement always produces similar results
- **Controllable**: Easy to tune the effect strength

The beauty is that stationary paddles work normally, but active players can "steer" the ball by timing their paddle movement with the collision.

## Controls

- **Up Arrow**: Move player paddle up
- **Down Arrow**: Move player paddle down
- **X Button**: Restart game (when game over)