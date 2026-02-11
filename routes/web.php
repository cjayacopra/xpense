<?php

use App\Http\Controllers\AccountController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\TransactionController;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;
use Laravel\Fortify\Features;

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('/', DashboardController::class);
    Route::get('dashboard', DashboardController::class)->name('dashboard');

    // Add home route alias for compatibility with tests
    Route::get('/home', function () {
        return redirect()->route('dashboard');
    })->name('home');

    Route::resource('accounts', AccountController::class);
    Route::resource('categories', CategoryController::class);
    Route::resource('transactions', TransactionController::class);
});

Route::get('/about', function () {
    return Inertia::render('About', [
        'canRegister' => Features::enabled(Features::registration()),
    ]);
})->name('about');

require __DIR__.'/settings.php';
