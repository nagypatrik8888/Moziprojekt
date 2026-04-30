<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Genre;
use App\Models\Language;
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
                'poster_url' => $movie->poster_url,
            ];
        }

        return response()->json($response);
    }

    public function create_form()
    {
        return view('admin.movies.form', [
            'movie' => new Movie(),
            'mode' => 'create',
            'genres' => Genre::orderBy('name')->get(['id', 'name']),
            'languages' => Language::orderBy('name')->get(['id', 'name']),
        ]);
    }

    public function update_form($movie_id)
    {
        $movie = Movie::findOrFail($movie_id);
        return view('admin.movies.form', [
            'movie' => $movie,
            'mode' => 'edit',
            'genres' => Genre::orderBy('name')->get(['id', 'name']),
            'languages' => Language::orderBy('name')->get(['id', 'name']),
        ]);
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
            'language' => ['nullable', 'string'],
            'language_id' => ['required', 'integer', 'exists:languages,id'],
            'poster' => ['required', 'mimes:jpg,png,jpeg,webp'] //validáljuk hogy milyen fajta file

        ]);
        if ($validator->fails()) {
            if ($request->wantsJson()) {
                return response()->json($validator->errors()); //ha fail json error
            }
            return redirect()->back()->withErrors($validator)->withInput();
        }

        $validated = $validator->valid();  //ellenorizzuk letezik e a screening

        $file = $request->file('poster');
        $path = '/storage/' . $file->storePublicly('uploads', 'public');

        // Ha a frontend nem küldte a `language` szabadszöveges nevet, vegyük a languages.name-ből
        $languageName = $validated['language'] ?? null;
        if (!$languageName) {
            $languageName = Language::where('id', $validated['language_id'])->value('name') ?? '';
        }

        $movie = new Movie();
        $movie->title = $validated['title'];
        $movie->genre_id = $validated['genre_id'];
        $movie->release_date = $validated['release_date'];
        $movie->rating = $validated['rating'] ?? null;
        $movie->duration_min = $validated['duration_min'];
        $movie->description = $validated['description'];
        $movie->language = $languageName;
        $movie->language_id = $validated['language_id'];
        $movie->poster_url = $path;
        $movie->save(); //save menti el DB-be

        if ($request->wantsJson()) {
            return response()->json([
                'message' => 'Film created',
                'film_id' => $movie->id,
            ], 201);
        }

        return redirect('/admin');
    }

    public function update(int $movie_id, Request $request)
    {
        $validator = Validator::make($request->all(), [
            'title' => ['required', 'string', 'max:255'],
            'genre_id' => ['required', 'integer', 'exists:genres,id'],
            'release_date' => ['required', 'date'],
            'rating' => ['required', 'numeric'],
            'duration_min' => ['required', 'integer', 'min:1'],
            'description' => ['required', 'string'],
            'language' => ['nullable', 'string'],
            'language_id' => ['nullable', 'integer', 'exists:languages,id'],
            'poster' => ['mimes:jpg,png,jpeg,webp'] //validáljuk hogy milyen fajta file

        ]);
        if ($validator->fails()) {
            if ($request->wantsJson()) {
                return response()->json($validator->errors(), 422);
            }

            return redirect()->back()->withErrors($validator)->withInput();
        }

        $validated = $validator->valid();  //ellenorizzuk letezik e a screening

        $file = $request->file('poster');
        if ($file) {
            $path = '/storage/' . $file->storePublicly('uploads', 'public');
        }

        $movie = Movie::find($movie_id);
        $movie->title = $validated['title'];
        $movie->genre_id = $validated['genre_id'];
        $movie->release_date = $validated['release_date'];
        $movie->rating = $validated['rating'] ?? null;
        $movie->duration_min = $validated['duration_min'];
        $movie->description = $validated['description'];
        $movie->language = $validated['language'] ?? $movie->language;
        if (array_key_exists('language_id', $validated) && $validated['language_id'] !== null) {
            $movie->language_id = $validated['language_id'];
        }
        if (isset($path)) {
            $movie->poster_url = $path;
        }
        $movie->save(); //save menti el DB-be

        if ($request->wantsJson()) {
            return response()->json([
                'message' => 'Film Updated',
                'film_id' => $movie->id,
            ], 200);
        }

        return redirect('/admin');
    }
}
