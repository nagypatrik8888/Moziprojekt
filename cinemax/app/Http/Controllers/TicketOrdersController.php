<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class TicketOrdersController extends Controller
{
    public function store(){
        $response_for_frontend=[];
        return response()->json($response_for_frontend);
    }
}
