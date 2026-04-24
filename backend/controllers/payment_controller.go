package controllers
import (
	"net/http"
	"cronos-backend/services"
	"cronos-backend/utils"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)
type PaymentController struct {
	PaymentService *services.PaymentService
}
func NewPaymentController(service *services.PaymentService) *PaymentController {
	return &PaymentController{PaymentService: service}
}
func (ctrl *PaymentController) CreatePayment(c *gin.Context) {
	var req struct {
		OrderID uuid.UUID `json:"order_id" validate:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	mt, err := ctrl.PaymentService.CreatePayment(req.OrderID)
	if err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusCreated, "Payment created", mt)
}
func (ctrl *PaymentController) MidtransWebhook(c *gin.Context) {
	var notification map[string]interface{}
	if err := c.ShouldBindJSON(&notification); err != nil {
		utils.BadRequest(c, "Invalid notification", err.Error())
		return
	}
	if err := ctrl.PaymentService.HandleWebhook(notification); err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}
func (ctrl *PaymentController) GetPayment(c *gin.Context) {
	orderID, err := uuid.Parse(c.Param("orderId"))
	if err != nil {
		utils.BadRequest(c, "Invalid order ID", nil)
		return
	}
	payment, err := ctrl.PaymentService.GetPaymentByOrderID(orderID)
	if err != nil {
		utils.NotFound(c, "Payment not found")
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Payment retrieved", payment)
}
