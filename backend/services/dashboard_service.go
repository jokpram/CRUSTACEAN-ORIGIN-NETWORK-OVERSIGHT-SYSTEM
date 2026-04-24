package services
import (
	"cronos-backend/repositories"
	"github.com/google/uuid"
)
type DashboardService struct {
	UserRepo        *repositories.UserRepository
	OrderRepo       *repositories.OrderRepository
	FarmRepo        *repositories.FarmRepository
	ProductRepo     *repositories.ProductRepository
	CultivationRepo *repositories.CultivationRepository
	HarvestRepo     *repositories.HarvestRepository
	ShipmentRepo    *repositories.ShipmentRepository
}
func NewDashboardService(
	userRepo *repositories.UserRepository,
	orderRepo *repositories.OrderRepository,
	farmRepo *repositories.FarmRepository,
	productRepo *repositories.ProductRepository,
	cultivationRepo *repositories.CultivationRepository,
	harvestRepo *repositories.HarvestRepository,
	shipmentRepo *repositories.ShipmentRepository,
) *DashboardService {
	return &DashboardService{
		UserRepo:        userRepo,
		OrderRepo:       orderRepo,
		FarmRepo:        farmRepo,
		ProductRepo:     productRepo,
		CultivationRepo: cultivationRepo,
		HarvestRepo:     harvestRepo,
		ShipmentRepo:    shipmentRepo,
	}
}
func (s *DashboardService) GetAdminDashboard() (map[string]interface{}, error) {
	userCounts, _ := s.UserRepo.CountByRole()
	orderCounts, _ := s.OrderRepo.CountByStatus()
	totalRevenue, _ := s.OrderRepo.SumTotalRevenue()
	return map[string]interface{}{
		"users":         userCounts,
		"orders":        orderCounts,
		"total_revenue": totalRevenue,
	}, nil
}
func (s *DashboardService) GetPetambakDashboard(userID uuid.UUID) (map[string]interface{}, error) {
	farmCount, _ := s.FarmRepo.CountByUserID(userID)
	productCount, _ := s.ProductRepo.CountByUserID(userID)
	cultivationCount, _ := s.CultivationRepo.CountByUserID(userID)
	harvestCount, _ := s.HarvestRepo.CountHarvestsByUserID(userID)
	revenue, _ := s.OrderRepo.SumRevenueBySellerID(userID)
	return map[string]interface{}{
		"total_farms":        farmCount,
		"total_products":     productCount,
		"total_cultivations": cultivationCount,
		"total_harvests":     harvestCount,
		"total_revenue":      revenue,
	}, nil
}
func (s *DashboardService) GetLogistikDashboard(userID uuid.UUID) (map[string]interface{}, error) {
	shipmentCount, _ := s.ShipmentRepo.CountByCourierID(userID)
	statusCounts, _ := s.ShipmentRepo.CountByStatus(userID)
	return map[string]interface{}{
		"total_shipments": shipmentCount,
		"shipment_status": statusCounts,
	}, nil
}
func (s *DashboardService) GetKonsumenDashboard(userID uuid.UUID) (map[string]interface{}, error) {
	orders, total, _ := s.OrderRepo.FindByUserID(userID, 1, 5)
	orderStatusCounts := make(map[string]int)
	for _, o := range orders {
		orderStatusCounts[o.Status]++
	}
	return map[string]interface{}{
		"total_orders":  total,
		"recent_orders": orders,
		"order_status":  orderStatusCounts,
	}, nil
}
