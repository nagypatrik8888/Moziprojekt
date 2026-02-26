<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Movie;
use Illuminate\Http\Request;

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
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'genre_id' => ['required', 'integer', 'exists:genres,id'],

            // ezek opcionálisak (ha nálad kötelező valamelyik, szigorítjuk)
            'release_date' => ['nullable', 'date'],
            'rating' => ['nullable', 'numeric'],
            'duration_min' => ['nullable', 'integer', 'min:1'],
            'description' => ['nullable', 'string'],
        ]);

        $movie = new Movie();
        $movie->title = $validated['title'];
        $movie->genre_id = $validated['genre_id'];
        $movie->release_date = $validated['release_date'] ?? null;
        $movie->rating = $validated['rating'] ?? null;
        $movie->duration_min = $validated['duration_min'] ?? null;
        $movie->description = $validated['description'] ?? null;
        $movie->save();

        return response()->json([
            'message' => 'Film created',
            'film_id' => $movie->id,
        ], 201);
    }
}