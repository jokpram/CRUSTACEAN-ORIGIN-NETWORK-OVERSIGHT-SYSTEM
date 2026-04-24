package com.cronos.websocket;

import com.cronos.entity.ChatMessage;
import com.cronos.repository.ChatMessageRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;
import org.springframework.web.socket.handler.TextWebSocketHandler;
import org.springframework.web.util.UriComponentsBuilder;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

@Component
@RequiredArgsConstructor
@Slf4j
public class ChatWebSocketHandler extends TextWebSocketHandler {

    private final ChatMessageRepository chatMessageRepo;
    private final ObjectMapper objectMapper;

    private final Map<String, WebSocketSession> clients = new ConcurrentHashMap<>();
    private final Map<String, List<String>> clientRooms = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        String userId = getQueryParam(session, "user_id");
        if (userId != null) {
            clients.put(userId, session);
            clientRooms.put(userId, new CopyOnWriteArrayList<>());
            log.info("WebSocket connected: {}", userId);
        }
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        String userId = getQueryParam(session, "user_id");
        if (userId == null) return;

        JsonNode node = objectMapper.readTree(message.getPayload());
        String type = node.has("type") ? node.get("type").asText() : "";
        String roomId = node.has("room_id") ? node.get("room_id").asText() : "";

        switch (type) {
            case "join":
                List<String> rooms = clientRooms.get(userId);
                if (rooms != null && !rooms.contains(roomId)) {
                    rooms.add(roomId);
                }
                break;
            case "message":
                String content = node.has("content") ? node.get("content").asText() : "";
                ChatMessage msg = ChatMessage.builder()
                        .roomId(UUID.fromString(roomId))
                        .senderId(UUID.fromString(userId))
                        .content(content)
                        .createdAt(LocalDateTime.now())
                        .build();
                chatMessageRepo.save(msg);
                broadcastToRoom(roomId, objectMapper.writeValueAsString(msg));
                break;
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        String userId = getQueryParam(session, "user_id");
        if (userId != null) {
            clients.remove(userId);
            clientRooms.remove(userId);
            log.info("WebSocket disconnected: {}", userId);
        }
    }

    private void broadcastToRoom(String roomId, String message) {
        clientRooms.forEach((uid, rooms) -> {
            if (rooms.contains(roomId)) {
                WebSocketSession s = clients.get(uid);
                if (s != null && s.isOpen()) {
                    try {
                        s.sendMessage(new TextMessage(message));
                    } catch (Exception e) {
                        log.error("Failed to send WS message: {}", e.getMessage());
                    }
                }
            }
        });
    }

    private String getQueryParam(WebSocketSession session, String param) {
        if (session.getUri() == null) return null;
        Map<String, String> params = UriComponentsBuilder.fromUri(session.getUri()).build().getQueryParams().toSingleValueMap();
        return params.get(param);
    }
}
