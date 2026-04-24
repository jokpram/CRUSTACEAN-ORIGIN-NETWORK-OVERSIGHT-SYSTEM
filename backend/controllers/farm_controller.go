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
type FarmController struct {
	FarmService *services.FarmService
}
func NewFarmController(farmService *services.FarmService) *FarmController {
	return &FarmController{FarmService: farmService}
}
func (ctrl *FarmController) CreateFarm(c *gin.Context) {
	userID := middleware.GetUserID(c)
	var farm models.Farm
	if err := c.ShouldBindJSON(&farm); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	if err := ctrl.FarmService.CreateFarm(userID, &farm); err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusCreated, "Farm created successfully", farm)
}
func (ctrl *FarmController) GetMyFarms(c *gin.Context) {
	userID := middleware.GetUserID(c)
	farms, err := ctrl.FarmService.GetMyFarms(userID)
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Farms retrieved", farms)
}
func (ctrl *FarmController) GetFarm(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid farm ID", nil)
		return
	}
	farm, err := ctrl.FarmService.GetFarm(id)
	if err != nil {
		utils.NotFound(c, "Farm not found")
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Farm retrieved", farm)
}
func (ctrl *FarmController) UpdateFarm(c *gin.Context) {
	userID := middleware.GetUserID(c)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid farm ID", nil)
		return
	}
	var req models.Farm
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	farm, err := ctrl.FarmService.UpdateFarm(userID, id, &req)
	if err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Farm updated", farm)
}
func (ctrl *FarmController) DeleteFarm(c *gin.Context) {
	userID := middleware.GetUserID(c)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid farm ID", nil)
		return
	}
	if err := ctrl.FarmService.DeleteFarm(userID, id); err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Farm deleted", nil)
}
func (ctrl *FarmController) CreatePond(c *gin.Context) {
	userID := middleware.GetUserID(c)
	farmID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid farm ID", nil)
		return
	}
	var pond models.Pond
	if err := c.ShouldBindJSON(&pond); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	if err := ctrl.FarmService.CreatePond(userID, farmID, &pond); err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusCreated, "Pond created", pond)
}
func (ctrl *FarmController) GetPonds(c *gin.Context) {
	farmID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid farm ID", nil)
		return
	}
	ponds, err := ctrl.FarmService.GetPonds(farmID)
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Ponds retrieved", ponds)
}
func (ctrl *FarmController) UpdatePond(c *gin.Context) {
	userID := middleware.GetUserID(c)
	pondID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid pond ID", nil)
		return
	}
	var req models.Pond
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	pond, err := ctrl.FarmService.UpdatePond(userID, pondID, &req)
	if err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Pond updated", pond)
}
func (ctrl *FarmController) DeletePond(c *gin.Context) {
	userID := middleware.GetUserID(c)
	pondID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid pond ID", nil)
		return
	}
	if err := ctrl.FarmService.DeletePond(userID, pondID); err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Pond deleted", nil)
}
