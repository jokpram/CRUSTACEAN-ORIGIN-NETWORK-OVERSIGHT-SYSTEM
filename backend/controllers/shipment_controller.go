package controllers
import (
	"net/http"
	"cronos-backend/middleware"
	"cronos-backend/services"
	"cronos-backend/utils"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)
type ShipmentController struct {
	ShipmentService *services.ShipmentService
}
func NewShipmentController(service *services.ShipmentService) *ShipmentController {
	return &ShipmentController{ShipmentService: service}
}
func (ctrl *ShipmentController) CreateShipment(c *gin.Context) {
	var req services.CreateShipmentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	shipment, err := ctrl.ShipmentService.CreateShipment(req)
	if err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusCreated, "Shipment created", shipment)
}
func (ctrl *ShipmentController) GetMyShipments(c *gin.Context) {
	courierID := middleware.GetUserID(c)
	shipments, err := ctrl.ShipmentService.GetMyShipments(courierID)
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Shipments retrieved", shipments)
}
func (ctrl *ShipmentController) GetAllShipments(c *gin.Context) {
	shipments, err := ctrl.ShipmentService.GetAllShipments()
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "All shipments retrieved", shipments)
}
func (ctrl *ShipmentController) UpdateShipmentStatus(c *gin.Context) {
	courierID := middleware.GetUserID(c)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid shipment ID", nil)
		return
	}
	var req struct {
		Status   string `json:"status" validate:"required"`
		Location string `json:"location"`
		Notes    string `json:"notes"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	shipment, err := ctrl.ShipmentService.UpdateShipmentStatus(courierID, id, req.Status, req.Location, req.Notes)
	if err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Shipment status updated", shipment)
}
func (ctrl *ShipmentController) GetShipmentLogs(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid shipment ID", nil)
		return
	}
	logs, err := ctrl.ShipmentService.GetShipmentLogs(id)
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Shipment logs retrieved", logs)
}
