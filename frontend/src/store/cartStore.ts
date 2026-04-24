import { create } from 'zustand';
import type { CartItem, Product } from '../types';
interface CartState {
    items: CartItem[];
    addItem: (product: Product, quantity?: number) => void;
    removeItem: (productId: string) => void;
    updateQuantity: (productId: string, quantity: number) => void;
    clearCart: () => void;
    getTotalAmount: () => number;
    getTotalItems: () => number;
}
export const useCartStore = create<CartState>((set, get) => ({
    items: JSON.parse(localStorage.getItem('cronos_cart') || '[]'),
    addItem: (product, quantity = 1) => {
        set((state) => {
            const existing = state.items.find((i) => i.product.id === product.id);
            let newItems: CartItem[];
            if (existing) {
                newItems = state.items.map((i) =>
                    i.product.id === product.id ? { ...i, quantity: i.quantity + quantity } : i
                );
            } else {
                newItems = [...state.items, { product, quantity }];
            }
            localStorage.setItem('cronos_cart', JSON.stringify(newItems));
            return { items: newItems };
        });
    },
    removeItem: (productId) => {
        set((state) => {
            const newItems = state.items.filter((i) => i.product.id !== productId);
            localStorage.setItem('cronos_cart', JSON.stringify(newItems));
            return { items: newItems };
        });
    },
    updateQuantity: (productId, quantity) => {
        set((state) => {
            const newItems = state.items.map((i) =>
                i.product.id === productId ? { ...i, quantity: Math.max(1, quantity) } : i
            );
            localStorage.setItem('cronos_cart', JSON.stringify(newItems));
            return { items: newItems };
        });
    },
    clearCart: () => {
        localStorage.removeItem('cronos_cart');
        set({ items: [] });
    },
    getTotalAmount: () => get().items.reduce((sum, i) => sum + i.product.price * i.quantity, 0),
    getTotalItems: () => get().items.reduce((sum, i) => sum + i.quantity, 0),
}));
