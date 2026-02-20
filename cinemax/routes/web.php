<?php

use App\Http\Controllers\MovieController;
use Illuminate\Support\Facades\Route;


Route::get('/', function () {
    return view('welcome');
});


Route::get('/movies', [MovieController::class, 'index']);
Route::get('/movies/{movie_id}', [MovieController::class, 'show']); //letrehoztunk egy routeot ami fogad egy parametert, hogy a route celja hogy egy film adatait megjelenitsuk



//TODO::ticket orders controller, + ticket order model 