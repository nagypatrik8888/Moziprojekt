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
            <label for="title">Cím <span class="text-danger" aria-hidden="true">*</span></label>
            <input
                id="title"
                type="text"
                name="title"
                value="{{ old('title', $movie->title) }}"
                class="form-control @error('title') is-invalid @enderror"
                required
            />
        </div>

        <div class="form-group">
            <label for="genre_id">Műfaj <span class="text-danger" aria-hidden="true">*</span></label>
            <select
                id="genre_id"
                name="genre_id"
                class="form-control @error('genre_id') is-invalid @enderror"
                required
            >
                <option value="">– válassz –</option>
                @foreach ($genres as $g)
                    <option value="{{ $g->id }}" @selected(old('genre_id', $movie->genre_id) == $g->id)>
                        {{ $g->name }}
                    </option>
                @endforeach
            </select>
        </div>

        <div class="form-group">
            <label for="release_date">Megjelenés dátuma <span class="text-danger" aria-hidden="true">*</span></label>
            <input
                id="release_date"
                type="date"
                name="release_date"
                value="{{ old('release_date', $movie->release_date) }}"
                class="form-control @error('release_date') is-invalid @enderror"
                required
            />
        </div>

        <div class="form-group">
            <label for="rating">Értékelés (0–10) <span class="text-danger" aria-hidden="true">*</span></label>
            <input
                id="rating"
                type="number"
                step="0.1"
                min="0"
                max="10"
                name="rating"
                value="{{ old('rating', $movie->rating) }}"
                class="form-control @error('rating') is-invalid @enderror"
                required
            />
        </div>

        <div class="form-group">
            <label for="duration_min">Hossz (perc) <span class="text-danger" aria-hidden="true">*</span></label>
            <input
                id="duration_min"
                type="number"
                min="1"
                name="duration_min"
                value="{{ old('duration_min', $movie->duration_min) }}"
                class="form-control @error('duration_min') is-invalid @enderror"
                required
            />
        </div>

        <div class="form-group">
            <label for="description">Leírás <span class="text-danger" aria-hidden="true">*</span></label>
            <textarea
                id="description"
                name="description"
                rows="3"
                class="form-control @error('description') is-invalid @enderror"
                required
            >{{ old('description', $movie->description) }}</textarea>
        </div>

        <div class="form-group">
            <label for="language_id">Nyelv {!! $mode === 'create' ? '<span class="text-danger" aria-hidden="true">*</span>' : '' !!}</label>
            <select
                id="language_id"
                name="language_id"
                class="form-control @error('language_id') is-invalid @enderror"
                {{ $mode === 'create' ? 'required' : '' }}
            >
                <option value="">– válassz –</option>
                @foreach ($languages as $l)
                    <option value="{{ $l->id }}" @selected(old('language_id', $movie->language_id) == $l->id)>
                        {{ $l->name }}
                    </option>
                @endforeach
            </select>
        </div>

        {{-- Legacy szabadszöveges nyelv mező — a select-tel szinkronban tartjuk JS-ben --}}
        <input
            id="language"
            type="hidden"
            name="language"
            value="{{ old('language', $movie->language ?? '') }}"
        />

        <div class="form-group">
            <label for="poster">
                Poszter
                @if ($mode === 'create')
                    <span class="text-danger" aria-hidden="true">*</span>
                @endif
            </label>
            <input
                id="poster"
                type="file"
                name="poster"
                accept="image/*"
                class="form-control @error('poster') is-invalid @enderror"
                {{ $mode === 'create' ? 'required' : '' }}
            />
            <small class="text-muted">JPG / PNG / JPEG / WEBP{{ $mode === 'edit' ? ' — csak akkor töltsd fel, ha cserélni szeretnéd' : '' }}.</small>
        </div>

        @if ($mode === 'edit' && $movie->poster_url)
            <div class="mb-3">
                <p class="mb-1">Jelenlegi poszter:</p>
                <img src="{{ $movie->poster_url }}" alt="poster" style="max-width: 200px;">
            </div>
        @endif

        <button class="btn btn-cmx-gold px-4 py-2 fw-bold" type="submit">
            <i class="bi {{ $mode === 'edit' ? 'bi-check2-circle' : 'bi-plus-circle' }}"></i>
            {{ $mode === 'edit' ? 'Módosítás mentése' : 'Film létrehozása' }}
        </button>
    </form>

    <script>
        // A nyelv-select kiválasztott option szövegét visszaírjuk a hidden `language` mezőbe,
        // hogy a régi backend mező továbbra is megkapja a megfelelő értéket.
        (function () {
            const sel = document.getElementById('language_id');
            const lang = document.getElementById('language');
            if (!sel || !lang) return;
            const sync = () => {
                const opt = sel.options[sel.selectedIndex];
                lang.value = opt && opt.value ? opt.text : '';
            };
            sel.addEventListener('change', sync);
            sync();
        })();
    </script>
@endsection
