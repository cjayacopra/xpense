<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AccountResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'balance' => $this->balance / 100, // Convert cents to units
            'currency' => $this->currency,
            'icon' => $this->icon ?? 'Wallet',
            'formatted_balance' => number_format($this->balance / 100, 2) . ' ' . $this->currency,
        ];
    }
}
