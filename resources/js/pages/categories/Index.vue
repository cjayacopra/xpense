<script setup lang="ts">
import { Head, useForm } from '@inertiajs/vue3';
import { 
    Plus, Tag, Trash2, Edit2, ShoppingCart, Utensils, Car, Home, 
    Zap, Heart, Gift, Briefcase, GraduationCap, Plane, Coffee 
} from 'lucide-vue-next';
import AppLayout from '@/layouts/AppLayout.vue';
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
import categoriesRoutes from '@/routes/categories';
import { type BreadcrumbItem } from '@/types';
import { ref } from 'vue';

interface Category {
    id: number;
    name: string;
    icon: string;
    color: string;
}

defineProps<{
    categories?: {
        data: Category[];
    };
}>();

const breadcrumbs: BreadcrumbItem[] = [
    {
        title: 'Categories',
        href: categoriesRoutes.index().url,
    },
];

const icons = [
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

const getIcon = (name: string) => {
    return icons.find(i => i.name === name)?.component || Tag;
};

const isCreateModalOpen = ref(false);
const isEditModalOpen = ref(false);
const editingCategory = ref<Category | null>(null);

const createForm = useForm({
    name: '',
    icon: 'Tag',
    color: '#3b82f6',
});

const editForm = useForm({
    name: '',
    icon: 'Tag',
    color: '#3b82f6',
});

const submitCreate = () => {
    createForm.post(categoriesRoutes.store().url, {
        onSuccess: () => {
            isCreateModalOpen.value = false;
            createForm.reset();
        },
    });
};

const openEditModal = (category: Category) => {
    editingCategory.value = category;
    editForm.name = category.name;
    editForm.icon = category.icon || 'Tag';
    editForm.color = category.color || '#3b82f6';
    isEditModalOpen.value = true;
};

const submitUpdate = () => {
    if (!editingCategory.value) return;
    
    editForm.put(categoriesRoutes.update(editingCategory.value.id).url, {
        onSuccess: () => {
            isEditModalOpen.value = false;
            editingCategory.value = null;
            editForm.reset();
        },
    });
};

const deleteCategory = (id: number) => {
    if (confirm('Are you sure you want to delete this category?')) {
        createForm.delete(categoriesRoutes.destroy(id).url);
    }
};
</script>

<template>
    <Head title="Categories" />

    <AppLayout :breadcrumbs="breadcrumbs">
        <div class="flex h-full flex-1 flex-col gap-6 p-6">
            <div class="flex items-center justify-between">
                <div class="space-y-1">
                    <h2 class="text-3xl font-extrabold tracking-tight">Categories</h2>
                    <p class="text-muted-foreground">
                        Organize your transactions with custom categories and icons.
                    </p>
                </div>

                <Dialog v-model:open="isCreateModalOpen">
                    <DialogTrigger as-child>
                        <Button class="rounded-full px-6 shadow-lg shadow-primary/20">
                            <Plus class="mr-2 h-4 w-4" />
                            Add Category
                        </Button>
                    </DialogTrigger>
                    <DialogContent class="glass max-w-md">
                        <form @submit.prevent="submitCreate">
                            <DialogHeader>
                                <DialogTitle>Add Category</DialogTitle>
                                <DialogDescription>
                                    Create a new category to group your expenses.
                                </DialogDescription>
                            </DialogHeader>
                            <div class="grid gap-6 py-4">
                                <div class="grid gap-2">
                                    <Label for="name">Category Name</Label>
                                    <Input
                                        id="name"
                                        v-model="createForm.name"
                                        placeholder="e.g. Food, Transport, Rent"
                                        required
                                        class="rounded-xl"
                                    />
                                </div>

                                <div class="grid gap-2">
                                    <Label>Choose Icon</Label>
                                    <div class="grid grid-cols-6 gap-2">
                                        <Button 
                                            v-for="icon in icons" 
                                            :key="icon.name" 
                                            type="button" 
                                            variant="outline" 
                                            size="icon" 
                                            class="h-10 w-10 rounded-xl border-2 transition-all"
                                            :class="createForm.icon === icon.name ? 'border-primary bg-primary/10' : 'border-border/50'"
                                            @click="createForm.icon = icon.name"
                                        >
                                            <component :is="icon.component" class="h-4 w-4" />
                                        </Button>
                                    </div>
                                </div>

                                <div class="grid gap-2">
                                    <Label for="color">Color</Label>
                                    <div class="flex items-center gap-3">
                                        <Input
                                            id="color"
                                            type="color"
                                            v-model="createForm.color"
                                            class="h-12 w-24 p-1 rounded-xl cursor-pointer"
                                        />
                                        <span class="text-sm font-mono text-muted-foreground uppercase">{{ createForm.color }}</span>
                                    </div>
                                </div>
                            </div>
                            <DialogFooter>
                                <Button type="submit" :disabled="createForm.processing" class="w-full rounded-xl">
                                    Save Category
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
                            <DialogTitle>Edit Category</DialogTitle>
                            <DialogDescription>
                                Update the category name, icon, or color.
                            </DialogDescription>
                        </DialogHeader>
                        <div class="grid gap-6 py-4">
                            <div class="grid gap-2">
                                <Label for="edit-name">Category Name</Label>
                                <Input
                                    id="edit-name"
                                    v-model="editForm.name"
                                    required
                                    class="rounded-xl"
                                />
                            </div>

                            <div class="grid gap-2">
                                <Label>Choose Icon</Label>
                                <div class="grid grid-cols-6 gap-2">
                                    <Button 
                                        v-for="icon in icons" 
                                        :key="icon.name" 
                                        type="button" 
                                        variant="outline" 
                                        size="icon" 
                                        class="h-10 w-10 rounded-xl border-2 transition-all"
                                        :class="editForm.icon === icon.name ? 'border-primary bg-primary/10' : 'border-border/50'"
                                        @click="editForm.icon = icon.name"
                                    >
                                        <component :is="icon.component" class="h-4 w-4" />
                                    </Button>
                                </div>
                            </div>

                            <div class="grid gap-2">
                                <Label for="edit-color">Color</Label>
                                <div class="flex items-center gap-3">
                                    <Input
                                        id="edit-color"
                                        type="color"
                                        v-model="editForm.color"
                                        class="h-12 w-24 p-1 rounded-xl cursor-pointer"
                                    />
                                    <span class="text-sm font-mono text-muted-foreground uppercase">{{ editForm.color }}</span>
                                </div>
                            </div>
                        </div>
                        <DialogFooter>
                            <Button type="submit" :disabled="editForm.processing" class="w-full rounded-xl">
                                Update Category
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>

            <div class="grid gap-6 md:grid-cols-3 lg:grid-cols-4">
                <Card v-for="category in categories?.data || []" :key="category.id" class="glass-card border-none bg-card/50 overflow-hidden group">
                    <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-4">
                        <div class="flex items-center gap-4">
                            <div 
                                class="flex h-12 w-12 items-center justify-center rounded-2xl border-2 border-white/20 shadow-xl transition-transform group-hover:scale-110" 
                                :style="{ backgroundColor: category.color || '#ccc' }"
                            >
                                <component :is="getIcon(category.icon)" class="h-6 w-6 text-white" />
                            </div>
                            <div class="space-y-0.5">
                                <CardTitle class="text-lg font-bold uppercase tracking-tight">
                                    {{ category.name }}
                                </CardTitle>
                                <p class="text-[10px] font-medium text-muted-foreground uppercase tracking-widest">{{ category.color }}</p>
                            </div>
                        </div>
                    </CardHeader>
                    <CardContent>
                        <div class="flex justify-end gap-1">
                            <Button variant="ghost" size="icon" @click="openEditModal(category)" class="rounded-full hover:bg-primary/10 hover:text-primary transition-colors">
                                <Edit2 class="h-4 w-4" />
                            </Button>
                            <Button variant="ghost" size="icon" @click="deleteCategory(category.id)" class="rounded-full hover:bg-destructive/10 hover:text-destructive transition-colors">
                                <Trash2 class="h-4 w-4" />
                            </Button>
                        </div>
                    </CardContent>
                </Card>

                <div v-if="!categories?.data?.length" class="col-span-full flex flex-col items-center justify-center rounded-3xl border-2 border-dashed p-24 text-center border-border/50">
                    <div class="mb-6 rounded-full bg-muted p-6">
                        <Tag class="h-12 w-12 text-muted-foreground opacity-20" />
                    </div>
                    <h3 class="text-2xl font-bold">No categories found</h3>
                    <p class="mt-2 max-w-sm text-muted-foreground">Add your first category to start organizing your spending habits effectively.</p>
                    <Button variant="outline" @click="isCreateModalOpen = true" class="mt-8 rounded-full px-8 glass border-none">
                        Create a category
                    </Button>
                </div>
            </div>
        </div>
    </AppLayout>
</template>
