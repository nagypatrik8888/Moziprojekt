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
        $movies = Movie::with('genre')->with('screening')->get(); //lekeri adatbazisbol a movie-kat a genre-ákkal és a screening-ekkel egyutt

        $prices = Price::all(); //lekerjuk adatbazisbol az osszes price tablaban levo osszes adatot
        $genres = Genre::all();

        $response = [           //letrehozunk egy response valtozot es abban indexeket pl movies aminek az erteke ures tomb lesz
            'movies' => [],
            'genres' => [],
            'prices' => [],
        ];

        foreach ($movies as $movie) //foreach ciklusban minden egyes filmen egyenkent vegigmegy
        {
            $movie_data_for_frontend = [ //letrehozunk egy tombot azokkal az adatokkal amiketr a frontendnek vissza szretnenk kuldeni
                'title' => $movie->title,
                'genre_name' => $movie->genre->name,
                'release_date' =>$movie->release_date,
                'rating' =>$movie->rating,
                'duration' => $movie ->duration_min,
                'description' => $movie ->description,

            ];


            foreach ($movie->screening as $screening) { //egyszerre egy moviehoz tartozo screeningjein megyunk vegig
            }
          
        
            $response['movies'][] = $movie_data_for_frontend; //response valtozon belul a movies indexhez adunk hozza egy elemet 
        }


        foreach ($prices as $price) { //soronkent vizsgaljuk a prices tabla elemeit

            $priceData=[
                'price'=>$price->price,
                'price_type'=>$price->type,
            ];

            $response['prices'][] = $priceData;
        }

        foreach ($genres as $genre) {

            $genreData=[
                'genre_name'=>$genre->name,
            ];

            $response['genres'][] = $genreData;
        }



        dd($movies,$prices,$genres,$response);
        return response()->json($response); //json valasz kuldese a frontendnek
    }
}
