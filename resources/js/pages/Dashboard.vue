<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import { Wallet, Receipt, ArrowRight, Calendar, Tag, TrendingUp, TrendingDown, Plus, ArrowLeftRight } from 'lucide-vue-next';
import { computed } from 'vue';
import { Button } from '@/components/ui/button';
import {
    Card,
    CardContent,
    CardHeader,
    CardTitle,
} from '@/components/ui/card';
import AppLayout from '@/layouts/AppLayout.vue';
import { dashboard } from '@/routes';
import transactions from '@/routes/transactions';
import { type BreadcrumbItem } from '@/types';

interface Transaction {
    id: number;
    type: 'income' | 'expense' | 'transfer';
    amount: number;
    formatted_amount: string;
    description: string;
    date: string;
    account?: { name: string };
    destination_account?: { name: string };
    category?: { name: string; color: string };
}

interface ChartData {
    day: string;
    income: number;
    expenses: number;
}

const props = defineProps<{
    stats?: {
        total_balance: string;
        this_month_expenses: string;
    };
    recent_expenses?: {
        data: Transaction[];
    };
    chart_data?: ChartData[];
}>();

const breadcrumbs: BreadcrumbItem[] = [
    {
        title: 'Dashboard',
        href: dashboard().url,
    },
];

const maxChartValue = computed(() => {
    if (!props.chart_data || props.chart_data.length === 0) return 100;
    const values = props.chart_data.flatMap(d => [d.income, d.expenses]);
    return Math.max(...values, 100);
});
</script>

