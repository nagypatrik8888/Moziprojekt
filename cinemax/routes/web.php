<?php

use App\Http\Controllers\MovieController;
use Illuminate\Support\Facades\Route;


Route::get('/', function () {
    return view('welcome');
});


Route::get('/movies', [MovieController::class, 'index']);



//TODO::ticket orders controller, + ticket order model 