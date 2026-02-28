<?php

namespace App\Http\Controllers;

use App\Models\TicketOrder;
use Illuminate\Http\Request;

class ProfileTicketOrdersController extends Controller
{
    //

    public function index() {
        $response_for_frontend = [
            'ticket_orders' => [],
        ];
        $current_user_id = auth()->user()->id; 
        $ticket_order_rows = TicketOrder::where('user_id','=',$current_user_id)->with(['user','screening'])->orderBy('id')->get();


        foreach($ticket_order_rows as $ticket_order) { //ciklusban elemenkent vizsgaljuk a ticket order sorokat
            $ticket_order_data_for_frontend = [
                'movie_name' => $ticket_order->screening->film->title,
                'movie_genre' => $ticket_order->screening->film->genre->name,
                'movie_duration' => $ticket_order->screening->film->duration_min,
                'movie_rating' => $ticket_order->screening->film->rating,
                'screening_date' => $ticket_order->screening->screening_date,
                'screening_time' => $ticket_order->screening->screening_time,
                'total_price' => $ticket_order->screening->total_price,
                'ticket_type' => $ticket_order->price->type,
            ];

            $response_for_frontend['ticket_orders'][] = $ticket_order_data_for_frontend;
        }


        return response()->json($response_for_frontend);
    }
}
