package blockchain
import (
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"time"
	"cronos-backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type Ledger struct {
	DB *gorm.DB
}
func NewLedger(db *gorm.DB) *Ledger {
	return &Ledger{DB: db}
}
func (l *Ledger) RecordEvent(eventType string, actorID uuid.UUID, entityType string, entityID uuid.UUID, dataPayload interface{}) error {
	payloadBytes, err := json.Marshal(dataPayload)
	if err != nil {
		return fmt.Errorf("failed to marshal data payload: %w", err)
	}
	previousHash := l.getLastHash()
	timestamp := time.Now()
	currentHash := l.calculateHash(previousHash, string(payloadBytes), eventType, timestamp)
	log := models.TraceabilityLog{
		ID:           uuid.New(),
		PreviousHash: previousHash,
		CurrentHash:  currentHash,
		Timestamp:    timestamp,
		EventType:    eventType,
		ActorID:      actorID,
		EntityType:   entityType,
		EntityID:     entityID,
		DataPayload:  string(payloadBytes),
	}
	if err := l.DB.Create(&log).Error; err != nil {
		return fmt.Errorf("failed to record blockchain event: %w", err)
	}
	return nil
}
func (l *Ledger) getLastHash() string {
	var lastLog models.TraceabilityLog
	result := l.DB.Order("created_at DESC").First(&lastLog)
	if result.Error != nil {
		return "0000000000000000000000000000000000000000000000000000000000000000"
	}
	return lastLog.CurrentHash
}
func (l *Ledger) calculateHash(previousHash, dataPayload, eventType string, timestamp time.Time) string {
	data := previousHash + dataPayload + eventType + timestamp.String()
	hash := sha256.Sum256([]byte(data))
	return fmt.Sprintf("%x", hash)
}
func (l *Ledger) GetTraceByEntity(entityType string, entityID uuid.UUID) ([]models.TraceabilityLog, error) {
	var logs []models.TraceabilityLog
	err := l.DB.Where("entity_type = ? AND entity_id = ?", entityType, entityID).
		Order("timestamp ASC").
		Preload("Actor").
		Find(&logs).Error
	return logs, err
}
func (l *Ledger) GetTraceByBatchCode(batchCode string) ([]models.TraceabilityLog, error) {
	var batch models.Batch
	if err := l.DB.Where("batch_code = ?", batchCode).First(&batch).Error; err != nil {
		return nil, fmt.Errorf("batch not found: %w", err)
	}
	var logs []models.TraceabilityLog
	var batchLogs []models.TraceabilityLog
	l.DB.Where("entity_type = ? AND entity_id = ?", "batch", batch.ID).Find(&batchLogs)
	logs = append(logs, batchLogs...)
	var harvest models.Harvest
	if l.DB.First(&harvest, batch.HarvestID).Error == nil {
		var harvestLogs []models.TraceabilityLog
		l.DB.Where("entity_type = ? AND entity_id = ?", "harvest", harvest.ID).Find(&harvestLogs)
		logs = append(logs, harvestLogs...)
		var cultivationLogs []models.TraceabilityLog
		l.DB.Where("entity_type = ? AND entity_id = ?", "cultivation", harvest.CultivationCycleID).Find(&cultivationLogs)
		logs = append(logs, cultivationLogs...)
		var cycle models.CultivationCycle
		if l.DB.First(&cycle, harvest.CultivationCycleID).Error == nil {
			var pond models.Pond
			if l.DB.First(&pond, cycle.PondID).Error == nil {
				var farmLogs []models.TraceabilityLog
				l.DB.Where("entity_type = ? AND entity_id = ?", "farm", pond.FarmID).Find(&farmLogs)
				logs = append(logs, farmLogs...)
			}
		}
	}
	var products []models.Product
	l.DB.Where("batch_id = ?", batch.ID).Find(&products)
	for _, product := range products {
		var productLogs []models.TraceabilityLog
		l.DB.Where("entity_type = ? AND entity_id = ?", "product", product.ID).Find(&productLogs)
		logs = append(logs, productLogs...)
		var orderItems []models.OrderItem
		l.DB.Where("product_id = ?", product.ID).Find(&orderItems)
		for _, item := range orderItems {
			var orderLogs []models.TraceabilityLog
			l.DB.Where("entity_type = ? AND entity_id = ?", "order", item.OrderID).Find(&orderLogs)
			logs = append(logs, orderLogs...)
			var shipmentLogs []models.TraceabilityLog
			l.DB.Where("entity_type = ? AND entity_id = ?", "shipment", item.OrderID).Find(&shipmentLogs)
			logs = append(logs, shipmentLogs...)
		}
	}
	sortLogsByTimestamp(logs)
	for i := range logs {
		l.DB.First(&logs[i].Actor, logs[i].ActorID)
	}
	return logs, nil
}
func sortLogsByTimestamp(logs []models.TraceabilityLog) {
	for i := 0; i < len(logs); i++ {
		for j := i + 1; j < len(logs); j++ {
			if logs[i].Timestamp.After(logs[j].Timestamp) {
				logs[i], logs[j] = logs[j], logs[i]
			}
		}
	}
}
func (l *Ledger) VerifyChain() (bool, error) {
	var logs []models.TraceabilityLog
	if err := l.DB.Order("created_at ASC").Find(&logs).Error; err != nil {
		return false, err
	}
	for i := 1; i < len(logs); i++ {
		if logs[i].PreviousHash != logs[i-1].CurrentHash {
			return false, fmt.Errorf("chain broken at log %s", logs[i].ID)
		}
	}
	return true, nil
}
