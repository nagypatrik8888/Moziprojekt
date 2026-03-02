<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Language extends Model
{
    protected $table = 'languages';
    protected $primaryKey = 'id';
    public $timestamps = false; // SQL alapján nincs created_at/updated_at
}