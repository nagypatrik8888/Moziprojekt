@extends('layouts.admin')
@section('title', 'Új vetítési időpont')

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

<form action="/admin/screenings" method="POST" enctype="multipart/form-data">
    @csrf

    <div class="form-group">
        <label for="film_id">Film <span class="text-danger" aria-hidden="true">*</span></label>
        <select id="film_id" name="film_id" class="form-control @error('film_id') is-invalid @enderror" required>
            <option value="">– válassz filmet –</option>
            @foreach ($movies as $m)
                <option value="{{ $m->id }}" @selected(old('film_id') == $m->id)>
                    {{ $m->title }}
                </option>
            @endforeach
        </select>
    </div>

    <div class="form-group">
        <label for="room_id">Terem <span class="text-danger" aria-hidden="true">*</span></label>
        <select id="room_id" name="room_id" class="form-control @error('room_id') is-invalid @enderror" required>
            <option value="">– válassz termet –</option>
            @foreach ($rooms as $r)
                <option value="{{ $r->id }}" @selected(old('room_id') == $r->id)>
                    {{ $r->screen_size }} — {{ $r->sound_system }}
                </option>
            @endforeach
        </select>
    </div>

    <div class="form-group">
        <label for="screening_date">Vetítés dátuma <span class="text-danger" aria-hidden="true">*</span></label>
        <input
            id="screening_date"
            type="date"
            name="screening_date"
            min="{{ date('Y-m-d') }}"
            value="{{ old('screening_date') }}"
            class="form-control @error('screening_date') is-invalid @enderror"
            required
        />
    </div>

    <div class="form-group">
        <label for="start_time">Kezdés időpontja <span class="text-danger" aria-hidden="true">*</span></label>
        <input
            id="start_time"
            type="time"
            step="60"
            name="start_time"
            value="{{ old('start_time') }}"
            class="form-control @error('start_time') is-invalid @enderror"
            required
        />
    </div>

    <button class="btn btn-cmx-gold px-4 py-2 fw-bold" type="submit">
        <i class="bi bi-plus-circle"></i> Vetítés létrehozása
    </button>
</form>
@endsection
