using Microsoft.AspNetCore.Mvc;

namespace SousChefBackend.Controllers;

[ApiController] // 1. 标记这是一个 API 控制器
[Route("[controller]")] // 2. 路由规则：访问 /hello 就会进到这里
public class HelloController : ControllerBase
{
    // GET: /hello
    [HttpGet] 
    public IActionResult Get()
    {
        // 返回一个匿名对象，ASP.NET Core 会自动转成 JSON
        var response = new 
        { 
            Message = "Hello World from C# .NET 8!", 
            Status = "Success",
            Time = DateTime.Now 
        };

        return Ok(response); // 返回 HTTP 200 OK
    }
}