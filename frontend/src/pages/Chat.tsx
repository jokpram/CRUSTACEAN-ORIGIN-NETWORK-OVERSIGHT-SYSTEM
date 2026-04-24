import { useState, useEffect, useRef } from 'react';
import { useAuthStore } from '../store/authStore';
import { useChatStore } from '../store/chatStore';
import { LoadingSpinner, EmptyState, Modal } from '../components/ui';
import { FiSend, FiUser, FiMessageSquare, FiPlus, FiSearch } from 'react-icons/fi';
import { useTranslation } from 'react-i18next';
import { format } from 'date-fns';

export default function Chat() {
    const { user } = useAuthStore();
    const { rooms, users, messages, activeRoomId, loading, fetchRooms, fetchUsers, fetchMessages, createRoom, connect, disconnect, sendMessage, setActiveRoom } = useChatStore();
    const { t } = useTranslation();
    const [msgInput, setMsgInput] = useState('');
    const [showUserModal, setShowUserModal] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');
    const scrollRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        if (user) {
            connect(user.id);
            fetchRooms(user.id);
            fetchUsers();
        }
        return () => disconnect();
    }, [user]);

    useEffect(() => {
        if (scrollRef.current) {
            scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
        }
    }, [messages, activeRoomId]);

    const handleSend = (e: React.FormEvent) => {
        e.preventDefault();
        if (!msgInput.trim() || !activeRoomId) return;
        sendMessage(activeRoomId, msgInput);
        setMsgInput('');
    };

    const handleRoomSelect = (roomId: string) => {
        setActiveRoom(roomId);
        fetchMessages(roomId);
    };

    const handleCreatePrivateChat = async (targetUser: any) => {
        if (!user) return;
        const roomId = await createRoom(targetUser.name, 'private', [user.id, targetUser.id]);
        if (roomId) {
            handleRoomSelect(roomId);
            setShowUserModal(false);
        }
    };

    const filteredUsers = users.filter(u =>
        u.id !== user?.id &&
        (
            u.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
            u.role.toLowerCase().includes(searchTerm.toLowerCase()) ||
            (u.email && u.email.toLowerCase().includes(searchTerm.toLowerCase()))
        )
    );
    const groupedUsers = filteredUsers.reduce((acc, u) => {
        if (!acc[u.role]) acc[u.role] = [];
        acc[u.role].push(u);
        return acc;
    }, {} as Record<string, any[]>);

    if (loading && rooms.length === 0) return <LoadingSpinner />;

    return (
        <div className="flex h-[calc(100vh-120px)] gap-6">
            { }
            <div className="w-80 card flex flex-col overflow-hidden">
                <div className="p-4 border-b flex items-center justify-between">
                    <h2 className="font-bold text-lg flex items-center gap-2">
                        <FiMessageSquare /> {t('chat.messages', 'Messages')}
                    </h2>
                    <button
                        onClick={() => setShowUserModal(true)}
                        className="p-2 bg-primary-100 text-primary-600 rounded-lg hover:bg-primary-200 transition-colors"
                        title={t('chat.new_chat', 'New Chat')}
                    >
                        <FiPlus />
                    </button>
                </div>
                <div className="flex-1 overflow-y-auto">
                    {rooms.length === 0 ? (
                        <div className="p-8 text-center text-gray-400 text-sm">
                            {t('chat.no_rooms', 'No conversations yet.')}
                        </div>
                    ) : (
                        rooms.map((room) => (
                            <button
                                key={room.id}
                                onClick={() => handleRoomSelect(room.id)}
                                className={`w-full p-4 flex items-center gap-3 hover:bg-gray-50 transition-colors text-left border-b border-gray-100 ${activeRoomId === room.id ? 'bg-primary-50' : ''
                                    }`}
                            >
                                <div className="w-10 h-10 rounded-full bg-gradient-to-br from-ocean-100 to-ocean-200 flex items-center justify-center text-ocean-600">
                                    <FiUser />
                                </div>
                                <div className="flex-1 min-w-0">
                                    <p className="font-medium text-sm truncate">
                                        {room.type === 'private'
                                            ? room.members.find(m => m.id !== user?.id)?.name || room.name
                                            : room.name}
                                    </p>
                                    <p className="text-xs text-gray-500 truncate capitalize">{room.type}</p>
                                </div>
                            </button>
                        ))
                    )}
                </div>
            </div>

            { }
            <div className="flex-1 card flex flex-col overflow-hidden bg-white">
                {activeRoomId ? (
                    <>
                        <div className="p-4 border-b bg-gray-50 flex items-center gap-3">
                            <div className="w-8 h-8 rounded-full bg-primary-100 text-primary-600 flex items-center justify-center">
                                <FiUser />
                            </div>
                            <h3 className="font-bold text-gray-900">
                                {rooms.find(r => r.id === activeRoomId)?.type === 'private'
                                    ? rooms.find(r => r.id === activeRoomId)?.members.find(m => m.id !== user?.id)?.name || rooms.find(r => r.id === activeRoomId)?.name
                                    : rooms.find(r => r.id === activeRoomId)?.name || 'Chat'}
                            </h3>
                        </div>

                        <div ref={scrollRef} className="flex-1 overflow-y-auto p-6 space-y-4">
                            {(messages[activeRoomId] || []).map((msg) => {
                                const isMe = msg.sender_id === user?.id;
                                return (
                                    <div key={msg.id} className={`flex ${isMe ? 'justify-end' : 'justify-start'}`}>
                                        <div className={`max-w-[70%] rounded-2xl p-3 shadow-sm ${isMe
                                            ? 'bg-primary-600 text-white rounded-tr-none'
                                            : 'bg-gray-100 text-gray-800 rounded-tl-none'
                                            }`}>
                                            {!isMe && <p className="text-[10px] font-bold mb-1 opacity-70">{msg.sender?.name}</p>}
                                            <p className="text-sm">{msg.content}</p>
                                            <p className={`text-[10px] mt-1 text-right ${isMe ? 'text-white/70' : 'text-gray-400'}`}>
                                                {format(new Date(msg.created_at), 'HH:mm')}
                                            </p>
                                        </div>
                                    </div>
                                );
                            })}
                        </div>

                        <form onSubmit={handleSend} className="p-4 border-t bg-gray-50 flex gap-2">
                            <input
                                type="text"
                                value={msgInput}
                                onChange={(e) => setMsgInput(e.target.value)}
                                placeholder={t('chat.placeholder', 'Type a message...')}
                                className="input flex-1"
                            />
                            <button type="submit" className="btn-primary p-3">
                                <FiSend />
                            </button>
                        </form>
                    </>
                ) : (
                    <EmptyState
                        title={t('chat.select_title', 'No chat selected')}
                        message={t('chat.select_msg', 'Choose a conversation from the sidebar to start chatting.')}
                    />
                )}
            </div>

            <Modal
                isOpen={showUserModal}
                onClose={() => setShowUserModal(false)}
                title={t('chat.start_new', 'Start New Conversation')}
            >
                <div className="space-y-4">
                    <div className="relative">
                        <FiSearch className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
                        <input
                            type="text"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            placeholder={t('chat.search_users', 'Search users by name or role...')}
                            className="input pl-10"
                        />
                    </div>
                    <div className="max-h-80 overflow-y-auto space-y-6">
                        {Object.keys(groupedUsers).length === 0 ? (
                            <p className="text-center text-gray-500 py-4 text-sm">{t('chat.no_users', 'No users found')}</p>
                        ) : (
                            ['petambak', 'logistik', 'konsumen'].map((role) => {
                                const usersInRole = groupedUsers[role] || [];
                                if (usersInRole.length === 0) return null;
                                return (
                                    <div key={role} className="space-y-2">
                                        <h4 className="text-xs font-bold text-gray-400 uppercase tracking-widest px-1">
                                            {t(`roles.${role}`, role)}
                                        </h4>
                                        <div className="grid grid-cols-1 gap-2">
                                            {usersInRole.map((u: any) => (
                                                <button
                                                    key={u.id}
                                                    onClick={() => handleCreatePrivateChat(u)}
                                                    className="w-full p-3 flex items-center gap-3 hover:bg-primary-50 hover:border-primary-200 rounded-xl transition-all text-left border border-gray-100 bg-white shadow-sm"
                                                >
                                                    <div className="w-10 h-10 rounded-full bg-gradient-to-br from-primary-100 to-accent-100 flex items-center justify-center text-primary-600">
                                                        <FiUser />
                                                    </div>
                                                    <div className="flex-1">
                                                        <p className="font-bold text-sm text-gray-900">{u.name}</p>
                                                        <p className="text-[10px] text-gray-500 truncate">{u.email}</p>
                                                    </div>
                                                </button>
                                            ))}
                                        </div>
                                    </div>
                                );
                            })
                        )}
                    </div>
                </div>
            </Modal>
        </div>
    );
}
