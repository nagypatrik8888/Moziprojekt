<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{
    //

    /**
     * 
     */
    public function login(Request $request) {
        $response_for_frontend = [];
        $validator = Validator::make($request->all(),[
            'email' => ['required', 'email', 'max:255', 'exists:users,email'],
            'password' => ['required'],
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors()); //ha fail json error
        }

        $validated = $validator->valid();  //ellenorizzuk letezik e a screening


        return response()->json($response_for_frontend);
        
    }
}
