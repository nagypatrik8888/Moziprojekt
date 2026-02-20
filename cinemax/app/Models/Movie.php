<?php

namespace App\Models;

use App\Models\Genre;
use Illuminate\Database\Eloquent\Model;

class Movie extends Model
{
    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'films';

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
    public function genre()
    {
        return $this->hasOne(Genre::class,'id','genre_id');
    }

    /**
     * Get the genre associated with the user.
     */
    public function screenings()
    {
        return $this->hasMany(Screening::class,'film_id','id');
    }
}
