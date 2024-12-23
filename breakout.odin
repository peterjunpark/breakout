package breakout

import "core:fmt"
import rl "vendor:raylib"

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(1280, 1280, "Breakout!")
	rl.SetTargetFPS(500)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({150, 190, 220, 255})
		rl.EndDrawing()
	}
	rl.CloseWindow()
}
