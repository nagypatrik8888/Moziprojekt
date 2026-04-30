<?php

namespace App\Http\Controllers;

use App\Models\TicketOrder;
use Illuminate\Http\Request;

class ProfileTicketOrdersController extends Controller
{
    public function index()
    {
        $current_user_id = auth()->user()->id;

        $ticket_order_rows = TicketOrder::where('user_id', '=', $current_user_id)
            ->with([
                'screening.film.genre',
                'screening.room',
                'seats.seat',
            ])
            ->orderByDesc('id')
            ->get();

        $response_for_frontend = ['ticket_orders' => []];

        foreach ($ticket_order_rows as $ticket_order) {
            $screening = $ticket_order->screening;
            $film = $screening?->film;

            $seats = [];
            foreach ($ticket_order->seats as $tos) {
                $seat = $tos->seat;
                if (!$seat) {
                    continue;
                }
                $seats[] = [
                    'seat_id' => $seat->id,
                    'row_num' => $seat->row_num,
                    'column_num' => $seat->column_num,
                ];
            }

            $response_for_frontend['ticket_orders'][] = [
                'ticket_order_id' => $ticket_order->id,
                'movie_name'      => $film?->title,
                'movie_genre'     => $film?->genre?->name,
                'movie_duration'  => $film?->duration_min,
                'movie_rating'    => $film?->rating,
                'screening_date'  => $screening?->screening_date,
                'screening_time'  => $screening?->start_time,
                'room'            => $screening?->room?->screen_size,
                'total_price'     => (float) $ticket_order->total_price,
                'seats'           => $seats,
            ];
        }

        return response()->json($response_for_frontend);
    }
}
