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

            'screening_date' => ['required', 'date'],
            'start_time' => ['required', 'date_format:H:i:s'],
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors()); //ha fail json error
        }

        $validated = $validator->valid();  //ellenorizzuk letezik e a screening

        $screening = new Screening();
        $screening->film_id = $validated['film_id'];
        $screening->room_id = $validated['room_id'];
        $screening->screening_date = $validated['screening_date'];
        $screening->start_time = $validated['start_time'];
        $screening->save();

        return response()->json([
            'message' => 'Screening created',
            'screening_id' => $screening->id,
        ], 201);
    }
}