package controllers
import (
	"net/http"
	"cronos-backend/middleware"
	"cronos-backend/models"
	"cronos-backend/services"
	"cronos-backend/utils"
	"github.com/gin-gonic/gin"
)
type HarvestController struct {
	HarvestService *services.HarvestService
}
func NewHarvestController(service *services.HarvestService) *HarvestController {
	return &HarvestController{HarvestService: service}
}
func (ctrl *HarvestController) CreateHarvest(c *gin.Context) {
	userID := middleware.GetUserID(c)
	var harvest models.Harvest
	if err := c.ShouldBindJSON(&harvest); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	if err := ctrl.HarvestService.CreateHarvest(userID, &harvest); err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusCreated, "Harvest created", harvest)
}
func (ctrl *HarvestController) GetMyHarvests(c *gin.Context) {
	userID := middleware.GetUserID(c)
	harvests, err := ctrl.HarvestService.GetMyHarvests(userID)
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Harvests retrieved", harvests)
}
func (ctrl *HarvestController) CreateBatch(c *gin.Context) {
	userID := middleware.GetUserID(c)
	var batch models.Batch
	if err := c.ShouldBindJSON(&batch); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	if err := ctrl.HarvestService.CreateBatch(userID, &batch); err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusCreated, "Batch created", batch)
}
func (ctrl *HarvestController) GetMyBatches(c *gin.Context) {
	userID := middleware.GetUserID(c)
	batches, err := ctrl.HarvestService.GetMyBatches(userID)
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Batches retrieved", batches)
}
func (ctrl *HarvestController) GetBatchByCode(c *gin.Context) {
	code := c.Param("code")
	batch, err := ctrl.HarvestService.GetBatchByCode(code)
	if err != nil {
		utils.NotFound(c, "Batch not found")
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Batch retrieved", batch)
}
