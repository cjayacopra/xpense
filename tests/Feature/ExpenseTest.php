<?php

use App\Models\Account;
use App\Models\Category;
use App\Models\Transaction;
use App\Models\User;

test('expenses page is displayed', function () {
    $user = User::factory()->create();

    $response = $this
        ->actingAs($user)
        ->get('/transactions');

    $response->assertOk();
});

test('user can create an expense', function () {
    $this->withoutMiddleware(\Illuminate\Foundation\Http\Middleware\ValidateCsrfToken::class);
    $user = User::factory()->create();
    $account = Account::create([
        'user_id' => $user->id,
        'name' => 'Cash',
        'balance' => 100000,
    ]);
    $category = Category::create([
        'user_id' => $user->id,
        'name' => 'Food',
    ]);

    $response = $this
        ->actingAs($user)
        ->post('/transactions', [
            'type' => 'expense',
            'account_id' => $account->id,
            'category_id' => $category->id,
            'amount' => 50,
            'description' => 'Test Expense',
            'date' => now()->format('Y-m-d'),
        ]);

    $response->assertRedirect();
    $this->assertDatabaseHas('transactions', [
        'user_id' => $user->id,
        'amount' => 5000,
        'description' => 'Test Expense',
    ]);
});

test('user cannot view others expenses', function () {
    $this->withoutMiddleware(\Illuminate\Foundation\Http\Middleware\ValidateCsrfToken::class);
    $user1 = User::factory()->create();
    $user2 = User::factory()->create();

    $account = Account::create(['user_id' => $user2->id, 'name' => 'Other', 'balance' => 100]);
    $transaction = Transaction::create([
        'user_id' => $user2->id,
        'account_id' => $account->id,
        'type' => 'expense',
        'amount' => 100,
        'date' => now(),
    ]);

    $response = $this
        ->actingAs($user1)
        ->delete("/transactions/{$transaction->id}");

    $response->assertForbidden();
});
