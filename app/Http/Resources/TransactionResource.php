<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TransactionResource extends JsonResource
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
            'type' => $this->type,
            'amount' => $this->amount / 100,
            'formatted_amount' => number_format($this->amount / 100, 2),
            'description' => $this->description,
            'date' => $this->date->format('Y-m-d'),
            'account_id' => $this->account_id,
            'destination_account_id' => $this->destination_account_id,
            'category_id' => $this->category_id,
            'account' => new AccountResource($this->whenLoaded('account')),
            'destination_account' => new AccountResource($this->whenLoaded('destinationAccount')),
            'category' => new CategoryResource($this->whenLoaded('category')),
        ];
    }
}
