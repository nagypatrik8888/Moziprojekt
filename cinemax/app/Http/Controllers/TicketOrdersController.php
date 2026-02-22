<?php

namespace App\Http\Controllers;

use App\Models\TicketOrder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TicketOrdersController extends Controller
{

    public function index()
    {
        $order_rows = TicketOrder::with([
            'user',
            'price',
            'seats'
        ])
            ->orderByDesc('created_at')
            ->get();

        $response_for_frontend = [
            'ticket_orders' => [],
        ];


        foreach ($order_rows as $ticket_order) {

            $ticket_data_for_frontend = [
                'screening_id' => $ticket_order->screening_id,
                'total_price' => $ticket_order->total_price,
                'user_id' => $ticket_order->user_id,
                'user_name'=>$ticket_order->user->name,
                'seats' => [],
            ];        

            foreach($ticket_order->seats as $ticket_order_seat){
                $ticket_order_seat_data_for_frontend = [
                    'seat_id' => $ticket_order_seat->seat_id,
                    'row_num' => $ticket_order_seat->seat->row_num,
                    'column_num' => $ticket_order_seat->seat->column_num,
                ];

                $ticket_data_for_frontend['seats'][] = $ticket_order_seat_data_for_frontend;
            }

            $response_for_frontend['ticket_orders'][] = $ticket_data_for_frontend;
        }


        return response()->json($response_for_frontend);
    }


    public function store(Request $request)
    {

        $response_for_frontend = [];

        $validator = Validator::make($request->all(), [
            'movie_id' => 'required|integer',
            'screening_id' => 'required|integer',
            'seats.*.seat_id' => 'required|integer',
            'seats.*.price_id' => 'required|integer',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors());
        }

        $validated = $validator->valid();

        return response()->json($validated);
    }
}
