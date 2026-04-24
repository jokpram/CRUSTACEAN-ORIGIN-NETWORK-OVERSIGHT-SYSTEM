package controllers
import (
	"net/http"
	"cronos-backend/blockchain"
	"cronos-backend/models"
	"cronos-backend/utils"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)
type TraceabilityController struct {
	Ledger *blockchain.Ledger
	DB     *gorm.DB
}
func NewTraceabilityController(ledger *blockchain.Ledger, db *gorm.DB) *TraceabilityController {
	return &TraceabilityController{Ledger: ledger, DB: db}
}
func (ctrl *TraceabilityController) GetTraceByBatchCode(c *gin.Context) {
	batchCode := c.Param("batchCode")
	logs, err := ctrl.Ledger.GetTraceByBatchCode(batchCode)
	if err != nil {
		utils.NotFound(c, err.Error())
		return
	}
	var batch models.Batch
	ctrl.DB.Where("batch_code = ?", batchCode).
		Preload("Harvest").Preload("Harvest.CultivationCycle").
		Preload("Harvest.CultivationCycle.Pond").Preload("Harvest.CultivationCycle.Pond.Farm").
		Preload("Harvest.CultivationCycle.Pond.Farm.User").
		Preload("Harvest.CultivationCycle.ShrimpType").
		First(&batch)
	utils.SuccessResponse(c, http.StatusOK, "Traceability data retrieved", gin.H{
		"batch": batch,
		"logs":  logs,
	})
}
func (ctrl *TraceabilityController) GetAllLogs(c *gin.Context) {
	var logs []models.TraceabilityLog
	ctrl.DB.Preload("Actor").Order("timestamp DESC").Limit(100).Find(&logs)
	utils.SuccessResponse(c, http.StatusOK, "Traceability logs retrieved", logs)
}
func (ctrl *TraceabilityController) VerifyChain(c *gin.Context) {
	valid, err := ctrl.Ledger.VerifyChain()
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Chain verification complete", gin.H{
		"valid": valid,
	})
}