<template>
    <Head title="Dashboard" />

    <AppLayout :breadcrumbs="breadcrumbs">
        <div class="flex h-full flex-1 flex-col gap-6 p-6">
            <div class="flex flex-col gap-2">
                <h2 class="text-3xl font-extrabold tracking-tight">Overview</h2>
                <p class="text-muted-foreground font-medium">Welcome back to <span class="text-primary">Xpense</span>.</p>
            </div>

            <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
                <Card class="glass-card overflow-hidden border-none bg-gradient-to-br from-primary/10 to-primary/5 text-card-foreground">
                    <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle class="text-sm font-medium">Total Balance</CardTitle>
                        <div class="rounded-full bg-primary/10 p-2 text-primary">
                            <Wallet class="h-4 w-4" />
                        </div>
                    </CardHeader>
                    <CardContent>
                        <div class="text-3xl font-bold tracking-tight">PHP {{ stats?.total_balance || '0.00' }}</div>
                        <div class="mt-1 flex items-center text-xs text-muted-foreground">
                            <TrendingUp class="mr-1 h-3 w-3 text-green-500" />
                            <span>Healthy standing</span>
                        </div>
                    </CardContent>
                </Card>

                <Card class="glass-card overflow-hidden border-none bg-gradient-to-br from-destructive/10 to-destructive/5 text-card-foreground">
                    <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle class="text-sm font-medium">Monthly Spending</CardTitle>
                        <div class="rounded-full bg-destructive/10 p-2 text-destructive">
                            <Receipt class="h-4 w-4" />
                        </div>
                    </CardHeader>
                    <CardContent>
                        <div class="text-3xl font-bold tracking-tight text-destructive">PHP {{ stats?.this_month_expenses || '0.00' }}</div>
                        <div class="mt-1 flex items-center text-xs text-muted-foreground">
                            <TrendingDown class="mr-1 h-3 w-3 text-destructive" />
                            <span>Total spent this month</span>
                        </div>
                    </CardContent>
                </Card>
            </div>

            <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-7">
                <!-- Transaction Trend Graph -->
                <Card class="glass-card col-span-full lg:col-span-4 border-none bg-card/50">
                    <CardHeader>
                        <CardTitle class="text-xl font-bold">Transaction Trends</CardTitle>
                        <p class="text-sm text-muted-foreground font-medium">Income vs Expenses (Last 7 Days)</p>
                    </CardHeader>
                    <CardContent>
                        <div class="flex h-[240px] items-end justify-between gap-4 pt-8 pb-2">
                            <div v-for="day in props.chart_data || []" :key="day.day" class="flex flex-1 flex-col items-center gap-3 h-full justify-end">
                                <div class="relative flex w-full items-end justify-center gap-1.5 h-full">
                                    <!-- Income Bar -->
                                    <div 
                                        class="w-4 rounded-t-lg bg-green-500 shadow-lg shadow-green-500/20 transition-all hover:scale-110 hover:brightness-110"
                                        :style="{ height: `${Math.max((day.income / maxChartValue) * 100, 2)}%` }"
                                        :title="`Income: ${day.income}`"
                                    ></div>
                                    <!-- Expense Bar -->
                                    <div 
                                        class="w-4 rounded-t-lg bg-destructive shadow-lg shadow-destructive/20 transition-all hover:scale-110 hover:brightness-110"
                                        :style="{ height: `${Math.max((day.expenses / maxChartValue) * 100, 2)}%` }"
                                        :title="`Expenses: ${day.expenses}`"
                                    ></div>
                                </div>
                                <span class="text-[10px] font-bold text-muted-foreground uppercase tracking-widest">{{ day.day }}</span>
                            </div>
                        </div>
                        <div class="mt-8 flex justify-center gap-6 text-xs font-bold">
                            <div class="flex items-center gap-2">
                                <div class="h-3 w-3 rounded-full bg-green-500"></div>
                                <span class="uppercase tracking-wide opacity-70">Income</span>
                            </div>
                            <div class="flex items-center gap-2">
                                <div class="h-3 w-3 rounded-full bg-destructive"></div>
                                <span class="uppercase tracking-wide opacity-70">Expenses</span>
                            </div>
                        </div>
                    </CardContent>
                </Card>

                <!-- Recent Transactions -->
                <Card class="glass-card col-span-full lg:col-span-3 border-none bg-card/50">
                    <CardHeader class="flex flex-row items-center justify-between">
                        <div class="space-y-1">
                            <CardTitle class="text-xl font-bold">Recent</CardTitle>
                        </div>
                        <Button variant="ghost" as-child size="sm" class="glass rounded-full border-none">
                            <Link :href="transactions.index().url">
                                View All
                                <ArrowRight class="ml-2 h-4 w-4" />
                            </Link>
                        </Button>
                    </CardHeader>
                    <CardContent>
                        <div class="space-y-4">
                            <div v-for="transaction in recent_expenses?.data || []" :key="transaction.id" 
                                class="group flex items-center justify-between rounded-2xl border border-transparent p-3 transition-all hover:bg-accent/50"
                            >
                                <div class="flex items-center gap-3 overflow-hidden">
                                    <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-muted">
                                        <TrendingUp v-if="transaction.type === 'income'" class="h-4 w-4 text-green-600" />
                                        <ArrowLeftRight v-else-if="transaction.type === 'transfer'" class="h-4 w-4 text-blue-600" />
                                        <TrendingDown v-else class="h-4 w-4 text-destructive" />
                                    </div>
                                    <div class="overflow-hidden">
                                        <div class="truncate font-bold text-sm">{{ transaction.description || 'No description' }}</div>
                                        <div class="text-[10px] font-bold text-muted-foreground uppercase tracking-wider">
                                            {{ transaction.account?.name }}
                                            <span v-if="transaction.type === 'transfer'" class="mx-1">→</span>
                                            <span v-if="transaction.type === 'transfer'">{{ transaction.destination_account?.name }}</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="text-right shrink-0 ml-2">
                                    <div class="text-sm font-black" :class="{
                                        'text-green-600': transaction.type === 'income',
                                        'text-blue-600': transaction.type === 'transfer',
                                        'text-destructive': transaction.type === 'expense'
                                    }">
                                        {{ transaction.type === 'income' ? '+' : (transaction.type === 'transfer' ? '' : '-') }}{{ transaction.formatted_amount }}
                                    </div>
                                </div>
                            </div>
                            
                            <div v-if="!recent_expenses?.data?.length" class="flex flex-col items-center justify-center py-8 text-center text-muted-foreground">
                                <div class="mb-4 rounded-full bg-muted p-4">
                                    <Receipt class="h-8 w-8 opacity-20" />
                                </div>
                                <p class="text-xs font-bold uppercase tracking-widest">No activity</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    </AppLayout>
</template>
