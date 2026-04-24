package controllers
import (
	"net/http"
	"cronos-backend/middleware"
	"cronos-backend/models"
	"cronos-backend/services"
	"cronos-backend/utils"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)
type CultivationController struct {
	CultivationService *services.CultivationService
}
func NewCultivationController(service *services.CultivationService) *CultivationController {
	return &CultivationController{CultivationService: service}
}
func (ctrl *CultivationController) CreateCycle(c *gin.Context) {
	userID := middleware.GetUserID(c)
	var cycle models.CultivationCycle
	if err := c.ShouldBindJSON(&cycle); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	if err := ctrl.CultivationService.CreateCycle(userID, &cycle); err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusCreated, "Cultivation cycle created", cycle)
}
func (ctrl *CultivationController) GetMyCycles(c *gin.Context) {
	userID := middleware.GetUserID(c)
	cycles, err := ctrl.CultivationService.GetMyCycles(userID)
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Cultivation cycles retrieved", cycles)
}
func (ctrl *CultivationController) GetCycle(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid ID", nil)
		return
	}
	cycle, err := ctrl.CultivationService.GetCycle(id)
	if err != nil {
		utils.NotFound(c, "Cycle not found")
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Cycle retrieved", cycle)
}
func (ctrl *CultivationController) UpdateCycle(c *gin.Context) {
	userID := middleware.GetUserID(c)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid ID", nil)
		return
	}
	var req models.CultivationCycle
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	cycle, err := ctrl.CultivationService.UpdateCycle(userID, id, &req)
	if err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Cycle updated", cycle)
}
func (ctrl *CultivationController) AddFeedLog(c *gin.Context) {
	userID := middleware.GetUserID(c)
	cycleID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid ID", nil)
		return
	}
	var log models.FeedLog
	if err := c.ShouldBindJSON(&log); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	log.CultivationCycleID = cycleID
	if err := ctrl.CultivationService.AddFeedLog(userID, &log); err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusCreated, "Feed log added", log)
}
func (ctrl *CultivationController) GetFeedLogs(c *gin.Context) {
	cycleID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid ID", nil)
		return
	}
	logs, err := ctrl.CultivationService.GetFeedLogs(cycleID)
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Feed logs retrieved", logs)
}
func (ctrl *CultivationController) AddWaterQualityLog(c *gin.Context) {
	userID := middleware.GetUserID(c)
	cycleID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid ID", nil)
		return
	}
	var log models.WaterQualityLog
	if err := c.ShouldBindJSON(&log); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	log.CultivationCycleID = cycleID
	if err := ctrl.CultivationService.AddWaterQualityLog(userID, &log); err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusCreated, "Water quality log added", log)
}
func (ctrl *CultivationController) GetWaterQualityLogs(c *gin.Context) {
	cycleID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid ID", nil)
		return
	}
	logs, err := ctrl.CultivationService.GetWaterQualityLogs(cycleID)
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Water quality logs retrieved", logs)
}
