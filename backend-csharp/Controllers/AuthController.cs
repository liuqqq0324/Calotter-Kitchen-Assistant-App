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

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        // Validation
        if (string.IsNullOrWhiteSpace(request.Username) ||
            string.IsNullOrWhiteSpace(request.Email) ||
            string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest(new { message = "Username, email, and password are required" });
        }

        if (request.Password != request.ConfirmPassword)
        {
            return BadRequest(new { message = "Passwords do not match" });
        }

        // Check if username already exists
        if (await _context.Users.AnyAsync(u => u.Username == request.Username))
        {
            return Conflict(new { message = "Username already exists" });
        }

        // Check if email already exists
        if (await _context.Users.AnyAsync(u => u.Email == request.Email))
        {
            return Conflict(new { message = "Email already exists" });
        }

        // Create user
        var user = new User
        {
            Username = request.Username,
            Email = request.Email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        return Ok(new RegisterResponse
        {
            UserId = user.UserId,
            Message = "User registered successfully"
        });
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Identifier) ||
            string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest(new { message = "Identifier and password are required" });
        }

        // Find user by username or email
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Username == request.Identifier || u.Email == request.Identifier);

        if (user == null)
        {
            return Unauthorized(new { message = "Invalid credentials" });
        }

        // Verify password
        if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
        {
            return Unauthorized(new { message = "Invalid credentials" });
        }

        // Generate token
        var token = _jwtService.GenerateToken(user.UserId, user.Username);

        return Ok(new LoginResponse
        {
            UserId = user.UserId,
            Token = new TokenInfo
            {
                AccessToken = token,
                ExpiresIn = 3000
            }
        });
    }
}

