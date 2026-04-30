<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TicketOrderSeat extends Model
{
    //
    protected $table = 'ticket_order_seats';

    
    protected $fillable = [
        'seat_id',
        'price_id',
        'screening_id',
        'ticket_order_id',
    ];


    /**
     * Indicates if the model should be timestamped.
     *
     * @var bool
     */
    public $timestamps = false;


    public function seat()
    {
        return $this->hasOne(Seat::class, 'id', 'seat_id');
    }
}
