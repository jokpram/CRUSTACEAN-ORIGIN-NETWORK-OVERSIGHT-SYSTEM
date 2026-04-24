package com.cronos.controller;

import com.cronos.dto.response.ApiResponse;
import com.cronos.entity.ChatRoom;
import com.cronos.entity.User;
import com.cronos.repository.ChatMessageRepository;
import com.cronos.repository.ChatRoomRepository;
import com.cronos.repository.UserRepository;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatController {
    private final ChatRoomRepository chatRoomRepo;
    private final ChatMessageRepository chatMsgRepo;
    private final UserRepository userRepo;

    @GetMapping("/rooms")
    public ResponseEntity<?> getMyRooms(Authentication auth) {
        UUID userId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.success("Rooms retrieved", chatRoomRepo.findByMemberId(userId)));
    }

    @PostMapping("/rooms")
    public ResponseEntity<?> createRoom(Authentication auth, @RequestBody CreateRoomRequest req) {
        UUID userId = (UUID) auth.getPrincipal();
        if ("private".equals(req.type)) {
            var existing = chatRoomRepo.findPrivateRoomBetweenUsers(userId, req.targetUserId);
            if (existing.isPresent()) return ResponseEntity.ok(ApiResponse.success("Room already exists", existing.get()));
        }
        User me = userRepo.findById(userId).orElseThrow(() -> new RuntimeException("user not found"));
        User target = userRepo.findById(req.targetUserId).orElseThrow(() -> new RuntimeException("target user not found"));

        ChatRoom room = ChatRoom.builder()
                .type(req.type != null ? req.type : "private")
                .name(req.name != null ? req.name : target.getName())
                .members(List.of(me, target)).build();
        chatRoomRepo.save(room);
        return ResponseEntity.ok(ApiResponse.success("Room created", room));
    }

    @GetMapping("/rooms/{roomId}/messages")
    public ResponseEntity<?> getMessages(@PathVariable UUID roomId) {
        return ResponseEntity.ok(ApiResponse.success("Messages retrieved", chatMsgRepo.findTop50ByRoomIdOrderByCreatedAtAsc(roomId)));
    }

    @GetMapping("/users")
    public ResponseEntity<?> getChatUsers(Authentication auth) {
        UUID userId = (UUID) auth.getPrincipal();
        List<User> users = userRepo.findByRoleNot("admin");
        users.removeIf(u -> u.getId().equals(userId));
        return ResponseEntity.ok(ApiResponse.success("Users retrieved", users));
    }

    @Data
    static class CreateRoomRequest {
        private String type;
        private String name;
        @JsonProperty("target_user_id")
        private UUID targetUserId;
    }
}
