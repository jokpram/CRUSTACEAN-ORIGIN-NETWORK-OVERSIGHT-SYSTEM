package middleware
import (
	"cronos-backend/utils"
	"github.com/gin-gonic/gin"
)
func RoleMiddleware(roles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		userRole := GetUserRole(c)
		if userRole == "" {
			utils.Unauthorized(c, "User role not found")
			c.Abort()
			return
		}
		allowed := false
		for _, role := range roles {
			if userRole == role {
				allowed = true
				break
			}
		}
		if !allowed {
			utils.Forbidden(c, "You don't have permission to access this resource")
			c.Abort()
			return
		}
		c.Next()
	}
}
