package services
import (
	"errors"
	"math"
	"strconv"
	"cronos-backend/blockchain"
	"cronos-backend/models"
	"cronos-backend/repositories"
	"cronos-backend/utils"
	"github.com/google/uuid"
)
type ProductService struct {
	ProductRepo *repositories.ProductRepository
	Ledger      *blockchain.Ledger
}
func NewProductService(productRepo *repositories.ProductRepository, ledger *blockchain.Ledger) *ProductService {
	return &ProductService{ProductRepo: productRepo, Ledger: ledger}
}
func (s *ProductService) CreateProduct(userID uuid.UUID, product *models.Product) error {
	product.UserID = userID
	if err := s.ProductRepo.Create(product); err != nil {
		return errors.New("failed to create product")
	}
	s.Ledger.RecordEvent("product_listed", userID, "product", product.ID, map[string]interface{}{
		"name":  product.Name,
		"price": product.Price,
		"stock": product.Stock,
	})
	return nil
}
func (s *ProductService) GetMarketplaceProducts(pageStr, limitStr, shrimpType, size, search, sortBy, minPriceStr, maxPriceStr string) ([]models.Product, *utils.PaginationMeta, error) {
	page, _ := strconv.Atoi(pageStr)
	if page < 1 {
		page = 1
	}
	limit, _ := strconv.Atoi(limitStr)
	if limit < 1 {
		limit = 12
	}
	minPrice, _ := strconv.ParseFloat(minPriceStr, 64)
	maxPrice, _ := strconv.ParseFloat(maxPriceStr, 64)
	products, total, err := s.ProductRepo.FindAll(page, limit, shrimpType, size, search, sortBy, minPrice, maxPrice)
	if err != nil {
		return nil, nil, errors.New("failed to fetch products")
	}
	meta := &utils.PaginationMeta{
		CurrentPage: page,
		PerPage:     limit,
		Total:       total,
		TotalPages:  int(math.Ceil(float64(total) / float64(limit))),
	}
	return products, meta, nil
}
func (s *ProductService) GetProduct(id uuid.UUID) (*models.Product, error) {
	return s.ProductRepo.FindByID(id)
}
func (s *ProductService) GetMyProducts(userID uuid.UUID) ([]models.Product, error) {
	return s.ProductRepo.FindByUserID(userID)
}
func (s *ProductService) UpdateProduct(userID, productID uuid.UUID, req *models.Product) (*models.Product, error) {
	product, err := s.ProductRepo.FindByID(productID)
	if err != nil {
		return nil, errors.New("product not found")
	}
	if product.UserID != userID {
		return nil, errors.New("unauthorized")
	}
	if req.Name != "" {
		product.Name = req.Name
	}
	if req.Description != "" {
		product.Description = req.Description
	}
	if req.Price > 0 {
		product.Price = req.Price
	}
	if req.Stock >= 0 {
		product.Stock = req.Stock
	}
	if req.ShrimpType != "" {
		product.ShrimpType = req.ShrimpType
	}
	if req.Size != "" {
		product.Size = req.Size
	}
	product.IsAvailable = req.IsAvailable
	if err := s.ProductRepo.Update(product); err != nil {
		return nil, errors.New("failed to update product")
	}
	return product, nil
}
func (s *ProductService) DeleteProduct(userID, productID uuid.UUID) error {
	product, err := s.ProductRepo.FindByID(productID)
	if err != nil {
		return errors.New("product not found")
	}
	if product.UserID != userID {
		return errors.New("unauthorized")
	}
	return s.ProductRepo.Delete(productID)
}
