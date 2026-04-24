package controllers
import (
	"net/http"
	"cronos-backend/middleware"
	"cronos-backend/services"
	"cronos-backend/utils"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)
type OrderController struct {
	OrderService *services.OrderService
}
func NewOrderController(service *services.OrderService) *OrderController {
	return &OrderController{OrderService: service}
}
func (ctrl *OrderController) CreateOrder(c *gin.Context) {
	userID := middleware.GetUserID(c)
	var req services.CreateOrderRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	order, err := ctrl.OrderService.CreateOrder(userID, req)
	if err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusCreated, "Order created", order)
}
func (ctrl *OrderController) GetMyOrders(c *gin.Context) {
	userID := middleware.GetUserID(c)
	orders, meta, err := ctrl.OrderService.GetMyOrders(userID, c.Query("page"), c.Query("limit"))
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponseWithMeta(c, http.StatusOK, "Orders retrieved", orders, meta)
}
func (ctrl *OrderController) GetAllOrders(c *gin.Context) {
	orders, meta, err := ctrl.OrderService.GetAllOrders(c.Query("page"), c.Query("limit"), c.Query("status"))
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponseWithMeta(c, http.StatusOK, "Orders retrieved", orders, meta)
}
func (ctrl *OrderController) GetOrder(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid order ID", nil)
		return
	}
	order, err := ctrl.OrderService.GetOrder(id)
	if err != nil {
		utils.NotFound(c, "Order not found")
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Order retrieved", order)
}
func (ctrl *OrderController) CancelOrder(c *gin.Context) {
	userID := middleware.GetUserID(c)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid order ID", nil)
		return
	}
	if err := ctrl.OrderService.CancelOrder(userID, id); err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Order cancelled", nil)
}
func (ctrl *OrderController) GetSellerOrders(c *gin.Context) {
	userID := middleware.GetUserID(c)
	orders, err := ctrl.OrderService.GetSellerOrders(userID)
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Seller orders retrieved", orders)
}
