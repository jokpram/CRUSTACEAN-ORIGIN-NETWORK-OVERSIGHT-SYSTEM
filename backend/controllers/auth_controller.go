package controllers
import (
	"net/http"
	"cronos-backend/middleware"
	"cronos-backend/models"
	"cronos-backend/services"
	"cronos-backend/utils"
	"github.com/gin-gonic/gin"
)
type AuthController struct {
	AuthService *services.AuthService
}
func NewAuthController(authService *services.AuthService) *AuthController {
	return &AuthController{AuthService: authService}
}
func (ctrl *AuthController) Register(c *gin.Context) {
	var req models.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	if errs := utils.ValidateStruct(req); len(errs) > 0 {
		utils.BadRequest(c, "Validation failed", errs)
		return
	}
	user, token, err := ctrl.AuthService.Register(req)
	if err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusCreated, "Registration successful", gin.H{
		"user":  user,
		"token": token,
	})
}
func (ctrl *AuthController) Login(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	if errs := utils.ValidateStruct(req); len(errs) > 0 {
		utils.BadRequest(c, "Validation failed", errs)
		return
	}
	user, token, err := ctrl.AuthService.Login(req)
	if err != nil {
		utils.Unauthorized(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Login successful", gin.H{
		"user":  user,
		"token": token,
	})
}
func (ctrl *AuthController) GetProfile(c *gin.Context) {
	userID := middleware.GetUserID(c)
	user, err := ctrl.AuthService.GetProfile(userID)
	if err != nil {
		utils.NotFound(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Profile retrieved", user)
}
func (ctrl *AuthController) UpdateProfile(c *gin.Context) {
	userID := middleware.GetUserID(c)
	var req models.UpdateProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	user, err := ctrl.AuthService.UpdateProfile(userID, req)
	if err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Profile updated", user)
}
