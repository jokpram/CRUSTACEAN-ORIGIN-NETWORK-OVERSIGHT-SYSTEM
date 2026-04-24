package controllers
import (
	"net/http"
	"cronos-backend/models"
	"cronos-backend/services"
	"cronos-backend/utils"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)
type ShrimpTypeController struct {
	ShrimpTypeService *services.ShrimpTypeService
}
func NewShrimpTypeController(service *services.ShrimpTypeService) *ShrimpTypeController {
	return &ShrimpTypeController{ShrimpTypeService: service}
}
func (ctrl *ShrimpTypeController) Create(c *gin.Context) {
	var st models.ShrimpType
	if err := c.ShouldBindJSON(&st); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	if err := ctrl.ShrimpTypeService.Create(&st); err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusCreated, "Shrimp type created", st)
}
func (ctrl *ShrimpTypeController) GetAll(c *gin.Context) {
	types, err := ctrl.ShrimpTypeService.GetAll()
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Shrimp types retrieved", types)
}
func (ctrl *ShrimpTypeController) Update(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid ID", nil)
		return
	}
	var req models.ShrimpType
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	st, err := ctrl.ShrimpTypeService.Update(id, &req)
	if err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Shrimp type updated", st)
}
func (ctrl *ShrimpTypeController) Delete(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid ID", nil)
		return
	}
	if err := ctrl.ShrimpTypeService.Delete(id); err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Shrimp type deleted", nil)
}
