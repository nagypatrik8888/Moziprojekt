<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasApiTokens,HasFactory, Notifiable;

    const USER_TYPE_SIMPLE = 'simple';
    const USER_TYPE_ADMIN = 'admin';


    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function is_admin(): bool 
    {
        return $this->get_user_types()[$this->user_type] === self::USER_TYPE_ADMIN;
    }

    public function get_user_types() {
        return [
            1 => self::USER_TYPE_SIMPLE,
            2 => self::USER_TYPE_ADMIN
        ];
    }

    public function get_data_for_frontend() {
        return [
            'id' => $this->id,
            'name' =>  $this->name,
            'email' => $this->email,
            'is_admin' => $this->is_admin(),
        ];
    }
}
