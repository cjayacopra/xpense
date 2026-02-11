<script setup lang="ts">
import { Head, useForm } from '@inertiajs/vue3';
import { 
    Plus, Receipt, Trash2, Calendar, Wallet, Tag, TrendingUp, TrendingDown, Edit2,
    ShoppingCart, Utensils, Car, Home, Zap, Heart, Gift, Briefcase, GraduationCap, Plane, Coffee,
    ArrowLeftRight
} from 'lucide-vue-next';
import { ref, computed } from 'vue';
import { Button } from '@/components/ui/button';
import {
    Card,
    CardContent,
    CardHeader,
    CardTitle,
} from '@/components/ui/card';
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import AppLayout from '@/layouts/AppLayout.vue';
import transactionsRoutes from '@/routes/transactions';
import { type BreadcrumbItem } from '@/types';

interface Account {
    id: number;
    name: string;
    formatted_balance: string;
}

interface Category {
    id: number;
    name: string;
    icon: string;
    color: string;
}

interface Transaction {
    id: number;
    type: 'income' | 'expense' | 'transfer';
    amount: number;
    formatted_amount: string;
    description: string;
    date: string;
    account_id: number;
    destination_account_id: number | null;
    category_id: number | null;
    account?: Account;
    destination_account?: Account;
    category?: Category;
}

const props = defineProps<{
    expenses?: {
        data: Transaction[];
    };
    accounts?: {
        data: Account[];
    };
    categories?: {
        data: Category[];
    };
}>();

const breadcrumbs: BreadcrumbItem[] = [
    {
        title: 'Transactions',
        href: transactionsRoutes.index().url,
    },
];

const categoryIcons = [
    { name: 'Tag', component: Tag },
    { name: 'ShoppingCart', component: ShoppingCart },
    { name: 'Utensils', component: Utensils },
    { name: 'Car', component: Car },
    { name: 'Home', component: Home },
    { name: 'Zap', component: Zap },
    { name: 'Heart', component: Heart },
    { name: 'Gift', component: Gift },
    { name: 'Briefcase', component: Briefcase },
    { name: 'GraduationCap', component: GraduationCap },
    { name: 'Plane', component: Plane },
    { name: 'Coffee', component: Coffee },
];

const getCategoryIcon = (name: string | undefined) => {
    return categoryIcons.find(i => i.name === name)?.component || Tag;
};

const isCreateModalOpen = ref(false);
const isEditModalOpen = ref(false);
const editingTransaction = ref<Transaction | null>(null);

const createForm = useForm({
    type: 'expense' as 'income' | 'expense' | 'transfer',
    account_id: props.accounts?.data?.[0]?.id || '',
    destination_account_id: '',
    category_id: '',
    amount: '' as string | number,
    description: '',
    date: new Date().toISOString().split('T')[0],
});

const editForm = useForm({
    type: 'expense' as 'income' | 'expense' | 'transfer',
    account_id: '' as string | number,
    destination_account_id: '' as string | number,
    category_id: '' as string | number,
    amount: '' as string | number,
    description: '',
    date: '',
});

const submitCreate = () => {
    createForm.post(transactionsRoutes.store().url, {
        onSuccess: () => {
            isCreateModalOpen.value = false;
            createForm.reset();
        },
    });
};

const openEditModal = (transaction: Transaction) => {
    editingTransaction.value = transaction;
    editForm.type = transaction.type;
    editForm.account_id = transaction.account_id;
    editForm.destination_account_id = transaction.destination_account_id || '';
    editForm.category_id = transaction.category_id || '';
    editForm.amount = transaction.amount;
    editForm.description = transaction.description || '';
    editForm.date = transaction.date;
    isEditModalOpen.value = true;
};

const submitUpdate = () => {
    if (!editingTransaction.value) return;
    editForm.put(transactionsRoutes.update(editingTransaction.value.id).url, {
        onSuccess: () => {
            isEditModalOpen.value = false;
            editingTransaction.value = null;
            editForm.reset();
        },
    });
};

const deleteTransaction = (id: number) => {
    if (confirm('Are you sure you want to delete this transaction?')) {
        createForm.delete(transactionsRoutes.destroy(id).url);
    }
};

const totalExpenses = computed(() => {
    if (!props.expenses?.data) return 0;
    return props.expenses.data
        .filter(t => t.type === 'expense')
        .reduce((sum, t) => sum + t.amount, 0);
});

const totalIncome = computed(() => {
    if (!props.expenses?.data) return 0;
    return props.expenses.data
        .filter(t => t.type === 'income')
        .reduce((sum, t) => sum + t.amount, 0);
});

