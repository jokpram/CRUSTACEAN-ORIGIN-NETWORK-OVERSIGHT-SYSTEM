package middleware
import (
	"net/http"
	"sync"
	"time"
	"github.com/gin-gonic/gin"
)
type rateLimiter struct {
	visitors map[string]*visitor
	mu       sync.RWMutex
	rate     int
	burst    int
	window   time.Duration
}
type visitor struct {
	tokens    int
	lastVisit time.Time
}
func newRateLimiter(rate, burst int, window time.Duration) *rateLimiter {
	rl := &rateLimiter{
		visitors: make(map[string]*visitor),
		rate:     rate,
		burst:    burst,
		window:   window,
	}
	go rl.cleanup()
	return rl
}
func (rl *rateLimiter) cleanup() {
	for {
		time.Sleep(time.Minute)
		rl.mu.Lock()
		for ip, v := range rl.visitors {
			if time.Since(v.lastVisit) > rl.window {
				delete(rl.visitors, ip)
			}
		}
		rl.mu.Unlock()
	}
}
func (rl *rateLimiter) allow(ip string) bool {
	rl.mu.Lock()
	defer rl.mu.Unlock()
	v, exists := rl.visitors[ip]
	if !exists {
		rl.visitors[ip] = &visitor{
			tokens:    rl.burst - 1,
			lastVisit: time.Now(),
		}
		return true
	}
	elapsed := time.Since(v.lastVisit)
	v.lastVisit = time.Now()
	tokensToAdd := int(elapsed.Seconds()) * rl.rate
	v.tokens += tokensToAdd
	if v.tokens > rl.burst {
		v.tokens = rl.burst
	}
	if v.tokens <= 0 {
		return false
	}
	v.tokens--
	return true
}
func RateLimitMiddleware() gin.HandlerFunc {
	limiter := newRateLimiter(10, 100, 5*time.Minute)
	return func(c *gin.Context) {
		ip := c.ClientIP()
		if !limiter.allow(ip) {
			c.JSON(http.StatusTooManyRequests, gin.H{
				"success": false,
				"message": "Too many requests, please try again later",
			})
			c.Abort()
			return
		}
		c.Next()
	}
}
