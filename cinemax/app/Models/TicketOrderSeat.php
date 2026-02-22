<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TicketOrderSeat extends Model
{
    //
        protected $table = 'ticket_order_seats';

        public function seat() {
            return $this->hasOne(Seat::class,'id','seat_id');
        }

}
