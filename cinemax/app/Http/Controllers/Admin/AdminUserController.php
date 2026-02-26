<?php

namespace App\Http\Controllers\Admin;

use App\Actions\Fortify\CreateNewUser;
use App\Http\Controllers\Controller;
use App\Models\User;
use GuzzleHttp\Promise\Create;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

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
        $createNewUser = new CreateNewUser();
         $validator = Validator::make($request->all(),[
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => $createNewUser->getPasswordRulesForValidator(),
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors()); //ha fail json error
        }

        $validated = $validator->valid();  //ellenorizzuk letezik e a screening
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