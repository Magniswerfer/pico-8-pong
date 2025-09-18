pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- ========================================
-- simple pico-8 pong game
-- ========================================

-- game constants
local screen_width = 127
local screen_height = 127
local screen_center = 63
local paddle_start_y = 55

-- player paddle (left side)
local player_paddle = {
    x = 4,
    y = paddle_start_y,
    width = 4,
    height = 16,
    speed = 2,
    side = 0 -- 0 = left side
}

-- cpu paddle (right side)
local cpu_paddle = {
    x = 120,
    y = paddle_start_y,
    width = 4,
    height = 16,
    speed = 1.5,
    side = 1, -- 1 = right side
    difficulty = 4 -- bigger is easier
}

-- game ball
local ball = {
    x = screen_center,
    y = screen_center,
    width = 4,
    height = 4,
    direction = 0, -- angle in pico-8 format (0-1)
    speed = 1,
    max_speed = 5
}

-- ========================================
-- main game functions
-- ========================================

function _init()
    reset_ball_position("random")
end

function _update()
    -- handle ball collisions with screen edges
    handle_ball_screen_collision()

    -- handle ball collisions with paddles
    handle_ball_paddle_collision(ball, player_paddle)
    handle_ball_paddle_collision(ball, cpu_paddle)

    -- handle player input
    update_player_paddle()

    -- update cpu ai
    update_cpu_paddle()

    -- move the ball
    ball.x = ball.x + cos(ball.direction) * ball.speed
    ball.y = ball.y + sin(ball.direction) * ball.speed
end

function _draw()
    -- clear screen
    cls()

    -- draw paddles
    draw_paddle(player_paddle)
    draw_paddle(cpu_paddle)

    -- draw ball
    rectfill(ball.x, ball.y, ball.x + ball.width - 1, ball.y + ball.height - 1, 10)

    -- draw center line
    draw_center_line()
    draw_border()
end

-->8
-- ========================================
-- paddle functions
-- ========================================

function update_player_paddle()
    -- move paddle up
    if btn(⬆️) then
        player_paddle.y = max(0, player_paddle.y - player_paddle.speed)
    end

    -- move paddle down
    if btn(⬇️) then
        player_paddle.y = min(screen_height - player_paddle.height, player_paddle.y + player_paddle.speed)
    end
end

function update_cpu_paddle()
    -- simple ai: follow the ball
    local ball_center_y = ball.y + ball.height / 2
    local paddle_center_y = cpu_paddle.y + cpu_paddle.height / 2
    local difference = ball_center_y - paddle_center_y

    -- only move if difference is significant (prevents jittering)
    if abs(difference) > cpu_paddle.difficulty then
        local new_y = cpu_paddle.y + sgn(difference) * cpu_paddle.speed
        cpu_paddle.y = mid(0, new_y, screen_height - cpu_paddle.height)
    end
end

function draw_paddle(paddle)
    rectfill(paddle.x, paddle.y, paddle.x + paddle.width - 1, paddle.y + paddle.height - 1, 7)
end

-- ========================================
-- ball functions
-- ========================================

function increase_ball_speed(b, inc)
    b.speed += inc
    b.speed = min(b.speed, b.max_speed)
end

function reset_ball_position(dir)
    -- reset ball to center
    ball.x = screen_center
    ball.y = screen_center
    ball.speed = 1

    -- set ball direction
    local angle
    if dir == "left" then
        -- ball goes toward left player
        angle = rnd(30) + 225
    elseif dir == "right" then
        -- ball goes toward right player
        angle = rnd(30) + 45
    else
        -- random direction
        angle = rnd() > 0.5 and rnd(60) + 30 or rnd(60) + 210
    end

    -- store direction as pico-8 angle (0-1)
    ball.direction = angle / 360
end

function handle_ball_screen_collision()
    -- ball hit left or right edge - reset to center
    if ball.x <= 0 then
        reset_ball_position("right")
    elseif ball.x >= screen_width - ball.width then
        reset_ball_position("left")
    end

    -- ball hit top or bottom edge - bounce
    if ball.y <= 0 or ball.y >= screen_height - ball.height then
        ball.direction = -ball.direction
    end
end

function handle_ball_paddle_collision(ball, paddle)
    -- check if ball and paddle are colliding
    if not objects_colliding(ball, paddle) then
        return
    end

    -- check if ball is moving toward the paddle
    local moving_left = cos(ball.direction) < 0
    local moving_toward_paddle = (paddle.side == 0 and moving_left)
            or (paddle.side == 1 and not moving_left)
    if not moving_toward_paddle then
        return
    end

    -- bounce ball horizontally and adjust position to prevent sticking
    if paddle.side == 0 then
        -- left paddle - reverse horizontal direction
        ball.direction = 0.5 - ball.direction
        ball.x = paddle.x + paddle.width
    else
        -- right paddle - reverse horizontal direction
        ball.direction = 0.5 - ball.direction
        ball.x = paddle.x - ball.width
    end

    -- increase ball speed slightly on each hit (max speed of 3)
    increase_ball_speed(ball, 0.2)

    local moving_up = sin(ball.direction) < 0

    -- change direction off ball depending on where it hit the paddle
    if ball.y < paddle.y + paddle.height / 3 then
        -- if in lower third and moving down, change directions again
        if not moving_up then
            ball.direction = -ball.direction
        end
    end
    if ball.y > paddle.y + 2 * (paddle.height / 3) then
        -- if in higher third
        if moving_up then
            ball.direction = -ball.direction
        end
    end
end

-- ========================================
-- utility functions
-- ========================================

function objects_colliding(obj1, obj2)
    return obj1.x < obj2.x + obj2.width
            and obj1.x + obj1.width > obj2.x
            and obj1.y < obj2.y + obj2.height
            and obj1.y + obj1.height > obj2.y
end

function draw_center_line()
    -- draw dotted center line
    for i = 0, screen_height, 8 do
        pset(screen_center, i, 6)
    end
end

function draw_border()
    for i = 0, screen_width, 1 do
        pset(i, 0, 1)
        pset(i, screen_height, 1)
    end

    for i = 0, screen_height, 1 do
        pset(0, i, 1)
        pset(screen_width, i, 1)
    end
end

--)

__gfx__
00000000000770000000000077777777000000070000000770000000700000000000000077777777777777777777777700000000000000000000000000000000
00000000000770000077770077777777000000070000000770000000700000000000000000000000000000077000000000000000000000000000000000000000
00700700000770000777777077777777000000070000000770000000700000000000000000000000000000077000000000000000000000000000000000000000
00077000000770000777777077777777000000070000000770000000700000000000000000000000000000077000000000000000000000000000000000000000
00077000000770000777777077777777000000070000000770000000700000000000000000000000000000077000000000000000000000000000000000000000
00700700000770000777777077777777000000070000000770000000700000000000000000000000000000077000000000000000000000000000000000000000
00000000000770000077770077777777000000070000000770000000700000000000000000000000000000077000000000000000000000000000000000000000
00000000000770000000000077777777000000077777777770000000777777777777777700000000000000077000000000000000000000000000000000000000
__map__
0b09090909090909090909090909090a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
