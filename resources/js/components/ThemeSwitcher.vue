<script setup lang="ts">
import { Moon, Sun, Monitor } from 'lucide-vue-next';
import { Button } from '@/components/ui/button';
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { useAppearance } from '@/composables/useAppearance';

const { appearance, updateAppearance } = useAppearance();
</script>

<template>
    <DropdownMenu>
        <DropdownMenuTrigger as-child>
            <Button variant="ghost" size="icon" class="h-9 w-9">
                <Sun v-if="appearance === 'light'" class="h-4 w-4" />
                <Moon v-else-if="appearance === 'dark'" class="h-4 w-4" />
                <Monitor v-else class="h-4 w-4" />
                <span class="sr-only">Toggle theme</span>
            </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
            <DropdownMenuItem @click="updateAppearance('light')" :class="{ 'bg-accent': appearance === 'light' }">
                <Sun class="mr-2 h-4 w-4" />
                <span>Light</span>
            </DropdownMenuItem>
            <DropdownMenuItem @click="updateAppearance('dark')" :class="{ 'bg-accent': appearance === 'dark' }">
                <Moon class="mr-2 h-4 w-4" />
                <span>Dark</span>
            </DropdownMenuItem>
            <DropdownMenuItem @click="updateAppearance('system')" :class="{ 'bg-accent': appearance === 'system' }">
                <Monitor class="mr-2 h-4 w-4" />
                <span>System</span>
            </DropdownMenuItem>
        </DropdownMenuContent>
    </DropdownMenu>
</template>
