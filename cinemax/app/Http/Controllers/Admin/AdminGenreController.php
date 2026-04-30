<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Genre;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AdminGenreController extends Controller
{
    // GET /api/admin/genre
    public function index()
    {
        $rows = Genre::all();

        $response = ['genres' => []];

        foreach ($rows as $g) {
            $response['genres'][] = [
                'genre_id' => $g->id,
                'name' => $g->name,
                'description' => $g->description,
            ];
        }

        return response()->json($response);
    }

    // POST /api/admin/genre
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => ['required', 'string', 'max:100', 'unique:genres,name'],
            'description' => ['required', 'string'],
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $v = $validator->valid();

        $g = new Genre();
        $g->name = $v['name'];
        $g->description = $v['description'];
        $g->save();

        return response()->json([
            'message' => 'Genre created',
            'genre_id' => $g->id
        ], 201);
    }

    // PUT /api/admin/genre/{genre_id}
    public function update(int $genre_id, Request $request)
    {
        $g = Genre::find($genre_id);

        if (!$g) {
            return response()->json(['message' => 'Genre not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => ['required', 'string', 'max:100', 'unique:genres,name,' . $genre_id],
            'description' => ['required', 'string'],
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $v = $validator->valid();

        $g->name = $v['name'];
        $g->description = $v['description'];
        $g->save();

        return response()->json([
            'message' => 'Genre updated',
            'genre_id' => $g->id
        ], 200);
    }
}