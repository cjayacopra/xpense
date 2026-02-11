<?php

namespace Database\Seeders;

use App\Models\Transaction;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // UserObserver will handle seeding default accounts and categories
        $user = User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => Hash::make('password'),
        ]);

        // Add some initial transactions for the test user
        $cash = $user->accounts()->where('name', 'Cash Wallet')->first();
        $bank = $user->accounts()->where('name', 'Savings Account')->first();
        $food = $user->categories()->where('name', 'Food & Dining')->first();
        $transport = $user->categories()->where('name', 'Transportation')->first();

        Transaction::create([
            'user_id' => $user->id,
            'account_id' => $cash->id,
            'category_id' => $food->id,
            'amount' => 15000,
            'type' => 'expense',
            'description' => 'Lunch at Jollibee',
            'date' => now(),
        ]);

        Transaction::create([
            'user_id' => $user->id,
            'account_id' => $bank->id,
            'category_id' => $transport->id,
            'amount' => 5000,
            'type' => 'expense',
            'description' => 'Grab ride',
            'date' => now(),
        ]);
        
        Transaction::create([
            'user_id' => $user->id,
            'account_id' => $bank->id,
            'amount' => 2500000,
            'type' => 'income',
            'description' => 'Monthly Salary',
            'date' => now(),
        ]);
    }
}
