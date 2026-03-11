@extends('layouts.admin')
@section('film_id', 'Movies - Create')

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

<form action="/admin/screenings" method="POST" enctype='multipart/form-data'>
    @csrf
    <div class="form-group">

        <label for="film_id">Film id</label>

        <input
            id="film_id"
            type="number"
            name="film_id"
            value="{{ old('film_id') }}"
            class="form-control @error('film_id') is-invalid @enderror" />
    </div>

    <div class="form-group">

        <label for="room_id">Room id</label>

        <input
            id="room_id"
            type="number"
            name="room_id"
            value="{{ old('room_id') }}"
            class="form-control @error('room_id') is-invalid @enderror" />
    </div>
    <div class="form-group">

        <label for="screening_date">Screening date</label>

        <input
            id="screening_date"
            type="text"
            name="screening_date"
            value="{{ old('screening_date') }}"
            class="form-control @error('screening_date') is-invalid @enderror" />
    </div>
    <div class="form-group">

        <label for="start_time">Start time</label>

        <input
            id="start_time"
            type="text"
            name="start_time"
            value="{{ old('start_time') }}"
            class="form-control @error('start_time') is-invalid @enderror" />
    </div>

    <button class="btn" type="submit">Beküldés</button>
</form>
@endsection