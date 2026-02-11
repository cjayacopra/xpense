<script setup lang="ts">
import { Link } from '@inertiajs/vue3';
import { LayoutGrid, Receipt, Wallet, Tag, Info } from 'lucide-vue-next';
import NavFooter from '@/components/NavFooter.vue';
import NavMain from '@/components/NavMain.vue';
import NavUser from '@/components/NavUser.vue';
import {
    Sidebar,
    SidebarContent,
    SidebarFooter,
    SidebarHeader,
    SidebarMenu,
    SidebarMenuButton,
    SidebarMenuItem,
} from '@/components/ui/sidebar';
import { dashboard, about } from '@/routes';
import accounts from '@/routes/accounts';
import categories from '@/routes/categories';
import transactions from '@/routes/transactions';
import { type NavItem } from '@/types';
import AppLogo from './AppLogo.vue';

const mainNavItems: NavItem[] = [
    {
        title: 'Dashboard',
        href: dashboard().url,
        icon: LayoutGrid,
    },
    {
        title: 'Transactions',
        href: transactions.index().url,
        icon: Receipt,
    },
    {
        title: 'Accounts',
        href: accounts.index().url,
        icon: Wallet,
    },
    {
        title: 'Categories',
        href: categories.index().url,
        icon: Tag,
    },
];

const footerNavItems: NavItem[] = [
    {
        title: 'About Xpense',
        href: about().url,
        icon: Info,
    },
];
</script>

<template>
    <Sidebar collapsible="icon" variant="inset">
        <SidebarHeader>
            <SidebarMenu>
                <SidebarMenuItem>
                    <SidebarMenuButton size="lg" as-child>
                        <Link :href="dashboard().url">
                            <AppLogo />
                        </Link>
                    </SidebarMenuButton>
                </SidebarMenuItem>
            </SidebarMenu>
        </SidebarHeader>

        <SidebarContent>
            <NavMain :items="mainNavItems" />
        </SidebarContent>

        <SidebarFooter>
            <NavFooter :items="footerNavItems" />
            <NavUser />
        </SidebarFooter>
    </Sidebar>
    <slot />
</template>
