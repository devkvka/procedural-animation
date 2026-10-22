package main

import "core:fmt"
import "core:math/linalg"
import rl "vendor:raylib"

SCREEN_SIZE_X :: 1500
SCREEN_SIZE_Y :: 1200

POINT_COUNT :: 100
DISTANCE_BETWEEN_PTS :: 15
HEAD_POINT_SIZE :: 15
NECK_POINT_SIZE :: 10
BODY_POINT_SIZE :: 5

Point :: struct {
    pos: [2]f64,
    r: f64,
}

Chain :: struct {
    first: Point,
    tail: [dynamic]Point, 
}

update :: proc(ch: ^Chain) {
    unit := linalg.normalize(ch.tail[0].pos - ch.first.pos)
    ch.tail[0].pos = ch.first.pos + unit * ch.first.r

    for i := 1; i < len(ch.tail); i += 1 {
        unit := linalg.normalize(ch.tail[i].pos - ch.tail[i-1].pos)
        ch.tail[i].pos = ch.tail[i-1].pos + unit * ch.tail[i-1].r
    }
}

draw :: proc(ch: ^Chain) {
    rl.DrawCircle(i32(ch.first.pos.x), i32(ch.first.pos.y), HEAD_POINT_SIZE, rl.WHITE)
    rl.DrawLine(i32(ch.first.pos.x), i32(ch.first.pos.y), i32(ch.tail[0].pos.x), i32(ch.tail[0].pos.y), rl.WHITE)
    rl.DrawCircle(i32(ch.tail[0].pos.x), i32(ch.tail[0].pos.y), NECK_POINT_SIZE, rl.WHITE)

    for i := 1; i < len(ch.tail); i += 1 {
        rl.DrawCircle(i32(ch.tail[i].pos.x), i32(ch.tail[i].pos.y), BODY_POINT_SIZE, rl.WHITE)
        rl.DrawLine(i32(ch.tail[i].pos.x), i32(ch.tail[i].pos.y), i32(ch.tail[i-1].pos.x), i32(ch.tail[i-1].pos.y), rl.WHITE)
    }
}

main :: proc() {
    ch := Chain {
        first = Point{{300, 300}, DISTANCE_BETWEEN_PTS},
        tail = [dynamic]Point{},
    }

    for i := 1; i < POINT_COUNT; i += 1 {
        append(&ch.tail, Point {
            {300+10*f64(i), 300+20*f64(i)}, DISTANCE_BETWEEN_PTS
        })
    }

    rl.InitWindow(SCREEN_SIZE_X, SCREEN_SIZE_Y, "Procedural animation")

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.GRAY)

        if rl.IsKeyPressed(.ZERO) {
            rl.ToggleBorderlessWindowed()
        }

        mouse := rl.GetMousePosition()
        ch.first.pos.x = f64(mouse.x)
        ch.first.pos.y = f64(mouse.y)

        update(&ch)
        draw(&ch)

        rl.EndDrawing()
    }
}
