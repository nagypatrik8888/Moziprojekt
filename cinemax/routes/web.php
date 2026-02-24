<?php


use Illuminate\Support\Facades\Route;


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
});

Route::get('/admin', function () {
    return view('admin');
});

Route::get('/profile', function () {
    return view('profile');
});

//TODO::ticket orders controller, + ticket order model 