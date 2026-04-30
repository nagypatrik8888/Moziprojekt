<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Room;
use App\Models\Movie;

class Screening extends Model
{
    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'screening'; //protected

    /**
     * The primary key associated with the table.
     *
     * @var string
     */
    protected $primaryKey = 'id';

    /**
     * Indicates if the model should be timestamped.
     *
     * @var bool
     */
    public $timestamps = false;

    /**
     * Get the genre associated with the user.
     */
    public function film()
    {
        return $this->hasOne(Movie::class,'id','film_id'); //hasone
    }

    public function room()
    {
        return $this->hasOne(Room::class,'id','room_id');
    }

    
}

