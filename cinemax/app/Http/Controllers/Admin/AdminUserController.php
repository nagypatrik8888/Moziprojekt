<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AdminUserController extends Controller
{
    public function index()
    {
        $user_rows = User::all();

        $response = [
            'users' => [],
        ];

        foreach ($user_rows as $user) {
            $response['users'][] = [
                'user_id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ];
        }

        return response()->json($response);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6'],
        ]);

        $user = new User();
        $user->name = $validated['name'];
        $user->email = $validated['email'];
        $user->password = Hash::make($validated['password']);
        $user->save();

        return response()->json([
            'message' => 'User created',
            'user_id' => $user->id,
        ], 201);
    }
}