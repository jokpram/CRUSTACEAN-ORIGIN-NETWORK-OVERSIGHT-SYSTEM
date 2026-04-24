export interface User {
    id: string;
    name: string;
    email: string;
    phone: string;
    role: 'admin' | 'petambak' | 'logistik' | 'konsumen';
    is_verified: boolean;
    address: string;
    avatar: string;
    balance: number;
    created_at: string;
}
export interface Farm {
    id: string;
    user_id: string;
    name: string;
    location: string;
    area: number;
    description: string;
    image: string;
    ponds?: Pond[];
    user?: User;
    created_at: string;
}
export interface Pond {
    id: string;
    farm_id: string;
    name: string;
    area: number;
    depth: number;
    status: string;
    farm?: Farm;
    created_at: string;
}
export interface ShrimpType {
    id: string;
    name: string;
    description: string;
    image: string;
}
export interface CultivationCycle {
    id: string;
    pond_id: string;
    shrimp_type_id: string;
    start_date: string;
    expected_end_date?: string;
    actual_end_date?: string;
    status: string;
    density: number;
    notes: string;
    pond?: Pond;
    shrimp_type?: ShrimpType;
    feed_logs?: FeedLog[];
    water_quality_logs?: WaterQualityLog[];
    harvests?: Harvest[];
    created_at: string;
}
export interface FeedLog {
    id: string;
    cultivation_cycle_id: string;
    feed_type: string;
    quantity: number;
    feeding_time: string;
    notes: string;
    created_at: string;
}
export interface WaterQualityLog {
    id: string;
    cultivation_cycle_id: string;
    temperature: number;
    ph: number;
    salinity: number;
    dissolved_oxygen: number;
    recorded_at: string;
    notes: string;
    created_at: string;
}
export interface Harvest {
    id: string;
    cultivation_cycle_id: string;
    harvest_date: string;
    total_weight: number;
    shrimp_size: string;
    quality_grade: string;
    notes: string;
    cultivation_cycle?: CultivationCycle;
    batches?: Batch[];
    created_at: string;
}
export interface Batch {
    id: string;
    harvest_id: string;
    batch_code: string;
    quantity: number;
    status: string;
    harvest?: Harvest;
    created_at: string;
}
export interface Product {
    id: string;
    user_id: string;
    batch_id?: string;
    name: string;
    description: string;
    price: number;
    stock: number;
    shrimp_type: string;
    size: string;
    unit: string;
    is_available: boolean;
    rating_avg: number;
    rating_count: number;
    user?: User;
    batch?: Batch;
    images?: ProductImage[];
    reviews?: Review[];
    created_at: string;
}
export interface ProductImage {
    id: string;
    product_id: string;
    image_url: string;
    is_primary: boolean;
}
export interface Order {
    id: string;
    user_id: string;
    total_amount: number;
    status: string;
    shipping_address: string;
    notes: string;
    user?: User;
    order_items?: OrderItem[];
    payment?: Payment;
    shipment?: Shipment;
    created_at: string;
}
export interface OrderItem {
    id: string;
    order_id: string;
    product_id: string;
    quantity: number;
    price: number;
    subtotal: number;
    product?: Product;
}
export interface Payment {
    id: string;
    order_id: string;
    amount: number;
    method: string;
    status: string;
    paid_at?: string;
    midtrans_transaction?: MidtransTransaction;
}
export interface MidtransTransaction {
    id: string;
    payment_id: string;
    order_id_midtrans: string;
    snap_token: string;
    snap_url: string;
    transaction_status: string;
    payment_type: string;
}
export interface Shipment {
    id: string;
    order_id: string;
    courier_id?: string;
    tracking_number: string;
    status: string;
    estimated_delivery?: string;
    actual_delivery?: string;
    order?: Order;
    courier?: User;
    shipment_logs?: ShipmentLog[];
    created_at: string;
}
export interface ShipmentLog {
    id: string;
    shipment_id: string;
    status: string;
    location: string;
    notes: string;
    timestamp: string;
}
export interface TraceabilityLog {
    id: string;
    previous_hash: string;
    current_hash: string;
    timestamp: string;
    event_type: string;
    actor_id: string;
    entity_type: string;
    entity_id: string;
    data_payload: string;
    actor?: User;
}
export interface Withdrawal {
    id: string;
    user_id: string;
    amount: number;
    bank_name: string;
    account_number: string;
    account_name: string;
    status: string;
    notes: string;
    processed_at?: string;
    user?: User;
    created_at: string;
}
export interface Review {
    id: string;
    user_id: string;
    product_id: string;
    rating: number;
    comment: string;
    user?: User;
    created_at: string;
}
export interface ApiResponse<T> {
    success: boolean;
    message: string;
    data: T;
    meta?: PaginationMeta;
}
export interface ApiErrorResponse {
    success: boolean;
    message: string;
    errors?: string[];
}
export interface PaginationMeta {
    current_page: number;
    per_page: number;
    total: number;
    total_pages: number;
}
export interface CartItem {
    product: Product;
    quantity: number;
}
