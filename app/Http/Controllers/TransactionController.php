<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreTransactionRequest;
use App\Http\Requests\UpdateTransactionRequest;
use App\Http\Resources\AccountResource;
use App\Http\Resources\CategoryResource;
use App\Http\Resources\TransactionResource;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class TransactionController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): Response
    {
        $transactions = $request->user()->transactions()
            ->with(['account', 'destinationAccount', 'category'])
            ->latest('date')
            ->latest('id')
            ->get();

        return Inertia::render('transactions/Index', [
            'expenses' => TransactionResource::collection($transactions),
            'accounts' => AccountResource::collection($request->user()->accounts),
            'categories' => CategoryResource::collection($request->user()->categories),
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreTransactionRequest $request)
    {
        $request->user()->transactions()->create([
            'type' => $request->type,
            'account_id' => $request->account_id,
            'destination_account_id' => $request->destination_account_id,
            'category_id' => $request->category_id,
            'amount' => $request->amount * 100,
            'description' => $request->description,
            'date' => $request->date,
        ]);

        return redirect()->back();
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateTransactionRequest $request, Transaction $transaction)
    {
        $this->authorize('update', $transaction);

        $transaction->update([
            'type' => $request->type,
            'account_id' => $request->account_id,
            'destination_account_id' => $request->destination_account_id,
            'category_id' => $request->category_id,
            'amount' => $request->amount * 100,
            'description' => $request->description,
            'date' => $request->date,
        ]);

        return redirect()->back();
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Transaction $transaction)
    {
        $this->authorize('delete', $transaction);

        $transaction->delete();

        return redirect()->back();
    }
}
