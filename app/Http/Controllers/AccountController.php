<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreAccountRequest;
use App\Http\Requests\UpdateAccountRequest;
use App\Http\Resources\AccountResource;
use App\Models\Account;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class AccountController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): Response
    {
        $accounts = $request->user()->accounts()->latest()->get();

        return Inertia::render('accounts/Index', [
            'accounts' => AccountResource::collection($accounts),
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreAccountRequest $request)
    {
        $request->user()->accounts()->create([
            'name' => $request->name,
            'balance' => $request->balance * 100,
            'currency' => $request->currency ?? 'PHP',
            'icon' => $request->icon ?? 'Wallet',
        ]);

        return redirect()->back();
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateAccountRequest $request, Account $account)
    {
        $this->authorize('update', $account);

        $account->update([
            'name' => $request->name,
            'balance' => $request->balance * 100,
            'currency' => $request->currency ?? 'PHP',
            'icon' => $request->icon ?? 'Wallet',
        ]);

        return redirect()->back();
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Account $account)
    {
        $this->authorize('delete', $account);

        $account->delete();

        return redirect()->back();
    }
}
