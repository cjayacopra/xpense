<script setup lang="ts">
import { Head, useForm } from '@inertiajs/vue3';
import { 
    Plus, Wallet, Trash2, Landmark, CreditCard, Coins, PiggyBank, Edit2, Check 
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
import accountsRoutes from '@/routes/accounts';
import { type BreadcrumbItem } from '@/types';

interface Account {
    id: number;
    name: string;
    balance: number;
    currency: string;
    icon: string;
    formatted_balance: string;
}

const props = defineProps<{
    accounts?: {
        data: Account[];
    };
}>();

const breadcrumbs: BreadcrumbItem[] = [
    {
        title: 'Accounts',
        href: accountsRoutes.index().url,
    },
];

const icons = [
    { name: 'Wallet', component: Wallet },
    { name: 'Landmark', component: Landmark },
    { name: 'CreditCard', component: CreditCard },
    { name: 'Coins', component: Coins },
    { name: 'PiggyBank', component: PiggyBank },
];

const getIcon = (name: string) => {
    return icons.find(i => i.name === name)?.component || Wallet;
};

const isCreateModalOpen = ref(false);
const isEditModalOpen = ref(false);
const editingAccount = ref<Account | null>(null);

const createForm = useForm({
    name: '',
    balance: 0,
    currency: 'PHP',
    icon: 'Wallet'
});

const editForm = useForm({
    name: '',
    balance: 0,
    currency: 'PHP',
    icon: 'Wallet'
});

const submitCreate = () => {
    createForm.post(accountsRoutes.store().url, {
        onSuccess: () => {
            isCreateModalOpen.value = false;
            createForm.reset();
        },
    });
};

const openEditModal = (account: Account) => {
    editingAccount.value = account;
    editForm.name = account.name;
    editForm.balance = account.balance;
    editForm.currency = account.currency;
    editForm.icon = account.icon || 'Wallet';
    isEditModalOpen.value = true;
};

const submitUpdate = () => {
    if (!editingAccount.value) return;
    editForm.put(accountsRoutes.update(editingAccount.value.id).url, {
        onSuccess: () => {
            isEditModalOpen.value = false;
            editingAccount.value = null;
            editForm.reset();
        },
    });
};

const deleteAccount = (id: number) => {
    if (confirm('Are you sure you want to delete this account?')) {
        createForm.delete(accountsRoutes.destroy(id).url);
    }
};
</script>

<template>
    <Head title="Accounts" />

    <AppLayout :breadcrumbs="breadcrumbs">
        <div class="flex h-full flex-1 flex-col gap-6 p-6">
            <div class="flex items-center justify-between">
                <div class="space-y-1">
                    <h2 class="text-3xl font-extrabold tracking-tight">Accounts</h2>
                    <p class="text-muted-foreground">
                        Manage your bank accounts and digital wallets.
                    </p>
                </div>

                <Dialog v-model:open="isCreateModalOpen">
                    <DialogTrigger as-child>
                        <Button class="rounded-full px-6 shadow-lg shadow-primary/20">
                            <Plus class="mr-2 h-4 w-4" />
                            Add Account
                        </Button>
                    </DialogTrigger>
                    <DialogContent class="glass max-w-md">
                        <form @submit.prevent="submitCreate">
                            <DialogHeader>
                                <DialogTitle>Add Account</DialogTitle>
                                <DialogDescription>
                                    Create a new account or wallet to track your expenses.
                                </DialogDescription>
                            </DialogHeader>
                            <div class="grid gap-6 py-4">
                                <div class="grid gap-2">
                                    <Label for="name">Account Name</Label>
                                    <Input id="name" v-model="createForm.name" placeholder="e.g. Cash, GCash, BPI" required class="rounded-xl" />
                                    <div v-if="createForm.errors.name" class="text-sm text-destructive">{{ createForm.errors.name }}</div>
                                </div>
                                
                                <div class="grid gap-2">
                                    <Label>Choose Icon</Label>
                                    <div class="flex flex-wrap gap-2">
                                        <Button 
                                            v-for="icon in icons" 
                                            :key="icon.name" 
                                            type="button" 
                                            variant="outline" 
                                            size="icon" 
                                            class="h-12 w-12 rounded-xl border-2 transition-all"
                                            :class="createForm.icon === icon.name ? 'border-primary bg-primary/10' : 'border-border/50'"
                                            @click="createForm.icon = icon.name"
                                        >
                                            <component :is="icon.component" class="h-5 w-5" />
                                        </Button>
                                    </div>
                                </div>

                                <div class="grid grid-cols-2 gap-4">
                                    <div class="grid gap-2">
                                        <Label for="balance">Initial Balance</Label>
                                        <Input id="balance" type="number" step="0.01" v-model="createForm.balance" required class="rounded-xl" />
                                    </div>
                                    <div class="grid gap-2">
                                        <Label for="currency">Currency</Label>
                                        <Input id="currency" v-model="createForm.currency" placeholder="PHP" required class="rounded-xl" />
                                    </div>
                                </div>
                            </div>
                            <DialogFooter>
                                <Button type="submit" :disabled="createForm.processing" class="w-full rounded-xl">
                                    Save Account
                                </Button>
                            </DialogFooter>
                        </form>
                    </DialogContent>
                </Dialog>
            </div>

            <!-- Edit Modal -->
            <Dialog v-model:open="isEditModalOpen">
                <DialogContent class="glass max-w-md">
                    <form @submit.prevent="submitUpdate">
                        <DialogHeader>
                            <DialogTitle>Edit Account</DialogTitle>
                            <DialogDescription>
                                Update your account details and icon.
                            </DialogDescription>
                        </DialogHeader>
                        <div class="grid gap-6 py-4">
                            <div class="grid gap-2">
                                <Label for="edit-name">Account Name</Label>
                                <Input id="edit-name" v-model="editForm.name" required class="rounded-xl" />
                            </div>
                            
                            <div class="grid gap-2">
                                <Label>Choose Icon</Label>
                                <div class="flex flex-wrap gap-2">
                                    <Button 
                                        v-for="icon in icons" 
                                        :key="icon.name" 
                                        type="button" 
                                        variant="outline" 
                                        size="icon" 
                                        class="h-12 w-12 rounded-xl border-2 transition-all"
                                        :class="editForm.icon === icon.name ? 'border-primary bg-primary/10' : 'border-border/50'"
                                        @click="editForm.icon = icon.name"
                                    >
                                        <component :is="icon.component" class="h-5 w-5" />
                                    </Button>
                                </div>
                            </div>

                            <div class="grid grid-cols-2 gap-4">
                                <div class="grid gap-2">
                                    <Label for="edit-balance">Balance</Label>
                                    <Input id="edit-balance" type="number" step="0.01" v-model="editForm.balance" required class="rounded-xl" />
                                </div>
                                <div class="grid gap-2">
                                    <Label for="edit-currency">Currency</Label>
                                    <Input id="edit-currency" v-model="editForm.currency" required class="rounded-xl" />
                                </div>
                            </div>
                        </div>
                        <DialogFooter>
                            <Button type="submit" :disabled="editForm.processing" class="w-full rounded-xl">
                                Update Account
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>

            <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
                <Card v-for="account in accounts?.data || []" :key="account.id" class="glass-card border-none bg-gradient-to-br from-primary/10 to-transparent group overflow-hidden">
                    <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
                        <div class="space-y-1">
                            <CardTitle class="text-sm font-bold uppercase tracking-widest opacity-70">
                                {{ account.name }}
                            </CardTitle>
                            <p class="text-[10px] font-medium opacity-50">{{ account.currency }} ACCOUNT</p>
                        </div>
                        <div class="rounded-2xl bg-primary/10 p-3 transition-all group-hover:scale-110 group-hover:bg-primary/20">
                            <component :is="getIcon(account.icon)" class="h-5 w-5 text-primary" />
                        </div>
                    </CardHeader>
                    <CardContent>
                        <div class="mt-4 text-3xl font-black tracking-tighter">{{ account.formatted_balance }}</div>
                        
                        <div class="mt-8 flex items-center justify-between">
                            <div class="flex -space-x-2">
                                <div class="h-8 w-8 rounded-full border-2 border-background bg-muted"></div>
                                <div class="h-8 w-8 rounded-full border-2 border-background bg-muted"></div>
                            </div>
                            <div class="flex items-center gap-1">
                                <Button variant="ghost" size="icon" @click="openEditModal(account)" class="rounded-full hover:bg-primary/10 hover:text-primary transition-colors">
                                    <Edit2 class="h-4 w-4" />
                                </Button>
                                <Button variant="ghost" size="icon" @click="deleteAccount(account.id)" class="rounded-full hover:bg-destructive/10 hover:text-destructive transition-colors">
                                    <Trash2 class="h-4 w-4" />
                                </Button>
                            </div>
                        </div>
                    </CardContent>
                </Card>

                <div v-if="!accounts?.data?.length" class="col-span-full flex flex-col items-center justify-center rounded-3xl border-2 border-dashed p-24 text-center border-border/50">
                    <div class="mb-6 rounded-full bg-muted p-6">
                        <Wallet class="h-12 w-12 text-muted-foreground opacity-20" />
                    </div>
                    <h3 class="text-2xl font-bold">No accounts found</h3>
                    <p class="mt-2 max-w-sm text-muted-foreground">Get started by creating your first account or digital wallet to track your money.</p>
                    <Button variant="outline" @click="isCreateModalOpen = true" class="mt-8 rounded-full px-8 glass border-none">
                        Create your first account
                    </Button>
                </div>
            </div>
        </div>
    </AppLayout>
</template>
