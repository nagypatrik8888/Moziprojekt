<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Room;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AdminRoomController extends Controller
{
    // GET /api/admin/rooms
    public function index()
    {
        $rows = Room::all();

        $response = ['rooms' => []];

        foreach ($rows as $r) {
            $response['rooms'][] = [
                'room_id' => $r->id,
                'screen_size' => $r->screen_size,
                'sound_system' => $r->sound_system,
            ];
        }

        return response()->json($response);
    }

    // POST /api/admin/rooms
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'screen_size' => ['required', 'string', 'max:20'],
            'sound_system' => ['required', 'string'],
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $v = $validator->valid();

        $r = new Room();
        $r->screen_size = $v['screen_size'];
        $r->sound_system = $v['sound_system'];
        $r->save();

        return response()->json([
            'message' => 'Room created',
            'room_id' => $r->id
        ], 201);
    }

    // PUT /api/admin/rooms/{room_id}
    public function update(int $room_id, Request $request)
    {
        $r = Room::find($room_id);

        if (!$r) {
            return response()->json(['message' => 'Room not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'screen_size' => ['required', 'string', 'max:20'],
            'sound_system' => ['required', 'string'],
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $v = $validator->valid();

        $r->screen_size = $v['screen_size'];
        $r->sound_system = $v['sound_system'];
        $r->save();

        return response()->json([
            'message' => 'Room updated',
            'room_id' => $r->id
        ], 200);
    }
}