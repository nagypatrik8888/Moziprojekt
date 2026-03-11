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
use App\Http\Controllers\Admin\AdminLanguageController;
use App\Http\Controllers\Admin\AdminGenreController;
use App\Http\Controllers\Admin\AdminPriceController;
use App\Http\Controllers\Admin\AdminRoomController;

Route::get('/', function (Request $request) {
    if ($request->wantsJson()) {
        return ['message' => 'Already authenticated', 'user' => auth()->user()];
    }
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

Route::get('/admin/movies/create', function () {
    return view('admin.movies.create');
})->middleware(['auth']);

Route::post('/admin/movies', [AdminFilmController::class, 'store'])->middleware(['auth']);

Route::get('/admin/screenings/create', function () {
            return view('admin.screenings.create');
        })->middleware(['auth']);

        Route::post('/admin/screenings',[AdminScreeningController::class, 'store'])->middleware(['auth']);

Route::prefix('api')->group(function () {
    Route::get('/user', function (Request $request) {
        return ['user' => auth()->user()->get_data_for_frontend()];
    })->middleware('auth:sanctum');
    Route::get('/movies', [MovieController::class, 'index']);
    Route::get('/movies/{movie_id}', [MovieController::class, 'show']); //letrehoztunk egy routeot ami fogad egy parametert, hogy a route celja hogy egy film adatait megjelenitsuk
    Route::post('/ticket_orders', [TicketOrdersController::class, 'store'])->middleware(['auth']);
    Route::get('/ticket_orders', [TicketOrdersController::class, 'index'])->middleware(['auth']); //TODO middleware, hogy csak admin nezhesse
    Route::get('/profile/ticket_orders', [ProfileTicketOrdersController::class, 'index'])->middleware(['auth']);
    Route::post('/user/login', [UserController::class, 'login']);

    // Admin API endpoints
    Route::prefix('admin')->middleware([IsAdmin::class])->group(function () {
        Route::get('/users', [AdminUserController::class, 'index']);
        Route::post('/users', [AdminUserController::class, 'store']);

        Route::get('/films', [AdminFilmController::class, 'index']);
        Route::post('/films', [AdminFilmController::class, 'store']);
        Route::put('/films/{movie_id}', [AdminFilmController::class, 'update']);

        Route::get('/screenings', [AdminScreeningController::class, 'index']);
        Route::post('/screenings', [AdminScreeningController::class, 'store']);

        Route::get('/languages', [AdminLanguageController::class, 'index']);
        Route::post('/languages', [AdminLanguageController::class, 'store']);
        Route::put('/languages/{language_id}', [AdminLanguageController::class, 'update']);

        Route::get('/genre', [AdminGenreController::class, 'index']);
        Route::post('/genre', [AdminGenreController::class, 'store']);
        Route::put('/genre/{genre_id}', [AdminGenreController::class, 'update']);

        Route::get('/prices', [AdminPriceController::class, 'index']);
        Route::post('/prices', [AdminPriceController::class, 'store']);
        Route::put('/prices/{price_id}', [AdminPriceController::class, 'update']);

        Route::get('/rooms', [AdminRoomController::class, 'index']);
        Route::post('/rooms', [AdminRoomController::class, 'store']);
        Route::put('/rooms/{room_id}', [AdminRoomController::class, 'update']);
    }); //TODO::admin role

});
//TODO::ticket orders controller, + ticket order model 
