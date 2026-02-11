<?php

namespace App\Observers;

use App\Models\Transaction;
use App\Models\Account;

class TransactionObserver
{
    /**
     * Handle the Transaction "created" event.
     */
    public function created(Transaction $transaction): void
    {
        $account = $transaction->account;
        
        if ($transaction->type === 'income') {
            $account->increment('balance', $transaction->amount);
        } elseif ($transaction->type === 'transfer') {
            $account->decrement('balance', $transaction->amount);
            if ($transaction->destination_account_id) {
                $transaction->destinationAccount->increment('balance', $transaction->amount);
            }
        } else {
            $account->decrement('balance', $transaction->amount);
        }
    }

    /**
     * Handle the Transaction "updated" event.
     */
    public function updated(Transaction $transaction): void
    {
        // Reverse the old transaction values
        $oldAccountId = $transaction->getOriginal('account_id');
        $oldDestAccountId = $transaction->getOriginal('destination_account_id');
        $oldAmount = $transaction->getOriginal('amount');
        $oldType = $transaction->getOriginal('type');
        
        $oldAccount = Account::find($oldAccountId);
        if ($oldAccount) {
            if ($oldType === 'income') {
                $oldAccount->decrement('balance', $oldAmount);
            } elseif ($oldType === 'transfer') {
                $oldAccount->increment('balance', $oldAmount);
                $oldDestAccount = Account::find($oldDestAccountId);
                if ($oldDestAccount) {
                    $oldDestAccount->decrement('balance', $oldAmount);
                }
            } else {
                $oldAccount->increment('balance', $oldAmount);
            }
        }
        
        // Apply new transaction values
        $newAccount = $transaction->account;
        if ($transaction->type === 'income') {
            $newAccount->increment('balance', $transaction->amount);
        } elseif ($transaction->type === 'transfer') {
            $newAccount->decrement('balance', $transaction->amount);
            if ($transaction->destination_account_id) {
                $transaction->destinationAccount->increment('balance', $transaction->amount);
            }
        } else {
            $newAccount->decrement('balance', $transaction->amount);
        }
    }

    /**
     * Handle the Transaction "deleted" event.
     */
    public function deleted(Transaction $transaction): void
    {
        $account = $transaction->account;
        
        if ($transaction->type === 'income') {
            $account->decrement('balance', $transaction->amount);
        } elseif ($transaction->type === 'transfer') {
            $account->increment('balance', $transaction->amount);
            if ($transaction->destination_account_id) {
                $transaction->destinationAccount->decrement('balance', $transaction->amount);
            }
        } else {
            $account->increment('balance', $transaction->amount);
        }
    }
}
