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
                'movie_id'=> $movie->id,
                'genre_name' => $movie->genre->name,
                'release_date' =>$movie->release_date,
                'rating' =>$movie->rating,
                'duration' => $movie ->duration_min,
                'description' => $movie ->description,

            ];


            /*foreach ($movie->screening as $screening) { //egyszerre egy moviehoz tartozo screeningjein megyunk vegig
            }*/
          
        
            $response_for_frontend['movies'][] = $movie_data_for_frontend; //response valtozon belul a movies indexhez adunk hozza egy elemet 
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

        $movie_row = Movie::where('id', $movie_id)->with('future_screenings')->with('genre')->first(); //adatbazisbol lekerjuk id szerint a kapott parameterhez tartozo moviet
        $price_rows = Price::all(); //lekerjuk adatbazisbol az osszes price tablaban levo osszes adatot

        $response_for_frontend = [           //letrehozunk egy response valtozot es abban indexeket pl movie_rows aminek az erteke ures tomb lesz
            'movie' => [],
            'prices' => [],
        ];

       
            $movie_data_for_frontend = [ //letrehozunk egy tombot azokkal az adatokkal amiketr a frontendnek vissza szretnenk kuldeni
                'title' => $movie_row->title,
                'movie_id'=> $movie_row->id,
                'genre_name' => $movie_row->genre->name,
                'release_date' =>$movie_row->release_date,
                'rating' =>$movie_row->rating,
                'duration' => $movie_row ->duration_min,
                'description' => $movie_row ->description,
                'screenings' => [],

            ];


            foreach ($movie_row->future_screenings as $screening) { //egyszerre egy moviehoz tartozo screeningjein megyunk vegig

                $screening_data_for_frontend=[
                    'screening_id'=>$screening->id,
                    'start_time'=>$screening->start_time,
                    'start_date'=>$screening->screening_date,
                    'room'=>[],
                    
                    
                    //székeket átadni 
                    //Melyik szobábában van a vetítés, és ott milyen székek vannak
                ];

                $room_data_for_frontend = [
                    'screen_size' => $screening->room->screen_size,
                    'seats'=>[],
                ];

                foreach ($screening->room->seats as $seat){
                    $seat_data_for_frontend=[
                        'seat_id' => $seat->id,
                        'row' => $seat->row_num,
                        'column' => $seat->column_num,
                    ];
                    
                    $room_data_for_frontend['seats'][]=$seat_data_for_frontend;

                }

                $screening_data_for_frontend['room'] = $room_data_for_frontend;

                 $movie_data_for_frontend['screenings'][] = $screening_data_for_frontend;

            }
          
        
            $response_for_frontend['movie'] = $movie_data_for_frontend; //a response változó movie indexének adunk értéket
        


        foreach ($price_rows as $price) { //soronkent vizsgaljuk a price_rows tabla elemeit

            $price_data_for_frontend=[
                'price'=>$price->price,
                'price_id'=>$price->id,
                'price_type'=>$price->type,
            ];

            $response_for_frontend['prices'][] = $price_data_for_frontend;
        }

        //dd($movie_rows,$price_rows,$genre_rows,$response);
        return response()->json($response_for_frontend); //json valasz kuldese a frontendnek
        dd($movie_id, $movie_row);

    }
}