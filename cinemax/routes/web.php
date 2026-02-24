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

//TODO::ticket orders controller, + ticket order model 