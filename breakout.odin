package breakout

import "core:fmt"
import "core:math"
import "core:math/linalg"
import rl "vendor:raylib"

SCREEN_SIZE :: 320
game_started: bool

PADDLE_WIDTH :: 50
PADDLE_HEIGHT :: 6
PADDLE_SPEED :: 200
PADDLE_POS_Y :: 260
paddle_pos_x: f32

BALL_SPEED :: 260
BALL_RADIUS :: 4
BALL_START_Y :: 160
ball_pos: rl.Vector2
ball_dir: rl.Vector2

BLOCK_WIDTH :: 28
BLOCK_HEIGHT :: 10
NUM_BLOCKS_X :: 10
NUM_BLOCKS_Y :: 8
Block_Color :: enum {
	Rose,
	Gold,
	Iris,
	Foam,
}
row_colors := [NUM_BLOCKS_Y]Block_Color{.Rose, .Rose, .Gold, .Gold, .Iris, .Iris, .Foam, .Foam}
block_color_values := [Block_Color]rl.Color {
	.Rose = {235, 188, 186, 255},
	.Gold = {246, 193, 119, 255},
	.Iris = {196, 167, 231, 255},
	.Foam = {156, 207, 216, 255},
}
blocks: [NUM_BLOCKS_X][NUM_BLOCKS_Y]bool

reflect :: proc(dir, normal: rl.Vector2) -> rl.Vector2 {
	new_dir := linalg.reflect(dir, linalg.normalize(normal))
	return linalg.normalize(new_dir)
}

restart :: proc() {
	game_started = false
	paddle_pos_x = SCREEN_SIZE / 2 - PADDLE_WIDTH / 2
	ball_pos = {SCREEN_SIZE / 2, BALL_START_Y}

	for x in 0 ..< NUM_BLOCKS_X {
		for y in 0 ..< NUM_BLOCKS_Y {
			blocks[x][y] = true
		}
	}
}

main :: proc() {
	// https://www.raylib.com/examples/core/loader.html?name=core_window_flags
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(1000, 1000, "BREAKOUT")
	rl.SetTargetFPS(500)

	restart()

	// Main game loop
	for !rl.WindowShouldClose() {
		// Returns time in seconds for last frame drawn (delta time)
		dt: f32

		if !game_started {
			ball_pos = {
				SCREEN_SIZE / 2 + f32(math.cos(rl.GetTime())) * SCREEN_SIZE / 2.5,
				BALL_START_Y,
			}
			if rl.IsKeyPressed(.SPACE) {
				// Direction must be normalized to length 1
				paddle_middle := rl.Vector2{paddle_pos_x + PADDLE_WIDTH / 2, PADDLE_POS_Y}
				ball_to_paddle := paddle_middle - ball_pos
				ball_dir = linalg.normalize0(ball_to_paddle)
				game_started = true
			}
		} else {
			dt = rl.GetFrameTime()
		}

		// Game logic
		prev_ball_pos := ball_pos
		ball_pos += ball_dir * BALL_SPEED * dt

		// If the ball hits the ceiling
		if ball_pos.y - BALL_RADIUS < 0 {
			ball_pos.y = BALL_RADIUS
			ball_dir = reflect(ball_dir, {0, 1})
		}

		// If the ball hits the left wall
		if ball_pos.x - BALL_RADIUS < 0 {
			ball_pos.x = BALL_RADIUS
			ball_dir = reflect(ball_dir, {1, 0})
		}

		// If the ball hits the right wall
		if ball_pos.x + BALL_RADIUS > SCREEN_SIZE {
			ball_pos.x = SCREEN_SIZE - BALL_RADIUS
			ball_dir = reflect(ball_dir, {-1, 0})
		}

		if ball_pos.y > SCREEN_SIZE + BALL_RADIUS * 5 {
			restart()
		}

		paddle_move_velocity: f32

		if rl.IsKeyDown(.H) {
			paddle_move_velocity -= PADDLE_SPEED
		}

		if rl.IsKeyDown(.L) {
			paddle_move_velocity += PADDLE_SPEED
		}

		paddle_pos_x += paddle_move_velocity * dt
		paddle_pos_x = clamp(paddle_pos_x, 0, SCREEN_SIZE - PADDLE_WIDTH)
		paddle_rect := rl.Rectangle{paddle_pos_x, PADDLE_POS_Y, PADDLE_WIDTH, PADDLE_HEIGHT}

		if rl.CheckCollisionCircleRec(ball_pos, BALL_RADIUS, paddle_rect) {
			collision_normal: rl.Vector2

			// If the ball hits the top of the paddle
			if prev_ball_pos.y < paddle_rect.y + paddle_rect.height {
				collision_normal += {0, -1}
				ball_pos.y = paddle_rect.y - BALL_RADIUS
			}

			// If the ball hits the bottom of the paddle
			if prev_ball_pos.y > paddle_rect.y + paddle_rect.height {
				collision_normal += {0, 1}
				ball_pos.y = paddle_rect.y + paddle_rect.height + BALL_RADIUS
			}

			// If the ball hits the left side of the paddle
			if prev_ball_pos.x < paddle_rect.x {
				collision_normal += {-1, 0}
			}

			// If the ball hits the right side of the paddle
			if prev_ball_pos.x > paddle_rect.x + paddle_rect.width {
				collision_normal += {1, 0}
			}

			// Bounce
			if collision_normal != 0 {
				ball_dir = reflect(ball_dir, collision_normal)
			}
		}

		// Drawing logic
		rl.BeginDrawing()
		rl.ClearBackground({25, 23, 36, 255})

		camera := rl.Camera2D {
			zoom = f32(rl.GetScreenHeight()) / SCREEN_SIZE,
		}
		rl.BeginMode2D(camera)

		// Draw paddle.
		rl.DrawRectangleRec(paddle_rect, {49, 116, 143, 255})
		// Draw ball.
		rl.DrawCircleV(ball_pos, BALL_RADIUS, {235, 111, 146, 255})
		// Draw blocks.
		for x in 0 ..< NUM_BLOCKS_X {
			for y in 0 ..< NUM_BLOCKS_Y {
				if blocks[x][y] == false {
					continue
				}
				block_rect := rl.Rectangle {
					f32(20 + x * BLOCK_WIDTH),
					f32(40 + y * BLOCK_HEIGHT),
					BLOCK_WIDTH,
					BLOCK_HEIGHT,
				}
				top_left := rl.Vector2{block_rect.x, block_rect.y}
				top_right := rl.Vector2{block_rect.x + block_rect.width, block_rect.y}
				bot_left := rl.Vector2{block_rect.x, block_rect.y + block_rect.height}
				bot_right := rl.Vector2 {
					block_rect.x + block_rect.width,
					block_rect.y + block_rect.height,
				}
				rl.DrawRectangleRec(block_rect, block_color_values[row_colors[y]])
				rl.DrawLineEx(top_left, top_right, 1, {144, 140, 170, 120})
				rl.DrawLineEx(top_left, bot_left, 1, {144, 140, 170, 120})
				rl.DrawLineEx(top_right, bot_right, 1, {110, 106, 134, 120})
				rl.DrawLineEx(bot_left, bot_right, 1, {110, 106, 134, 120})
			}
		}

		rl.EndMode2D()
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
