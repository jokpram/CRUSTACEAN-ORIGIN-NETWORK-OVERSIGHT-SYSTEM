package com.cronos.repository;

import com.cronos.entity.ChatRoom;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ChatRoomRepository extends JpaRepository<ChatRoom, UUID> {
    @Query("SELECT cr FROM ChatRoom cr JOIN cr.members m WHERE m.id = :userId")
    List<ChatRoom> findByMemberId(@Param("userId") UUID userId);

    @Query("SELECT cr FROM ChatRoom cr JOIN cr.members m1 JOIN cr.members m2 WHERE cr.type = 'private' AND m1.id = :userId1 AND m2.id = :userId2")
    Optional<ChatRoom> findPrivateRoomBetweenUsers(@Param("userId1") UUID userId1, @Param("userId2") UUID userId2);
}
