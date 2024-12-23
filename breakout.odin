package breakout

import "core:fmt"
import rl "vendor:raylib"

SCREEN_SIZE :: 320

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

restart :: proc() {
	paddle_pos_x = SCREEN_SIZE / 2 - PADDLE_WIDTH / 2
	ball_pos = {SCREEN_SIZE / 2, BALL_START_Y}
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
		dt := rl.GetFrameTime()

		// Logic stuff
		paddle_move_velocity: f32

		if rl.IsKeyDown(.LEFT) {
			paddle_move_velocity -= PADDLE_SPEED
		}

		if rl.IsKeyDown(.RIGHT) {
			paddle_move_velocity += PADDLE_SPEED
		}

		paddle_pos_x += paddle_move_velocity * dt
		paddle_pos_x = clamp(paddle_pos_x, 0, SCREEN_SIZE - PADDLE_WIDTH)


		// Drawing stuff
		rl.BeginDrawing()
		rl.ClearBackground({25, 23, 36, 255})

		camera := rl.Camera2D {
			zoom = f32(rl.GetScreenHeight()) / SCREEN_SIZE,
		}

		rl.BeginMode2D(camera)

		paddle_rect := rl.Rectangle{paddle_pos_x, PADDLE_POS_Y, PADDLE_WIDTH, PADDLE_HEIGHT}

		rl.DrawRectangleRec(paddle_rect, {49, 116, 143, 255})
		rl.DrawCircleV(ball_pos, BALL_RADIUS, {235, 111, 146, 255})
		rl.EndMode2D()
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
