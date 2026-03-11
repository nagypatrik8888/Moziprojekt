@extends('layouts.admin')
@section('title', 'Movies - Create')

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

<form action="/admin/movies" method="POST" enctype='multipart/form-data'>
    @csrf
    <div class="form-group">

        <label for="title">Movie Title</label>

        <input
            id="title"
            type="text"
            name="title"
            value="{{ old('title') }}"
            class="form-control @error('title') is-invalid @enderror" />
    </div>

    <div class="form-group">

        <label for="genre_id">genre_id</label>

        <input
            id="genre_id"
            type="number"
            name="genre_id"
            value="{{ old('genre_id') }}"
            class="form-control @error('genre_id') is-invalid @enderror" />
    </div>
    <div class="form-group">

        <label for="release_date">release_date</label>

        <input
            id="release_date"
            type="text"
            name="release_date"
            value="{{ old('release_date') }}"
            class="form-control @error('release_date') is-invalid @enderror" />
    </div>
    <div class="form-group">

        <label for="rating">rating</label>

        <input
            id="rating"
            type="number"
            name="rating"
            value="{{ old('rating') }}"
            class="form-control @error('rating') is-invalid @enderror" />
    </div>
    <div class="form-group">

        <label for="duration_min">duration_min</label>

        <input
            id="duration_min"
            type="number"
            name="duration_min"
            value="{{ old('duration_min') }}"
            class="form-control @error('duration_min') is-invalid @enderror" />
    </div>
    <div class="form-group">

        <label for="description">description</label>

        <input
            id="description"
            type="textarea"
            name="description"
            value="{{ old('description') }}"
            class="form-control @error('description') is-invalid @enderror" />
    </div>
    <div class="form-group">

        <label for="language">language</label>


        <input
            id="language"
            type="text"
            name="language"
            value="{{ old('language') }}"
            class="form-control @error('language') is-invalid @enderror" />
    </div>
    <div class="form-group">

        <label for="language_id">language_id</label>

        <input
            id="language_id"
            type="number"
            name="language_id"
            value="{{ old('language_id') }}"
            class="form-control @error('language_id') is-invalid @enderror" />
    </div>
    <div class="form-group">

        <label for="poster">poster</label>
        <input type="file" name="poster">
    </div>

    <button class="btn" type="submit">Beküldés</button>
</form>
@endsection