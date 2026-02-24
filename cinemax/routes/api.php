<?php
use App\Http\Controllers\MovieController;
use App\Http\Controllers\TicketOrdersController;
use App\Http\Controllers\ProfileTicketOrdersController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');
Route::get('/movies', [MovieController::class, 'index'])->middleware(['auth:sanctum']); ;
Route::get('/movies/{movie_id}', [MovieController::class, 'show']); //letrehoztunk egy routeot ami fogad egy parametert, hogy a route celja hogy egy film adatait megjelenitsuk
Route::post('/ticket_orders', [TicketOrdersController::class, 'store']);
Route::get('/ticket_orders', [TicketOrdersController::class, 'index'])->middleware(['auth:sanctum']); //TODO middleware, hogy csak admin nezhesse
Route::get('/profile/ticket_orders', [ProfileTicketOrdersController::class, 'index']);