<?php

namespace App\Http\Controllers;

use App\Http\Resources\TransactionResource;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function __invoke(Request $request): Response
    {
        $user = $request->user();
        
        $totalBalance = $user->accounts()->sum('balance') / 100;
        
        $thisMonthExpenses = $user->transactions()
            ->where('type', 'expense')
            ->whereMonth('date', Carbon::now()->month)
            ->whereYear('date', Carbon::now()->year)
            ->sum('amount') / 100;
            
        $recentTransactions = $user->transactions()
            ->with(['account', 'destinationAccount', 'category'])
            ->latest('date')
            ->latest('id')
            ->limit(5)
            ->get();

        // Prepare chart data (last 7 days)
        $chartData = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::now()->subDays($i)->format('Y-m-d');
            $dayName = Carbon::now()->subDays($i)->format('D');
            
            // Using a single query for both to be safe
            $totals = $user->transactions()
                ->whereDate('date', $date)
                ->select('type', DB::raw('sum(amount) as total'))
                ->groupBy('type')
                ->pluck('total', 'type');
                
            $chartData[] = [
                'day' => $dayName,
                'income' => ($totals['income'] ?? 0) / 100,
                'expenses' => ($totals['expense'] ?? 0) / 100,
            ];
        }

        return Inertia::render('About' === $request->path() ? 'About' : 'Dashboard', [
            'stats' => [
                'total_balance' => number_format($totalBalance, 2),
                'this_month_expenses' => number_format($thisMonthExpenses, 2),
            ],
            'recent_expenses' => TransactionResource::collection($recentTransactions),
            'chart_data' => $chartData,
        ]);
    }
}
