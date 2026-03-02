<?php

namespace App\Http\Controllers;

use App\Models\Screening;
use App\Models\Seat;
use App\Models\Price;
use App\Models\TicketOrder;
use App\Models\TicketOrderSeat;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TicketOrdersController extends Controller
{

    public function index()
    {
        $order_rows = TicketOrder::with([ //lekérjük az osszes rendelést a kapcsolódó adatokkal
            'user',
            'price',
            'seats'
        ])
            ->orderByDesc('created_at')
            ->get();

        $response_for_frontend = [ //valtozo, bele index aminek a megadott erteke tomb 
            'ticket_orders' => [],
        ];


        foreach ($order_rows as $ticket_order) {

            $ticket_data_for_frontend = [ //vegigmegyunk a rendeleseket soronkent vizsgaljuk oket, majd a szukseges mezoket kicsomagoljuk
                'ticket_order_id' => $ticket_order->id,
                'screening_id' => $ticket_order->screening_id,
                'total_price' => $ticket_order->total_price,
                'user_id' => $ticket_order->user_id,
                'user_name'=>$ticket_order->user->name,
                'seats' => [],
            ];        

            foreach($ticket_order->seats as $ticket_order_seat){ // atadjuk a rendeleshez tartozo szekeket sor/oszlop
                $ticket_order_seat_data_for_frontend = [
                    'seat_id' => $ticket_order_seat->seat_id,
                    'row_num' => $ticket_order_seat->seat->row_num,
                    'column_num' => $ticket_order_seat->seat->column_num,
                ];

                $ticket_data_for_frontend['seats'][] = $ticket_order_seat_data_for_frontend; //seatt adatokat betoltjuk elemenkent tombbe
            }

            $response_for_frontend['ticket_orders'][] = $ticket_data_for_frontend;
        }


        return response()->json($response_for_frontend); //kuldjuk vissza json formatumban a frontendnek
    }


    public function store(Request $request)
    {

        $response_for_frontend = []; 

        $validator = Validator::make($request->all(), [ //validaljuk a bejovo adatokat, mind kotelezo, egesz szam
            'screening_id' => 'required|integer',
            'seats.*.seat_id' => 'required|integer',
            'seats.*.price_id' => 'required|integer',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors()); //ha fail json error
        }

        $validated = $validator->valid();  //ellenorizzuk letezik e a screening
        $screening_row = Screening::where('id','=',$validated['screening_id'])->first();
        if(!$screening_row){ //Ha nincs ilyen screening akkor hibát jelzünk 
            return response()->json(['errors'=> ['Screening was not found!']]);
        }

        $total_price = 0; //ki kell számolni
        $erros = [];
        foreach($validated['seats'] as $seat) {
            $seat_row = Seat::where('id','=',$seat['seat_id'])->first();
            $price_row = Price::where('id','=',$seat['price_id'])->first();
            if(!$seat_row){
                $erros[] = 'Seat was not found: ' . $seat['seat_id'];
            }
            if(!$price_row){
                $erros[] = 'Price was not found: ' . $seat['price_id'];
            }

            $ticketOrderSeatOccupied = TicketOrderSeat::where([
                ['screening_id','=',$validated['screening_id']],
                ['seat_id','=',$seat_row->id]
            ])->exists();

            if($ticketOrderSeatOccupied){
                $erros[] = 'Seat occupied';
            }

            if(!$seat_row || !$price_row || $ticketOrderSeatOccupied){
                continue;
            }

            $total_price = $total_price + $price_row->price;
            
        }

        if(!empty($erros)){
            return response()->json(['errors'=> $erros]);
        }

        $ticket_order_row = TicketOrder::create([
            'user_id' => auth()->user()->id, //ezt ki kell cserélni majd bejelentkezett felhasználó id-ra 
            'ticket_id' => 9, //ezt az oszlopot db-ből ki kell törölni
            'quantity' => 1, //ezt az oszlopot db-ből ki kell törölni
            'seat_id' => null,//ezt az oszlopot db-ből ki kell törölni
            'total_price' => $total_price, 
            'screening_id' => $validated['screening_id']
        ]);

        $ticket_order_row->save();

        foreach($validated['seats'] as $seat) {
            $seat_row = TicketOrderSeat::create([
                'seat_id' => $seat['seat_id'],
                //'price_id' => $seat['price_id'],
                'screening_id' => $validated['screening_id'],//ezt az oszlopot db-ből ki kell törölni
                'ticket_order_id' => $ticket_order_row->id
            ]);

            $seat_row->save();
        }

        $response_for_frontend['ticket_order_id'] = $ticket_order_row->id;

        return response()->json($response_for_frontend);
    }
}
