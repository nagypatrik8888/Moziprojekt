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
        $movies = Movie::with('genre')->with('screening')->get(); //with szerepe
        $prices = Price::all();
        $genres = Genre::all();

        $response = [
            'movies' => [],
            'genres' => [],
            'prices' => [],
        ];

        foreach ($movies as $movie) //movies as??? movie
        {
            $movieData = [
                'title' => $movie->title,
                'genre_name' => $movie->genre->name,
                'release_date' =>$movie->release_date,
                'rating' =>$movie->rating,
                'duration' => $movie ->duration_min,
                'description' => $movie ->description,

            ];

            echo $movie->title . ' - ' . $movie->release_date . " - " .  "\n";
            echo $movie->genre->name . ' - ' . "\n";
            echo $movie->duration_min . ' - ' . "\n";

            foreach ($movie->screening as $screening) {
                echo $screening->start_time . "\t";
            }
          
            $response['movies'][] = $movieData;
        }

        foreach ($prices as $price) {
            echo $price->type . ' - ' .$price->price. ' - ' . "\n";

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

           echo $genre->name . ' - ' . "\n";

            $response['genres'][] = $genreData;
        }



        //dd($movies,$prices,$genres,$response);
        return response()->json($response);
    }
}
