<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Movie;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AdminFilmController extends Controller
{
    public function index()
    {
        // lista a már meglévő mintára, genre-rel együtt
        $movie_rows = Movie::with('genre')->get();

        $response = [
            'films' => [],
        ];

        foreach ($movie_rows as $movie) {
            $response['films'][] = [
                'film_id' => $movie->id,
                'title' => $movie->title,
                'genre' => $movie->genre ? [
                    'genre_id' => $movie->genre->id,
                    'name' => $movie->genre->name,
                ] : null,
                'release_date' => $movie->release_date ?? null,
                'rating' => $movie->rating ?? null,
                'duration_min' => $movie->duration_min ?? null,
                'description' => $movie->description ?? null,
            ];
        }

        return response()->json($response);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'title' => ['required', 'string', 'max:255'],
            'genre_id' => ['required', 'integer', 'exists:genres,id'],
            'release_date' => ['required', 'date'],
            'rating' => ['required', 'numeric'],
            'duration_min' => ['required', 'integer', 'min:1'],
            'description' => ['required', 'string'],
            'language' => ['required', 'string'],
            'language_id' => ['required', 'integer', 'exists:languages,id'],
            'poster_url' => ['required', 'string','url:http,https']

        ]);
         if ($validator->fails()) {
            return response()->json($validator->errors()); //ha fail json error
        }

        $validated = $validator->valid();  //ellenorizzuk letezik e a screening

        $movie = new Movie();
        $movie->title = $validated['title'];
        $movie->genre_id = $validated['genre_id'];
        $movie->release_date = $validated['release_date'];
        $movie->rating = $validated['rating'] ?? null;
        $movie->duration_min = $validated['duration_min'];
        $movie->description = $validated['description'];
        $movie->language = $validated['language'];
        $movie->language_id = $validated['language_id'];
        $movie->poster_url = $validated['poster_url'];
        $movie->save(); //save menti el DB-be

        return response()->json([
            'message' => 'Film created',
            'film_id' => $movie->id,
        ], 201);
    }
}