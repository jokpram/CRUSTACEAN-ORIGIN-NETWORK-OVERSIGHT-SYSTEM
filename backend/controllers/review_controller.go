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
type ReviewController struct {
	ReviewService *services.ReviewService
}
func NewReviewController(service *services.ReviewService) *ReviewController {
	return &ReviewController{ReviewService: service}
}
func (ctrl *ReviewController) CreateReview(c *gin.Context) {
	userID := middleware.GetUserID(c)
	var review models.Review
	if err := c.ShouldBindJSON(&review); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	if err := ctrl.ReviewService.CreateReview(userID, &review); err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusCreated, "Review created", review)
}
func (ctrl *ReviewController) GetProductReviews(c *gin.Context) {
	productID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid product ID", nil)
		return
	}
	reviews, err := ctrl.ReviewService.GetProductReviews(productID)
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Reviews retrieved", reviews)
}
