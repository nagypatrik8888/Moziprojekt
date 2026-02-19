<?php
//php artisan make:controller MovieController
//php artisan make:model Room
//TODO::ticket orders controller, + ticket order model 
namespace App\Http\Controllers;

use App\Models\Movie; //???
use Illuminate\Http\Request;
use App\Models\Price;
use App\Models\Genre;

class MovieController extends Controller //extends
{
    //
    public function index()
    {
        $movie_rows = Movie::with('genre')->get(); //lekeri adatbazisbol a movie-kat a genre-ákkal és a screening-ekkel egyutt
        //$price_rows = Price::all(); //lekerjuk adatbazisbol az osszes price tablaban levo osszes adatot
        $genre_rows = Genre::all();

        $response_for_frontend = [           //letrehozunk egy response valtozot es abban indexeket pl movie_rows aminek az erteke ures tomb lesz
            'movies' => [],
            'genres' => [],
            //'prices' => [],
        ];

        foreach ($movie_rows as $movie) //foreach ciklusban minden egyes filmen egyenkent vegigmegy
        {
            $movie_data_for_frontend = [ //letrehozunk egy tombot azokkal az adatokkal amiketr a frontendnek vissza szretnenk kuldeni
                'title' => $movie->title,
                'genre_name' => $movie->genre->name,
                'release_date' =>$movie->release_date,
                'rating' =>$movie->rating,
                'duration' => $movie ->duration_min,
                'description' => $movie ->description,

            ];


            /*foreach ($movie->screening as $screening) { //egyszerre egy moviehoz tartozo screeningjein megyunk vegig
            }*/
          
        
            $response_for_frontend['movies'][] = $movie_data_for_frontend; //response valtozon belul a movie_rows indexhez adunk hozza egy elemet 
        }

/*
        foreach ($price_rows as $price) { //soronkent vizsgaljuk a price_rows tabla elemeit

            $price_data_for_frontend=[
                'price'=>$price->price,
                'price_type'=>$price->type,
            ];

            $response_for_frontend['prices'][] = $price_data_for_frontend;
        }
*/
        foreach ($genre_rows as $genre) {

            $genre_data_for_frontend=[
                'genre_name'=>$genre->name,
            ];

            $response_for_frontend['genres'][] = $genre_data_for_frontend;
        }



        //dd($movie_rows,$price_rows,$genre_rows,$response);
        return response()->json($response_for_frontend); //json valasz kuldese a frontendnek
    }

    public function show(int $movie_id) { //itt kapjuk meg a routeban definialt parametert ami az urlbol jon

        $movie_row=Movie::where('id', $movie_id)->first(); //adatbazisbol lekerjuk id szerint a kapott parameterhez tartozo moviet
        dd($movie_id, $movie_row);
    }
}