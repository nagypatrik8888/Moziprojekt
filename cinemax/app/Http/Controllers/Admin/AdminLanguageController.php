<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Language;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AdminLanguageController extends Controller
{
    // GET /api/admin/languages
    public function index()
    {
        $rows = Language::all();

        $response = ['languages' => []];

        foreach ($rows as $l) {
            $response['languages'][] = [
                'language_id' => $l->id,
                'code' => $l->code,
                'name' => $l->name,
            ];
        }

        return response()->json($response);
    }

    // POST /api/admin/languages
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'code' => ['required', 'string', 'max:10', 'unique:languages,code'],
            'name' => ['required', 'string', 'max:50', 'unique:languages,name'],
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $v = $validator->valid();

        $l = new Language();
        $l->code = $v['code'];
        $l->name = $v['name'];
        $l->save();

        return response()->json([
            'message' => 'Language created',
            'language_id' => $l->id
        ], 201);
    }

    // PUT /api/admin/languages/{language_id}
    public function update(int $language_id, Request $request)
    {
        $l = Language::find($language_id);

        if (!$l) {
            return response()->json(['message' => 'Language not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'code' => ['required', 'string', 'max:10', 'unique:languages,code,' . $language_id],
            'name' => ['required', 'string', 'max:50', 'unique:languages,name,' . $language_id],
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $v = $validator->valid();

        $l->code = $v['code'];
        $l->name = $v['name'];
        $l->save();

        return response()->json([
            'message' => 'Language updated',
            'language_id' => $l->id
        ], 200);
    }
}