package services
import (
	"errors"
	"fmt"
	"time"
	"cronos-backend/config"
	"cronos-backend/models"
	"cronos-backend/repositories"
	"github.com/google/uuid"
	"github.com/midtrans/midtrans-go"
	"github.com/midtrans/midtrans-go/snap"
)
type PaymentService struct {
	PaymentRepo *repositories.PaymentRepository
	OrderRepo   *repositories.OrderRepository
	UserRepo    *repositories.UserRepository
}
func NewPaymentService(paymentRepo *repositories.PaymentRepository, orderRepo *repositories.OrderRepository, userRepo *repositories.UserRepository) *PaymentService {
	return &PaymentService{
		PaymentRepo: paymentRepo,
		OrderRepo:   orderRepo,
		UserRepo:    userRepo,
	}
}
func (s *PaymentService) CreatePayment(orderID uuid.UUID) (*models.MidtransTransaction, error) {
	order, err := s.OrderRepo.FindByID(orderID)
	if err != nil {
		return nil, errors.New("order not found")
	}
	if order.Status != "pending" {
		return nil, errors.New("order is not in pending status")
	}
	existingPayment, _ := s.PaymentRepo.FindByOrderID(orderID)
	if existingPayment != nil && existingPayment.ID != uuid.Nil {
		if existingPayment.MidtransTransaction != nil {
			return existingPayment.MidtransTransaction, nil
		}
	}
	payment := &models.Payment{
		OrderID: orderID,
		Amount:  order.TotalAmount,
		Status:  "pending",
	}
	if err := s.PaymentRepo.Create(payment); err != nil {
		return nil, errors.New("failed to create payment")
	}
	var snapClient snap.Client
	if config.AppConfig.MidtransIsProduction {
		snapClient.New(config.AppConfig.MidtransServerKey, midtrans.Production)
	} else {
		snapClient.New(config.AppConfig.MidtransServerKey, midtrans.Sandbox)
	}
	midtransOrderID := fmt.Sprintf("CRONOS-%s", order.ID.String()[:8])
	user, _ := s.UserRepo.FindByID(order.UserID)
	snapReq := &snap.Request{
		TransactionDetails: midtrans.TransactionDetails{
			OrderID:  midtransOrderID,
			GrossAmt: int64(order.TotalAmount),
		},
		CustomerDetail: &midtrans.CustomerDetails{
			FName: user.Name,
			Email: user.Email,
			Phone: user.Phone,
		},
	}
	snapResp, snapErr := snapClient.CreateTransaction(snapReq)
	if snapErr != nil {
		return nil, fmt.Errorf("failed to create snap token: %v", snapErr)
	}
	mt := &models.MidtransTransaction{
		PaymentID:       payment.ID,
		OrderIDMidtrans: midtransOrderID,
		SnapToken:       snapResp.Token,
		SnapURL:         snapResp.RedirectURL,
	}
	if err := s.PaymentRepo.CreateMidtransTransaction(mt); err != nil {
		return nil, errors.New("failed to save midtrans transaction")
	}
	return mt, nil
}
func (s *PaymentService) HandleWebhook(notification map[string]interface{}) error {
	orderIDMidtrans, ok := notification["order_id"].(string)
	if !ok {
		return errors.New("invalid order_id in notification")
	}
	transactionStatus, _ := notification["transaction_status"].(string)
	paymentType, _ := notification["payment_type"].(string)
	fraudStatus, _ := notification["fraud_status"].(string)
	mt, err := s.PaymentRepo.FindMidtransByOrderID(orderIDMidtrans)
	if err != nil {
		return errors.New("midtrans transaction not found")
	}
	mt.TransactionStatus = transactionStatus
	mt.PaymentType = paymentType
	mt.FraudStatus = fraudStatus
	payment, err := s.PaymentRepo.FindByID(mt.PaymentID)
	if err != nil {
		return errors.New("payment not found")
	}
	if payment.Status == "paid" && (transactionStatus == "capture" || transactionStatus == "settlement") {
		s.PaymentRepo.UpdateMidtransTransaction(mt)
		return nil
	}
	switch transactionStatus {
	case "capture":
		if fraudStatus == "accept" {
			payment.Status = "paid"
			now := time.Now()
			payment.PaidAt = &now
			payment.Method = paymentType
			order, _ := s.OrderRepo.FindByID(payment.OrderID)
			order.Status = "paid"
			s.OrderRepo.Update(order)
			s.creditSellerBalance(order)
		}
	case "settlement":
		payment.Status = "paid"
		now := time.Now()
		payment.PaidAt = &now
		payment.Method = paymentType
		order, _ := s.OrderRepo.FindByID(payment.OrderID)
		order.Status = "paid"
		s.OrderRepo.Update(order)
		s.creditSellerBalance(order)
	case "deny", "cancel", "expire":
		payment.Status = "failed"
		if transactionStatus == "expire" {
			payment.Status = "expired"
		}
		order, _ := s.OrderRepo.FindByID(payment.OrderID)
		order.Status = "cancelled"
		s.OrderRepo.Update(order)
	case "pending":
		payment.Status = "pending"
	}
	s.PaymentRepo.Update(payment)
	s.PaymentRepo.UpdateMidtransTransaction(mt)
	return nil
}
func (s *PaymentService) creditSellerBalance(order *models.Order) {
	sellerAmounts := make(map[uuid.UUID]float64)
	for _, item := range order.OrderItems {
		var p models.Product
		s.PaymentRepo.DB.First(&p, item.ProductID)
		if p.ID != uuid.Nil {
			sellerAmounts[p.UserID] += item.Subtotal
		}
	}
	for sellerID, amount := range sellerAmounts {
		seller, _ := s.UserRepo.FindByID(sellerID)
		if seller != nil {
			seller.Balance += amount
			s.UserRepo.Update(seller)
		}
	}
}
func (s *PaymentService) GetPaymentByOrderID(orderID uuid.UUID) (*models.Payment, error) {
	return s.PaymentRepo.FindByOrderID(orderID)
}
