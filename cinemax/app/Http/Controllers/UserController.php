<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{
    /**
     * POST /login
     * JSON-only SPA login. Sikeres bejelentkezés után 200-as választ küld
     * a frontendnek a felhasználói adatokkal; cookie-session-t indít.
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email'    => ['required', 'email', 'max:255'],
            'password' => ['required', 'string'],
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        if (!Auth::attempt($validator->valid(), true)) {
            return response()->json([
                'message' => 'Hibás email vagy jelszó.',
            ], 401);
        }

        $request->session()->regenerate();

        return response()->json([
            'message' => 'Sikeres bejelentkezés.',
            'user'    => Auth::user()->get_data_for_frontend(),
        ]);
    }

    /**
     * POST /register
     * Új felhasználó létrehozása + automatikus bejelentkeztetés.
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name'                  => ['required', 'string', 'max:255'],
            'email'                 => ['required', 'email', 'max:255', 'unique:users,email'],
            'password'              => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $validator->valid();

        $user = User::create([
            'name'      => $data['name'],
            'email'     => $data['email'],
            'password'  => Hash::make($data['password']),
            'user_type' => 1, // alapból sima felhasználó
        ]);

        Auth::login($user, true);
        $request->session()->regenerate();

        return response()->json([
            'message' => 'Sikeres regisztráció.',
            'user'    => $user->get_data_for_frontend(),
        ], 201);
    }

    /**
     * POST /logout
     * Bezárja a sessiont és invalidálja a CSRF tokent.
     */
    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return response()->json(['message' => 'Kijelentkezve.']);
    }
}
