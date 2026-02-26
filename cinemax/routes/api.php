<?php
use App\Http\Controllers\Admin\AdminFilmController;
use App\Http\Controllers\Admin\AdminScreeningController;
use App\Http\Controllers\Admin\AdminUserController;
use App\Http\Controllers\MovieController;
use App\Http\Controllers\TicketOrdersController;
use App\Http\Controllers\ProfileTicketOrdersController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;


Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');
Route::get('/movies', [MovieController::class, 'index']);
Route::get('/movies/{movie_id}', [MovieController::class, 'show']); //letrehoztunk egy routeot ami fogad egy parametert, hogy a route celja hogy egy film adatait megjelenitsuk
Route::post('/ticket_orders', [TicketOrdersController::class, 'store']);
Route::get('/ticket_orders', [TicketOrdersController::class, 'index']); //TODO middleware, hogy csak admin nezhesse
Route::get('/profile/ticket_orders', [ProfileTicketOrdersController::class, 'index']);
// Admin API endpoints
Route::prefix('admin')->group(function () {
    Route::get('/users', [AdminUserController::class, 'index']);
    Route::post('/users', [AdminUserController::class, 'store']);

    Route::get('/films', [AdminFilmController::class, 'index']);
    Route::post('/films', [AdminFilmController::class, 'store']);

    Route::get('/screenings', [AdminScreeningController::class, 'index']);
    Route::post('/screenings', [AdminScreeningController::class, 'store']);
});