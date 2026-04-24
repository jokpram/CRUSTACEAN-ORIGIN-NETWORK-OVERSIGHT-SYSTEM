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
type ProductController struct {
	ProductService *services.ProductService
}
func NewProductController(service *services.ProductService) *ProductController {
	return &ProductController{ProductService: service}
}
func (ctrl *ProductController) CreateProduct(c *gin.Context) {
	userID := middleware.GetUserID(c)
	var product models.Product
	if err := c.ShouldBindJSON(&product); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	if err := ctrl.ProductService.CreateProduct(userID, &product); err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusCreated, "Product created", product)
}
func (ctrl *ProductController) GetMarketplaceProducts(c *gin.Context) {
	products, meta, err := ctrl.ProductService.GetMarketplaceProducts(
		c.Query("page"), c.Query("limit"),
		c.Query("shrimp_type"), c.Query("size"),
		c.Query("search"), c.Query("sort"),
		c.Query("min_price"), c.Query("max_price"),
	)
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponseWithMeta(c, http.StatusOK, "Products retrieved", products, meta)
}
func (ctrl *ProductController) GetProduct(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid product ID", nil)
		return
	}
	product, err := ctrl.ProductService.GetProduct(id)
	if err != nil {
		utils.NotFound(c, "Product not found")
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Product retrieved", product)
}
func (ctrl *ProductController) GetMyProducts(c *gin.Context) {
	userID := middleware.GetUserID(c)
	products, err := ctrl.ProductService.GetMyProducts(userID)
	if err != nil {
		utils.InternalServerError(c, err.Error())
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "My products retrieved", products)
}
func (ctrl *ProductController) UpdateProduct(c *gin.Context) {
	userID := middleware.GetUserID(c)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid product ID", nil)
		return
	}
	var req models.Product
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, "Invalid request body", err.Error())
		return
	}
	product, err := ctrl.ProductService.UpdateProduct(userID, id, &req)
	if err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Product updated", product)
}
func (ctrl *ProductController) DeleteProduct(c *gin.Context) {
	userID := middleware.GetUserID(c)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid product ID", nil)
		return
	}
	if err := ctrl.ProductService.DeleteProduct(userID, id); err != nil {
		utils.BadRequest(c, err.Error(), nil)
		return
	}
	utils.SuccessResponse(c, http.StatusOK, "Product deleted", nil)
}
