using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SousChefBackend.Data;
using SousChefBackend.DTOs.Auth;
using SousChefBackend.Models;
using SousChefBackend.Services;
using BCrypt.Net;

namespace SousChefBackend.Controllers;

[ApiController]
[Route("api/ums/auth")]
public class AuthController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly JwtService _jwtService;

    public AuthController(ApplicationDbContext context, JwtService jwtService)
    {
        _context = context;
        _jwtService = jwtService;
    }

    // 注册
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
            return BadRequest(new { message = "Username and password required" });

        if (await _context.Users.AnyAsync(u => u.Username == request.Username))
            return Conflict(new { message = "Username exists" });

        var user = new User
        {
            Username = request.Username,
            Email = request.Email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
            
            // 🔥 注册即送厨房！
            Kitchen = new Kitchen() 
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        return Ok(new RegisterResponse { UserId = user.UserId, Message = "Registered successfully" });
    }

    // 登录
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        // 🔥 必须 Include Kitchen，否则 user.Kitchen 是 null
        var user = await _context.Users
            .Include(u => u.Kitchen) 
            .FirstOrDefaultAsync(u => u.Username == request.Identifier || u.Email == request.Identifier);

        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
        {
            return Unauthorized(new { message = "Invalid credentials" });
        }

        // 厨房自愈 (如果老数据没厨房，现场造一个)
        int kitchenId = 0;
        if (user.Kitchen == null)
        {
            var newKitchen = new Kitchen { UserId = user.UserId };
            _context.Kitchens.Add(newKitchen);
            await _context.SaveChangesAsync();
            kitchenId = newKitchen.Id;
        }
        else
        {
            kitchenId = user.Kitchen.Id;
        }

        // 生成 Token
        var token = _jwtService.GenerateToken(user.UserId, user.Username);

        return Ok(new LoginResponse
        {
            UserId = user.UserId,
            KitchenId = kitchenId, // 🔥 前端拿去查库存
            Token = new TokenInfo { AccessToken = token }
        });
    }
}