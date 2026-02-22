<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TicketOrder extends Model
{
    protected $table = 'ticket_orders';

    protected $fillable = [
        'user_id',
        'screening_id',
        'price_id',
        'quantity',
        'total_price',
    ];


    public function user()
    {
        return $this->hasOne(User::class,'id','user_id');
    }

    
    public function seats()
    {
        return $this->hasMany(TicketOrderSeat::class,'ticket_order_id','id');
    }

    public function price()
    {
        return $this->belongsTo(Price::class);
    }

    public function screening()
    {
        return $this->belongsTo(Screening::class);
    }
}