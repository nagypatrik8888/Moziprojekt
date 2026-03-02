<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Price;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AdminPriceController extends Controller
{
    // GET /api/admin/prices
    public function index()
    {
        $rows = Price::all();

        $response = ['prices' => []];

        foreach ($rows as $p) {
            $response['prices'][] = [
                'price_id' => $p->id,
                'type' => $p->type,
                'price' => $p->price,
            ];
        }

        return response()->json($response);
    }

    // POST /api/admin/prices
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'type' => ['required', 'string', 'max:50', 'unique:prices,type'],
            'price' => ['nullable', 'numeric'],
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $v = $validator->valid();

        $p = new Price();
        $p->type = $v['type'];
        $p->price = $v['price'] ?? null;
        $p->save();

        return response()->json([
            'message' => 'Price created',
            'price_id' => $p->id
        ], 201);
    }

    // PUT /api/admin/prices/{price_id}
    public function update(int $price_id, Request $request)
    {
        $p = Price::find($price_id);

        if (!$p) {
            return response()->json(['message' => 'Price not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'type' => ['required', 'string', 'max:50', 'unique:prices,type,' . $price_id],
            'price' => ['nullable', 'numeric'],
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $v = $validator->valid();

        $p->type = $v['type'];
        $p->price = $v['price'] ?? null;
        $p->save();

        return response()->json([
            'message' => 'Price updated',
            'price_id' => $p->id
        ], 200);
    }
}