package routes

import (
	"cronos-backend/blockchain"
	"cronos-backend/controllers"
	"cronos-backend/middleware"
	"cronos-backend/repositories"
	"cronos-backend/services"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupRoutes(r *gin.Engine, db *gorm.DB) {
	ledger := blockchain.NewLedger(db)
	userRepo := repositories.NewUserRepository(db)
	farmRepo := repositories.NewFarmRepository(db)
	cultivationRepo := repositories.NewCultivationRepository(db)
	harvestRepo := repositories.NewHarvestRepository(db)
	productRepo := repositories.NewProductRepository(db)
	orderRepo := repositories.NewOrderRepository(db)
	paymentRepo := repositories.NewPaymentRepository(db)
	shipmentRepo := repositories.NewShipmentRepository(db)
	withdrawalRepo := repositories.NewWithdrawalRepository(db)
	reviewRepo := repositories.NewReviewRepository(db)
	shrimpTypeRepo := repositories.NewShrimpTypeRepository(db)
	authService := services.NewAuthService(userRepo)
	userService := services.NewUserService(userRepo)
	farmService := services.NewFarmService(farmRepo, ledger)
	cultivationService := services.NewCultivationService(cultivationRepo, farmRepo, ledger)
	harvestService := services.NewHarvestService(harvestRepo, ledger)
	productService := services.NewProductService(productRepo, ledger)
	orderService := services.NewOrderService(orderRepo, productRepo, ledger)
	paymentService := services.NewPaymentService(paymentRepo, orderRepo, userRepo)
	shipmentService := services.NewShipmentService(shipmentRepo, orderRepo, ledger)
	withdrawalService := services.NewWithdrawalService(withdrawalRepo, userRepo)
	reviewService := services.NewReviewService(reviewRepo, productRepo)
	shrimpTypeService := services.NewShrimpTypeService(shrimpTypeRepo)
	dashboardService := services.NewDashboardService(userRepo, orderRepo, farmRepo, productRepo, cultivationRepo, harvestRepo, shipmentRepo)
	authCtrl := controllers.NewAuthController(authService)
	userCtrl := controllers.NewUserController(userService)
	farmCtrl := controllers.NewFarmController(farmService)
	cultivationCtrl := controllers.NewCultivationController(cultivationService)
	harvestCtrl := controllers.NewHarvestController(harvestService)
	productCtrl := controllers.NewProductController(productService)
	orderCtrl := controllers.NewOrderController(orderService)
	paymentCtrl := controllers.NewPaymentController(paymentService)
	shipmentCtrl := controllers.NewShipmentController(shipmentService)
	withdrawalCtrl := controllers.NewWithdrawalController(withdrawalService)
	reviewCtrl := controllers.NewReviewController(reviewService)
	shrimpTypeCtrl := controllers.NewShrimpTypeController(shrimpTypeService)
	dashboardCtrl := controllers.NewDashboardController(dashboardService)
	traceabilityCtrl := controllers.NewTraceabilityController(ledger, db)
	api := r.Group("/api")
	{
		api.POST("/auth/register", authCtrl.Register)
		api.POST("/auth/login", authCtrl.Login)
		api.GET("/products", productCtrl.GetMarketplaceProducts)
		api.GET("/products/:id", productCtrl.GetProduct)
		api.GET("/products/:id/reviews", reviewCtrl.GetProductReviews)
		api.GET("/shrimp-types", shrimpTypeCtrl.GetAll)
		api.GET("/traceability/:batchCode", traceabilityCtrl.GetTraceByBatchCode)
		api.POST("/payments/midtrans/webhook", paymentCtrl.MidtransWebhook)

		// Chat WebSocket
		api.GET("/chat/ws", controllers.HandleWebSocket)

		auth := api.Group("")
		auth.Use(middleware.AuthMiddleware())
		{
			auth.GET("/auth/profile", authCtrl.GetProfile)
			auth.PUT("/auth/profile", authCtrl.UpdateProfile)

			// Chat Routes
			auth.GET("/chat/rooms/:user_id", controllers.GetRooms)
			auth.GET("/chat/messages/:room_id", controllers.GetMessages)
			auth.POST("/chat/rooms", controllers.CreateRoom)
			auth.GET("/chat/users", controllers.GetChatUsers)
			admin := auth.Group("/admin")
			admin.Use(middleware.RoleMiddleware("admin"))
			{
				admin.GET("/users", userCtrl.GetAllUsers)
				admin.POST("/users", userCtrl.CreateUser)
				admin.PUT("/users/:id/verify", userCtrl.VerifyUser)
				admin.PUT("/users/:id/status", userCtrl.UpdateUserStatus)
				admin.GET("/dashboard", dashboardCtrl.GetAdminDashboard)
				admin.GET("/withdrawals", withdrawalCtrl.GetAllWithdrawals)
				admin.PUT("/withdrawals/:id", withdrawalCtrl.UpdateWithdrawal)
				admin.GET("/orders", orderCtrl.GetAllOrders)
				admin.GET("/traceability/logs", traceabilityCtrl.GetAllLogs)
				admin.GET("/traceability/verify", traceabilityCtrl.VerifyChain)
				admin.POST("/shrimp-types", shrimpTypeCtrl.Create)
				admin.PUT("/shrimp-types/:id", shrimpTypeCtrl.Update)
				admin.DELETE("/shrimp-types/:id", shrimpTypeCtrl.Delete)
				admin.POST("/shipments", shipmentCtrl.CreateShipment)
				admin.GET("/shipments", shipmentCtrl.GetAllShipments)
			}
			petambak := auth.Group("")
			petambak.Use(middleware.RoleMiddleware("petambak"))
			{
				petambak.GET("/dashboard/petambak", dashboardCtrl.GetPetambakDashboard)
				petambak.POST("/farms", farmCtrl.CreateFarm)
				petambak.GET("/farms", farmCtrl.GetMyFarms)
				petambak.GET("/farms/:id", farmCtrl.GetFarm)
				petambak.PUT("/farms/:id", farmCtrl.UpdateFarm)
				petambak.DELETE("/farms/:id", farmCtrl.DeleteFarm)
				petambak.POST("/farms/:id/ponds", farmCtrl.CreatePond)
				petambak.GET("/farms/:id/ponds", farmCtrl.GetPonds)
				petambak.PUT("/ponds/:id", farmCtrl.UpdatePond)
				petambak.DELETE("/ponds/:id", farmCtrl.DeletePond)
				petambak.POST("/cultivations", cultivationCtrl.CreateCycle)
				petambak.GET("/cultivations", cultivationCtrl.GetMyCycles)
				petambak.GET("/cultivations/:id", cultivationCtrl.GetCycle)
				petambak.PUT("/cultivations/:id", cultivationCtrl.UpdateCycle)
				petambak.POST("/cultivations/:id/feed-logs", cultivationCtrl.AddFeedLog)
				petambak.GET("/cultivations/:id/feed-logs", cultivationCtrl.GetFeedLogs)
				petambak.POST("/cultivations/:id/water-quality", cultivationCtrl.AddWaterQualityLog)
				petambak.GET("/cultivations/:id/water-quality", cultivationCtrl.GetWaterQualityLogs)
				petambak.POST("/harvests", harvestCtrl.CreateHarvest)
				petambak.GET("/harvests", harvestCtrl.GetMyHarvests)
				petambak.POST("/batches", harvestCtrl.CreateBatch)
				petambak.GET("/batches", harvestCtrl.GetMyBatches)
				petambak.GET("/batches/:code", harvestCtrl.GetBatchByCode)
				petambak.POST("/products", productCtrl.CreateProduct)
				petambak.GET("/products/my", productCtrl.GetMyProducts)
				petambak.PUT("/products/:id", productCtrl.UpdateProduct)
				petambak.DELETE("/products/:id", productCtrl.DeleteProduct)
				petambak.GET("/sales", orderCtrl.GetSellerOrders)
				petambak.POST("/withdrawals", withdrawalCtrl.CreateWithdrawal)
				petambak.GET("/withdrawals", withdrawalCtrl.GetMyWithdrawals)
			}
			logistik := auth.Group("")
			logistik.Use(middleware.RoleMiddleware("logistik"))
			{
				logistik.GET("/dashboard/logistik", dashboardCtrl.GetLogistikDashboard)
				logistik.GET("/shipments", shipmentCtrl.GetMyShipments)
				logistik.PUT("/shipments/:id/status", shipmentCtrl.UpdateShipmentStatus)
				logistik.GET("/shipments/:id/logs", shipmentCtrl.GetShipmentLogs)
			}
			konsumen := auth.Group("")
			konsumen.Use(middleware.RoleMiddleware("konsumen"))
			{
				konsumen.GET("/dashboard/konsumen", dashboardCtrl.GetKonsumenDashboard)
				konsumen.POST("/orders", orderCtrl.CreateOrder)
				konsumen.GET("/orders", orderCtrl.GetMyOrders)
				konsumen.GET("/orders/:id", orderCtrl.GetOrder)
				konsumen.PUT("/orders/:id/cancel", orderCtrl.CancelOrder)
				konsumen.POST("/payments/create", paymentCtrl.CreatePayment)
				konsumen.GET("/payments/:orderId", paymentCtrl.GetPayment)
				konsumen.POST("/reviews", reviewCtrl.CreateReview)
			}
		}
	}
}
