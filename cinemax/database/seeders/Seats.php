<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;


class Seats extends Seeder
{
    /**
     * Run the database seeds.
     */
   public function run(): void
    {
        $roomIds = DB::table('rooms')->pluck('id');

        foreach ($roomIds as $roomId) {
            for ($row = 1; $row <= 10; $row++) {
                for ($col = 1; $col <= 10; $col++) {
                    $exists = DB::table('seats')
                        ->where('room_id', $roomId)
                        ->where('row_num', $row)
                        ->where('column_num', $col)
                        ->exists();

                    if (! $exists) {
                        DB::table('seats')->insert([
                            'room_id'     => $roomId,
                            'row_num'     => $row,
                            'column_num'  => $col,
                            'created_at'  => now(),
                            'updated_at'  => now(),
                        ]);
                    }
                }
            }
        }
    }
}
