<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Screening;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;


class AdminScreeningController extends Controller
{
    public function index()
    {
        // Lista: film + genre + room együtt (átlátható admin listához)
        $screening_rows = Screening::with(['film.genre', 'room'])->get();

        $response = [
            'screenings' => [],
        ];

        foreach ($screening_rows as $screening) {
            $response['screenings'][] = [
                'screening_id' => $screening->id,

                'film' => $screening->film ? [
                    'film_id' => $screening->film->id,
                    'title' => $screening->film->title,
                    'genre' => $screening->film->genre ? [
                        'genre_id' => $screening->film->genre->id,
                        'name' => $screening->film->genre->name,
                    ] : null,
                ] : null,

                'room' => $screening->room ? [
                    'room_id' => $screening->room->id,
                    'name' => $screening->room->name ?? null,
                ] : null,

                // ezek a mezők nálad a DB-ben lehetnek kicsit más néven,
                // de alap mintának jó
                'screening_date' => $screening->screening_date ?? null,
                'start_time' => $screening->start_time ?? null,
            ];
        }

        return response()->json($response);
    }

    public function store(Request $request)
    {
        
        $validator = Validator::make($request->all(), [
            'film_id' => ['required', 'integer', 'exists:films,id'],
            'room_id' => ['required', 'integer', 'exists:rooms,id'],

            'screening_date' => ['required', 'date', 'after_or_equal:today'],
            'start_time' => ['required', 'date_format:H:i'],
        ]);

        if ($validator->fails()) {
            if($request->wantsJson()){
                return response()->json(['errors' => $validator->errors()], 422); //ha fail json error
            }
            return redirect()->back()->withErrors($validator)->withInput();
        }

        $validated = $validator->valid();  //ellenorizzuk letezik e a screening

        // Ütközés-ellenőrzés: ne lehessen ugyanarra a teremre + dátumra + idősávra két vetítés
        $conflict = Screening::where('room_id', $validated['room_id'])
            ->where('screening_date', $validated['screening_date'])
            ->where('start_time', $validated['start_time'].':00')
            ->exists();
        if ($conflict) {
            $msg = 'Erre a teremre és időpontra már van vetítés.';
            if ($request->wantsJson()) {
                return response()->json(['errors' => ['start_time' => [$msg]]], 409);
            }
            return redirect()->back()->withErrors(['start_time' => $msg])->withInput();
        }

        $screening = new Screening();
        $screening->film_id = $validated['film_id'];
        $screening->room_id = $validated['room_id'];
        $screening->screening_date = $validated['screening_date'];
        $screening->start_time = $validated['start_time'].':00';
        $screening->save();
         if($request->wantsJson()){
            return response()->json([
                'message' => 'Screening created',
            'screening_id' => $screening->id,
            ], 201);
        }

        return redirect('/admin');
    }
}