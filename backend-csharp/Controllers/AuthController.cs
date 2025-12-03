using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SousChefBackend.Data;
using SousChefBackend.DTOs.Auth;
using SousChefBackend.Models;

namespace SousChefBackend.Controllers;

[ApiController] // 标记这是一个 API 控制器
[Route("api/[controller]")] // 路由地址: api/Auth
public class AuthController : ControllerBase
{
    private readonly AppDbContext _context;

    // 构造函数：注入数据库上下文
    public AuthController(AppDbContext context)
    {
        _context = context;
    }

    // POST: api/Auth/login
    [HttpPost("login")]
    public async Task<ActionResult<LoginResponse>> Login(LoginRequest request)
    {
        // 1. 去数据库查有没有这个名字的人
        var user = await _context.Users
            .Include(u => u.Kitchen) // 🔥 连表查询：顺便把他的厨房信息也查出来
            .FirstOrDefaultAsync(u => u.Username == request.Username);

        // 2. 检查用户是否存在
        if (user == null)
        {
            return Unauthorized("User not found."); // 401 错误
        }

        // 3. 检查密码 (这里暂时用明文比对，以后再加 Hash)
        if (user.Password != request.Password)
        {
            return Unauthorized("Wrong password."); // 401 错误
        }

        // 4. 检查有没有厨房 (如果没有，这是数据异常，我们临时创建一个)
        if (user.Kitchen == null)
        {
            // 容错处理：万一这个用户没厨房，现场给他造一个
            var newKitchen = new Kitchen { UserId = user.Id };
            _context.Kitchens.Add(newKitchen);
            await _context.SaveChangesAsync();
            user.Kitchen = newKitchen;
        }

        // 5. 登录成功！组装数据返回给前端
        var response = new LoginResponse
        {
            Id = user.Id,
            Username = user.Username,
            Email = user.Email,
            KitchenId = user.Kitchen.Id, // 把厨房 ID 给前端
            Token = "fake-jwt-token-for-dev" 
        };

        return Ok(response); // 200 OK
    }
}