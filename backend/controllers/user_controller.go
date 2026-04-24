package controllers

import (
	"cronos-backend/models"
	"cronos-backend/services"
	"cronos-backend/utils"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type UserController struct {
	UserService *services.UserService
}

func NewUserController(userService *services.UserService) *UserController {
	return &UserController{UserService: userService}
}
func (ctrl *UserController) GetAllUsers(c *gin.Context) {
	page, limit := ctrl.UserService.ParsePagination(c.Query("page"), c.Query("limit"))
	role := c.Query("role")
	search := c.Query("search")
	users, meta, err := ctrl.UserService.GetAllUsers(page, limit, role, search)
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponseWithMeta(c, http.StatusOK, "Users retrieved", users, meta)
}
func (ctrl *UserController) CreateUser(c *gin.Context) {
	var req models.CreateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	if errs := utils.ValidateStruct(req); len(errs) > 0 {
		utils.BadRequest(c, "Validation failed", errs)
		return
	}
	user, err := ctrl.UserService.CreateUser(req)
	if err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusCreated, "User created successfully", user)
}
func (ctrl *UserController) VerifyUser(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid user ID", nil)
		return
	}
	user, err := ctrl.UserService.VerifyUser(id)
	if err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "User verified successfully", user)
}
func (ctrl *UserController) UpdateUserStatus(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid user ID", nil)
		return
	}
	var req struct {
		IsVerified bool `json:"is_verified"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	user, err := ctrl.UserService.UpdateUserStatus(id, req.IsVerified)
	if err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "User status updated", user)
}