const formatCurrency = (amount: number) => {
    return amount.toLocaleString(undefined, { minimumFractionDigits: 2 });
};
</script>

<template>
    <Head title="Transactions" />

    <AppLayout :breadcrumbs="breadcrumbs">
        <div class="flex h-full flex-1 flex-col gap-6 p-6">
            <div class="flex items-center justify-between">
                <div class="space-y-1">
                    <h2 class="text-3xl font-extrabold tracking-tight text-foreground">Transactions</h2>
                    <p class="text-muted-foreground text-sm">
                        Track your income, expenses, and internal transfers.
                    </p>
                </div>

                <Dialog v-model:open="isCreateModalOpen">
                    <DialogTrigger as-child>
                        <Button :disabled="!accounts?.data?.length" class="rounded-full px-6 shadow-lg shadow-primary/20">
                            <Plus class="mr-2 h-4 w-4" />
                            Add Record
                        </Button>
                    </DialogTrigger>
                    <DialogContent class="glass max-w-md border-none">
                        <form @submit.prevent="submitCreate">
                            <DialogHeader>
                                <DialogTitle>New Transaction</DialogTitle>
                                <DialogDescription>
                                    Record a new financial activity.
                                </DialogDescription>
                            </DialogHeader>
                            <div class="grid gap-6 py-4">
                                <div class="flex gap-1 bg-muted p-1 rounded-2xl">
                                    <Button 
                                        type="button" 
                                        class="flex-1 rounded-xl h-9" 
                                        :variant="createForm.type === 'expense' ? 'destructive' : 'ghost'"
                                        @click="createForm.type = 'expense'"
                                    >
                                        Expense
                                    </Button>
                                    <Button 
                                        type="button" 
                                        class="flex-1 rounded-xl h-9" 
                                        :variant="createForm.type === 'income' ? 'default' : 'ghost'"
                                        :class="createForm.type === 'income' ? 'bg-green-600 hover:bg-green-700 text-white' : ''"
                                        @click="createForm.type = 'income'"
                                    >
                                        Income
                                    </Button>
                                    <Button 
                                        type="button" 
                                        class="flex-1 rounded-xl h-9" 
                                        :variant="createForm.type === 'transfer' ? 'secondary' : 'ghost'"
                                        @click="createForm.type = 'transfer'"
                                    >
                                        Transfer
                                    </Button>
                                </div>

                                <div class="grid gap-2">
                                    <Label for="account_id">{{ createForm.type === 'transfer' ? 'From Account' : 'Account' }}</Label>
                                    <select
                                        id="account_id"
                                        v-model="createForm.account_id"
                                        class="flex h-10 w-full rounded-xl border border-input bg-background/50 px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                                        required
                                    >
                                        <option v-for="account in accounts?.data || []" :key="account.id" :value="account.id">
                                            {{ account.name }}
                                        </option>
                                    </select>
                                </div>

                                <div v-if="createForm.type === 'transfer'" class="grid gap-2 animate-in fade-in slide-in-from-top-2">
                                    <Label for="destination_account_id">To Account</Label>
                                    <select
                                        id="destination_account_id"
                                        v-model="createForm.destination_account_id"
                                        class="flex h-10 w-full rounded-xl border border-input bg-background/50 px-3 py-2 text-sm ring-offset-background"
                                        required
                                    >
                                        <option value="" disabled>Select destination...</option>
                                        <option v-for="account in accounts?.data?.filter(a => a.id !== createForm.account_id) || []" :key="account.id" :value="account.id">
                                            {{ account.name }}
                                        </option>
                                    </select>
                                </div>

                                <div v-if="createForm.type !== 'transfer'" class="grid gap-2">
                                    <Label for="category_id">Category</Label>
                                    <select
                                        id="category_id"
                                        v-model="createForm.category_id"
                                        class="flex h-10 w-full rounded-xl border border-input bg-background/50 px-3 py-2 text-sm ring-offset-background"
                                    >
                                        <option value="">No Category</option>
                                        <option v-for="category in categories?.data || []" :key="category.id" :value="category.id">
                                            {{ category.name }}
                                        </option>
                                    </select>
                                </div>

                                <div class="grid grid-cols-2 gap-4">
                                    <div class="grid gap-2">
                                        <Label for="amount">Amount</Label>
                                        <Input id="amount" type="number" step="0.01" v-model="createForm.amount" placeholder="0.00" required class="rounded-xl" />
                                    </div>
                                    <div class="grid gap-2">
                                        <Label for="date">Date</Label>
                                        <Input id="date" type="date" v-model="createForm.date" required class="rounded-xl" />
                                    </div>
                                </div>

                                <div class="grid gap-2">
                                    <Label for="description">Description</Label>
                                    <Input id="description" v-model="createForm.description" placeholder="Optional details..." class="rounded-xl" />
                                </div>
                            </div>
                            <DialogFooter>
                                <Button type="submit" :disabled="createForm.processing" class="w-full rounded-xl">
                                    Save Transaction
                                </Button>
                            </DialogFooter>
                        </form>
                    </DialogContent>
                </Dialog>
            </div>

            <!-- Dashboard Style Stats -->
            <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
                <Card class="glass-card border-none bg-gradient-to-br from-green-500/10 to-green-500/5">
                    <CardHeader class="pb-2">
                        <CardTitle class="text-xs font-bold uppercase tracking-widest text-green-600/70">Total Income</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div class="text-3xl font-black tracking-tight text-green-600">PHP {{ formatCurrency(totalIncome) }}</div>
                    </CardContent>
                </Card>
                <Card class="glass-card border-none bg-gradient-to-br from-destructive/10 to-destructive/5">
                    <CardHeader class="pb-2">
                        <CardTitle class="text-xs font-bold uppercase tracking-widest text-destructive/70">Total Spending</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div class="text-3xl font-black tracking-tight text-destructive">PHP {{ formatCurrency(totalExpenses) }}</div>
                    </CardContent>
                </Card>
            </div>

            <!-- History Table -->
            <Card class="glass-card border-none bg-card/50 overflow-hidden">
                <CardContent class="p-0">
                    <div class="relative w-full overflow-auto">
                        <table class="w-full caption-bottom text-sm">
                            <thead class="bg-muted/30">
                                <tr class="border-b border-border/50">
                                    <th class="h-14 px-6 text-left align-middle font-bold text-muted-foreground uppercase tracking-widest text-[10px]">Type</th>
                                    <th class="h-14 px-6 text-left align-middle font-bold text-muted-foreground uppercase tracking-widest text-[10px]">Date</th>
                                    <th class="h-14 px-6 text-left align-middle font-bold text-muted-foreground uppercase tracking-widest text-[10px]">Description</th>
                                    <th class="h-14 px-6 text-left align-middle font-bold text-muted-foreground uppercase tracking-widest text-[10px]">Account Details</th>
                                    <th class="h-14 px-6 text-right align-middle font-bold text-muted-foreground uppercase tracking-widest text-[10px]">Amount</th>
                                    <th class="h-14 px-6 text-right align-middle font-bold text-muted-foreground uppercase tracking-widest text-[10px]">Actions</th>
                                </tr>
                            </thead>
                            <tbody class="[&_tr:last-child]:border-0">
                                <tr v-for="transaction in expenses?.data || []" :key="transaction.id" class="border-b border-border/50 transition-all hover:bg-accent/30 group">
                                    <td class="p-6 align-middle">
                                        <div v-if="transaction.type === 'income'" class="flex h-10 w-10 items-center justify-center rounded-xl bg-green-100 text-green-600 dark:bg-green-900/30">
                                            <TrendingUp class="h-5 w-5" />
                                        </div>
                                        <div v-else-if="transaction.type === 'transfer'" class="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-100 text-blue-600 dark:bg-blue-900/30">
                                            <ArrowLeftRight class="h-5 w-5" />
                                        </div>
                                        <div v-else class="flex h-10 w-10 items-center justify-center rounded-xl bg-red-100 text-red-600 dark:bg-red-900/30">
                                            <TrendingDown class="h-5 w-5" />
                                        </div>
                                    </td>
                                    <td class="p-6 align-middle">
                                        <div class="flex flex-col gap-0.5">
                                            <span class="font-bold text-foreground">{{ transaction.date }}</span>
                                            <span v-if="transaction.category" class="flex items-center gap-1.5 text-[10px] font-bold uppercase tracking-widest" :style="{ color: transaction.category.color }">
                                                <component :is="getCategoryIcon(transaction.category.icon)" class="h-3 w-3" />
                                                {{ transaction.category.name }}
                                            </span>
                                        </div>
                                    </td>
                                    <td class="p-6 align-middle font-medium max-w-[200px]">
                                        <div class="truncate">{{ transaction.description || 'No description' }}</div>
                                    </td>
                                    <td class="p-6 align-middle">
                                        <div class="flex items-center gap-2 text-xs font-bold text-muted-foreground">
                                            <Wallet class="h-3.5 w-3.5" />
                                            <span>{{ transaction.account?.name }}</span>
                                            <template v-if="transaction.type === 'transfer'">
                                                <ArrowRight class="h-3 w-3 mx-1" />
                                                <Landmark class="h-3.5 w-3.5" />
                                                <span>{{ transaction.destination_account?.name }}</span>
                                            </template>
                                        </div>
                                    </td>
                                    <td class="p-6 align-middle text-right">
                                        <span class="text-xl font-black" :class="{
                                            'text-green-600': transaction.type === 'income',
                                            'text-blue-600': transaction.type === 'transfer',
                                            'text-destructive': transaction.type === 'expense'
                                        }">
                                            {{ transaction.type === 'income' ? '+' : (transaction.type === 'transfer' ? '' : '-') }}{{ transaction.formatted_amount }}
                                        </span>
                                    </td>
                                    <td class="p-6 align-middle text-right">
                                        <div class="flex items-center justify-end gap-1">
                                            <Button variant="ghost" size="icon" @click="openEditModal(transaction)" class="rounded-full hover:bg-primary/10 hover:text-primary transition-colors">
                                                <Edit2 class="h-4 w-4" />
                                            </Button>
                                            <Button variant="ghost" size="icon" @click="deleteTransaction(transaction.id)" class="rounded-full hover:bg-destructive/10 hover:text-destructive transition-colors">
                                                <Trash2 class="h-4 w-4" />
                                            </Button>
                                        </div>
                                    </td>
                                </tr>
                                <tr v-if="!expenses?.data?.length">
                                    <td colspan="6" class="p-24 text-center text-muted-foreground">
                                        <div class="mx-auto mb-4 flex h-20 w-20 items-center justify-center rounded-3xl bg-muted/50">
                                            <Receipt class="h-10 w-10 opacity-20" />
                                        </div>
                                        <h3 class="text-xl font-bold text-foreground">No records found</h3>
                                        <p class="mt-1">Add your first transaction to start tracking!</p>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </CardContent>
            </Card>

            <!-- Edit Modal (Simplified for reuse) -->
            <Dialog v-model:open="isEditModalOpen">
                <DialogContent class="glass max-w-md border-none">
                    <form @submit.prevent="submitUpdate">
                        <DialogHeader>
                            <DialogTitle>Edit Transaction</DialogTitle>
                        </DialogHeader>
                        <div class="grid gap-6 py-4">
                            <div class="flex gap-1 bg-muted p-1 rounded-2xl">
                                <Button type="button" class="flex-1 rounded-xl" :variant="editForm.type === 'expense' ? 'destructive' : 'ghost'" @click="editForm.type = 'expense'">Expense</Button>
                                <Button type="button" class="flex-1 rounded-xl" :variant="editForm.type === 'income' ? 'default' : 'ghost'" :class="editForm.type === 'income' ? 'bg-green-600 text-white' : ''" @click="editForm.type = 'income'">Income</Button>
                                <Button type="button" class="flex-1 rounded-xl" :variant="editForm.type === 'transfer' ? 'secondary' : 'ghost'" @click="editForm.type = 'transfer'">Transfer</Button>
                            </div>
                            <div class="grid gap-2">
                                <Label>Account</Label>
                                <select v-model="editForm.account_id" class="flex h-10 w-full rounded-xl border border-input bg-background/50 px-3 py-2 text-sm">
                                    <option v-for="account in accounts?.data || []" :key="account.id" :value="account.id">{{ account.name }}</option>
                                </select>
                            </div>
                            <div v-if="editForm.type === 'transfer'" class="grid gap-2">
                                <Label>To Account</Label>
                                <select v-model="editForm.destination_account_id" class="flex h-10 w-full rounded-xl border border-input bg-background/50 px-3 py-2 text-sm">
                                    <option v-for="account in accounts?.data?.filter(a => a.id !== editForm.account_id) || []" :key="account.id" :value="account.id">{{ account.name }}</option>
                                </select>
                            </div>
                            <div class="grid grid-cols-2 gap-4">
                                <div class="grid gap-2">
                                    <Label>Amount</Label>
                                    <Input type="number" step="0.01" v-model="editForm.amount" class="rounded-xl" />
                                </div>
                                <div class="grid gap-2">
                                    <Label>Date</Label>
                                    <Input type="date" v-model="editForm.date" class="rounded-xl" />
                                </div>
                            </div>
                        </div>
                        <DialogFooter>
                            <Button type="submit" :disabled="editForm.processing" class="w-full rounded-xl">Update</Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>
        </div>
    </AppLayout>
</template>
