<?php

namespace App\Observers;

use App\Models\User;
use App\Models\Account;
use App\Models\Category;

class UserObserver
{
    /**
     * Handle the User "created" event.
     */
    public function created(User $user): void
    {
        // Default Accounts
        $accounts = [
            ['name' => 'Cash Wallet', 'icon' => 'Wallet'],
            ['name' => 'Savings Account', 'icon' => 'Landmark'],
            ['name' => 'Credit Card', 'icon' => 'CreditCard'],
        ];

        foreach ($accounts as $account) {
            Account::create([
                'user_id' => $user->id,
                'name' => $account['name'],
                'icon' => $account['icon'],
                'balance' => 0,
                'currency' => 'PHP',
            ]);
        }

        // Default Categories
        $categories = [
            ['name' => 'Food & Dining', 'icon' => 'Utensils', 'color' => '#ef4444'],
            ['name' => 'Transportation', 'icon' => 'Car', 'color' => '#3b82f6'],
            ['name' => 'Shopping', 'icon' => 'ShoppingCart', 'color' => '#a855f7'],
            ['name' => 'Housing & Rent', 'icon' => 'Home', 'color' => '#f59e0b'],
            ['name' => 'Bills & Utilities', 'icon' => 'Zap', 'color' => '#10b981'],
            ['name' => 'Health & Wellness', 'icon' => 'Heart', 'color' => '#ec4899'],
            ['name' => 'Education', 'icon' => 'GraduationCap', 'color' => '#6366f1'],
            ['name' => 'Travel', 'icon' => 'Plane', 'color' => '#06b6d4'],
            ['name' => 'Coffee & Snacks', 'icon' => 'Coffee', 'color' => '#78350f'],
            ['name' => 'Entertainment', 'icon' => 'Gift', 'color' => '#f43f5e'],
        ];

        foreach ($categories as $category) {
            Category::create([
                'user_id' => $user->id,
                'name' => $category['name'],
                'icon' => $category['icon'],
                'color' => $category['color'],
            ]);
        }
    }
}
