<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import AppLogo from '@/components/AppLogo.vue';
import { dashboard, login, register } from '@/routes';

withDefaults(
    defineProps<{
        canRegister: boolean;
    }>(),
    {
        canRegister: true,
    },
);
</script>

<template>
    <Head title="Welcome">
        <link rel="preconnect" href="https://rsms.me/" />
        <link rel="stylesheet" href="https://rsms.me/inter/inter.css" />
    </Head>
    <div
        class="flex min-h-screen flex-col items-center bg-[#FDFDFC] p-6 text-[#1b1b18] lg:justify-center lg:p-8 dark:bg-[#0a0a0a]"
    >
        <header
            class="mb-6 w-full max-w-[335px] text-sm lg:max-w-4xl"
        >
            <nav class="flex items-center justify-between gap-4">
                <div class="flex items-center gap-2">
                    <AppLogo />
                </div>
                <div class="flex items-center gap-4">
                    <Link
                        v-if="$page.props.auth.user"
                        :href="dashboard().url"
                        class="inline-block rounded-sm border border-[#19140035] px-5 py-1.5 text-sm font-medium leading-normal text-[#1b1b18] hover:border-[#1915014a] dark:border-[#3E3E3A] dark:text-[#EDEDEC] dark:hover:border-[#62605b]"
                    >
                        Dashboard
                    </Link>
                    <template v-else>
                        <Link
                            :href="login().url"
                            class="inline-block rounded-sm border border-transparent px-5 py-1.5 text-sm font-medium leading-normal text-[#1b1b18] hover:border-[#19140035] dark:text-[#EDEDEC] dark:hover:border-[#3E3E3A]"
                        >
                            Log in
                        </Link>
                        <Link
                            v-if="canRegister"
                            :href="register().url"
                            class="inline-block rounded-sm border border-[#19140035] px-5 py-1.5 text-sm font-medium leading-normal text-[#1b1b18] hover:border-[#1915014a] dark:border-[#3E3E3A] dark:text-[#EDEDEC] dark:hover:border-[#62605b]"
                        >
                            Register
                        </Link>
                    </template>
                </div>
            </nav>
        </header>
        
        <main class="flex w-full max-w-4xl flex-col items-center justify-center py-12 text-center lg:py-24">
            <h1 class="mb-4 text-4xl font-extrabold tracking-tight lg:text-6xl dark:text-white">
                Manage your expenses with <span class="text-destructive">Xpense</span>
            </h1>
            <p class="mb-8 max-w-2xl text-lg text-muted-foreground lg:text-xl">
                The simple, elegant way to track your daily spending, manage multiple accounts, and stay on top of your financial goals.
            </p>
            
            <div class="flex flex-col gap-4 sm:flex-row">
                <Link
                    v-if="!$page.props.auth.user"
                    :href="register().url"
                    class="inline-flex h-12 items-center justify-center rounded-md bg-primary px-8 text-sm font-medium text-primary-foreground shadow transition-colors hover:bg-primary/90 focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
                >
                    Get Started for Free
                </Link>
                <Link
                    v-else
                    :href="dashboard().url"
                    class="inline-flex h-12 items-center justify-center rounded-md bg-primary px-8 text-sm font-medium text-primary-foreground shadow transition-colors hover:bg-primary/90 focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
                >
                    Go to Dashboard
                </Link>
            </div>
            
            <div class="mt-16 grid w-full grid-cols-1 gap-8 text-left md:grid-cols-3 lg:mt-24">
                <div class="rounded-xl border bg-card p-6 shadow-sm">
                    <h3 class="mb-2 text-xl font-bold">Multi-Account</h3>
                    <p class="text-muted-foreground">Track cash, bank accounts, and digital wallets all in one place.</p>
                </div>
                <div class="rounded-xl border bg-card p-6 shadow-sm">
                    <h3 class="mb-2 text-xl font-bold">Categorized</h3>
                    <p class="text-muted-foreground">Organize your spending with custom categories and colors.</p>
                </div>
                <div class="rounded-xl border bg-card p-6 shadow-sm">
                    <h3 class="mb-2 text-xl font-bold">Insights</h3>
                    <p class="text-muted-foreground">Get a clear overview of your monthly spending patterns instantly.</p>
                </div>
            </div>
        </main>

        <footer class="mt-auto py-8 text-center text-sm text-muted-foreground">
            &copy; 2026 Xpense. Built with Laravel 12 and Inertia.js.
        </footer>
    </div>
</template>
