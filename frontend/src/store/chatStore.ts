import { create } from 'zustand';
import axios from 'axios';

interface Message {
    id: string;
    room_id: string;
    sender_id: string;
    content: string;
    created_at: string;
    sender: { name: string };
}

interface Room {
    id: string;
    name: string;
    type: string;
    members: any[];
}

interface ChatState {
    rooms: Room[];
    users: any[];
    messages: Record<string, Message[]>;
    activeRoomId: string | null;
    socket: WebSocket | null;
    loading: boolean;

    fetchRooms: (userId: string) => Promise<void>;
    fetchUsers: () => Promise<void>;
    fetchMessages: (roomId: string) => Promise<void>;
    createRoom: (name: string, type: string, userIds: string[]) => Promise<string | null>;
    connect: (userId: string) => void;
    disconnect: () => void;
    sendMessage: (roomId: string, content: string) => void;
    setActiveRoom: (roomId: string) => void;
}

const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:8081/api';
const WS_BASE = API_BASE.replace('http', 'ws') + '/chat/ws';

export const useChatStore = create<ChatState>((set, get) => ({
    rooms: [],
    users: [],
    messages: {},
    activeRoomId: null,
    socket: null,
    loading: false,

    fetchRooms: async (userId) => {
        set({ loading: true });
        try {
            const res = await axios.get(`${API_BASE}/chat/rooms/${userId}`);
            set({ rooms: res.data.data || [] });
        } catch (err) {
            console.error('Failed to fetch rooms', err);
        } finally {
            set({ loading: false });
        }
    },

    fetchUsers: async () => {
        try {
            const res = await axios.get(`${API_BASE}/chat/users`);
            set({ users: res.data.data || [] });
        } catch (err) {
            console.error('Failed to fetch users', err);
        }
    },

    createRoom: async (name, type, userIds) => {
        try {
            const res = await axios.post(`${API_BASE}/chat/rooms`, { name, type, target_user_id: userIds[0] });
            const newRoom = res.data.data;
            set((state) => ({
                rooms: state.rooms.some(r => r.id === newRoom.id) ? state.rooms : [newRoom, ...state.rooms]
            }));
            return newRoom.id;
        } catch (err) {
            console.error('Failed to create room', err);
            return null;
        }
    },

    fetchMessages: async (roomId) => {
        try {
            const res = await axios.get(`${API_BASE}/chat/messages/${roomId}`);
            set((state) => ({
                messages: { ...state.messages, [roomId]: res.data.data || [] }
            }));
        } catch (err) {
            console.error('Failed to fetch messages', err);
        }
    },

    connect: (userId) => {
        if (get().socket) return;
        const currentUserId = userId;
        const socket = new WebSocket(`${WS_BASE}?user_id=${userId}`);

        socket.onmessage = (event) => {
            const data = JSON.parse(event.data);
            if (data.id) { // New message
                const msg = data as Message;
                set((state) => {
                    const roomMessages = state.messages[msg.room_id] || [];
                    return {
                        messages: {
                            ...state.messages,
                            [msg.room_id]: [...roomMessages, msg]
                        }
                    };
                });
            }
        };

        socket.onclose = () => {
            set({ socket: null });
            // Auto-reconnect after 3 seconds
            setTimeout(() => {
                if (currentUserId) get().connect(currentUserId);
            }, 3000);
        };

        set({ socket });
    },

    disconnect: () => {
        get().socket?.close();
        set({ socket: null });
    },

    sendMessage: (roomId, content) => {
        const socket = get().socket;
        if (socket && socket.readyState === WebSocket.OPEN) {
            socket.send(JSON.stringify({
                type: 'message',
                room_id: roomId,
                content: content
            }));
        }
    },

    setActiveRoom: (roomId) => {
        set({ activeRoomId: roomId });
        const socket = get().socket;
        if (socket && socket.readyState === WebSocket.OPEN) {
            socket.send(JSON.stringify({
                type: 'join',
                room_id: roomId
            }));
        }
    }
}));
