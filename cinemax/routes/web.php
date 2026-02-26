<?php


use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AdminFilmController;
use App\Http\Controllers\Admin\AdminScreeningController;
use App\Http\Controllers\Admin\AdminUserController;
use App\Http\Controllers\MovieController;
use App\Http\Controllers\TicketOrdersController;
use App\Http\Controllers\ProfileTicketOrdersController;
use App\Http\Controllers\UserController;
use App\Http\Middleware\IsAdmin;
use Illuminate\Http\Request;


Route::get('/', function () {
    return view('home');
});


Route::get('/movies', function () {
    return view('movies');
});

Route::get('/about', function () {
    return view('about');
});

Route::get('/login', function () {
    return view('login');
});

Route::get('/bookings', function () {
    return view('bookings');
})->middleware(['auth']);

Route::get('/admin', function () {
    return view('admin');
})->middleware(['auth']);

Route::get('/profile', function () {
    return view('profile');
})->middleware(['auth']);



Route::prefix('api')->middleware([IsAdmin::class])->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    })->middleware('auth:sanctum');
    Route::get('/movies', [MovieController::class, 'index']);
    Route::get('/movies/{movie_id}', [MovieController::class, 'show']); //letrehoztunk egy routeot ami fogad egy parametert, hogy a route celja hogy egy film adatait megjelenitsuk
    Route::post('/ticket_orders', [TicketOrdersController::class, 'store'])->middleware(['auth']);
    Route::get('/ticket_orders', [TicketOrdersController::class, 'index'])->middleware(['auth']); //TODO middleware, hogy csak admin nezhesse
    Route::get('/profile/ticket_orders', [ProfileTicketOrdersController::class, 'index'])->middleware(['auth']);
    Route::post('/user/login', [UserController::class, 'login']);

    // Admin API endpoints
    Route::prefix('admin')->group(function () {
        Route::get('/users', [AdminUserController::class, 'index']);
        Route::post('/users', [AdminUserController::class, 'store']);

        Route::get('/films', [AdminFilmController::class, 'index']);
        Route::post('/films', [AdminFilmController::class, 'store']);

        Route::get('/screenings', [AdminScreeningController::class, 'index']);
        Route::post('/screenings', [AdminScreeningController::class, 'store']);
    }); //TODO::admin role

});
//TODO::ticket orders controller, + ticket order model 
