<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TicketOrdersController extends Controller
{
    public function store(Request $request){
        $response_for_frontend=[];

        $validator = Validator::make($request->all(),[
            'movie_id' => 'required|integer',
            'screening_id' => 'required|integer',
            'seats.*.seat_id' => 'required|integer',
            'seats.*.price_id' => 'required|integer',
        ]);

        if($validator->fails()){
            return response()->json($validator->errors());
        }

        $validated = $validator->valid();

        //dd($validated);
                              
        return response()->json($validated);
    }
}
