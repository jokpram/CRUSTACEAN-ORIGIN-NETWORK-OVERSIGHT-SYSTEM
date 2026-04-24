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
type WithdrawalController struct {
	WithdrawalService *services.WithdrawalService
}
func NewWithdrawalController(service *services.WithdrawalService) *WithdrawalController {
	return &WithdrawalController{WithdrawalService: service}
}
func (ctrl *WithdrawalController) CreateWithdrawal(c *gin.Context) {
	userID := middleware.GetUserID(c)
	var req models.Withdrawal
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	if err := ctrl.WithdrawalService.CreateWithdrawal(userID, &req); err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusCreated, "Withdrawal request created", req)
}
func (ctrl *WithdrawalController) GetMyWithdrawals(c *gin.Context) {
	userID := middleware.GetUserID(c)
	withdrawals, err := ctrl.WithdrawalService.GetMyWithdrawals(userID)
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Withdrawals retrieved", withdrawals)
}
func (ctrl *WithdrawalController) GetAllWithdrawals(c *gin.Context) {
	withdrawals, err := ctrl.WithdrawalService.GetAllWithdrawals()
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "All withdrawals retrieved", withdrawals)
}
func (ctrl *WithdrawalController) UpdateWithdrawal(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid withdrawal ID", nil)
		return
	}
	var req struct {
		Status string `json:"status" validate:"required"`
		Notes  string `json:"notes"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	withdrawal, err := ctrl.WithdrawalService.UpdateWithdrawal(id, req.Status, req.Notes)
	if err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Withdrawal updated", withdrawal)
}
