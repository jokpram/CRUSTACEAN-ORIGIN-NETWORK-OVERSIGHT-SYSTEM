package controllers
import (
	"net/http"
	"cronos-backend/middleware"
	"cronos-backend/services"
	"cronos-backend/utils"
	"github.com/gin-gonic/gin"
)
type DashboardController struct {
	DashboardService *services.DashboardService
}
func NewDashboardController(service *services.DashboardService) *DashboardController {
	return &DashboardController{DashboardService: service}
}
func (ctrl *DashboardController) GetAdminDashboard(c *gin.Context) {
	data, err := ctrl.DashboardService.GetAdminDashboard()
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Admin dashboard", data)
}
func (ctrl *DashboardController) GetPetambakDashboard(c *gin.Context) {
	userID := middleware.GetUserID(c)
	data, err := ctrl.DashboardService.GetPetambakDashboard(userID)
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Petambak dashboard", data)
}
func (ctrl *DashboardController) GetLogistikDashboard(c *gin.Context) {
	userID := middleware.GetUserID(c)
	data, err := ctrl.DashboardService.GetLogistikDashboard(userID)
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Logistik dashboard", data)
}
func (ctrl *DashboardController) GetKonsumenDashboard(c *gin.Context) {
	userID := middleware.GetUserID(c)
	data, err := ctrl.DashboardService.GetKonsumenDashboard(userID)
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Konsumen dashboard", data)
}
