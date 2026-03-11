@extends('layouts.admin')

@section('title', $mode === 'edit' ? 'Movies - Edit' : 'Movies - Create')

@section('content')
    @if ($errors->any())
        <div class="alert alert-danger">
            <ul>
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form
        action="{{ $mode === 'edit' ? url('/admin/movies/'.$movie->id) : url('/admin/movies') }}"
        method="POST"
        enctype="multipart/form-data"
    >
        @csrf

        @if ($mode === 'edit')
            @method('PUT')
        @endif

        <div class="form-group">
            <label for="title">Movie Title</label>
            <input
                id="title"
                type="text"
                name="title"
                value="{{ old('title', $movie->title) }}"
                class="form-control @error('title') is-invalid @enderror"
            />
        </div>

        <div class="form-group">
            <label for="genre_id">genre_id</label>
            <input
                id="genre_id"
                type="number"
                name="genre_id"
                value="{{ old('genre_id', $movie->genre_id) }}"
                class="form-control @error('genre_id') is-invalid @enderror"
            />
        </div>

        <div class="form-group">
            <label for="release_date">release_date</label>
            <input
                id="release_date"
                type="date"
                name="release_date"
                value="{{ old('release_date', $movie->release_date) }}"
                class="form-control @error('release_date') is-invalid @enderror"
            />
        </div>

        <div class="form-group">
            <label for="rating">rating</label>
            <input
                id="rating"
                type="number"
                step="0.1"
                name="rating"
                value="{{ old('rating', $movie->rating) }}"
                class="form-control @error('rating') is-invalid @enderror"
            />
        </div>

        <div class="form-group">
            <label for="duration_min">duration_min</label>
            <input
                id="duration_min"
                type="number"
                name="duration_min"
                value="{{ old('duration_min', $movie->duration_min) }}"
                class="form-control @error('duration_min') is-invalid @enderror"
            />
        </div>

        <div class="form-group">
            <label for="description">description</label>
            <textarea
                id="description"
                name="description"
                class="form-control @error('description') is-invalid @enderror"
            >{{ old('description', $movie->description) }}</textarea>
        </div>

        <div class="form-group">
            <label for="language">language</label>
            <input
                id="language"
                type="text"
                name="language"
                value="{{ old('language', $movie->language) }}"
                class="form-control @error('language') is-invalid @enderror"
            />
        </div>

        <div class="form-group">
            <label for="language_id">language_id</label>
            <input
                id="language_id"
                type="number"
                name="language_id"
                value="{{ old('language_id', $movie->language_id) }}"
                class="form-control @error('language_id') is-invalid @enderror"
            />
        </div>

        <div class="form-group">
            <label for="poster">poster</label>
            <input
                id="poster"
                type="file"
                name="poster"
                class="form-control @error('poster') is-invalid @enderror"
            />
        </div>

        @if ($mode === 'edit' && $movie->poster_url)
            <div class="mb-3">
                <p>Jelenlegi poszter:</p>
                <img src="{{ $movie->poster_url }}" alt="poster" style="max-width: 200px;">
            </div>
        @endif

        <button class="btn" type="submit">
            {{ $mode === 'edit' ? 'Módosítás' : 'Beküldés' }}
        </button>
    </form>
@endsection