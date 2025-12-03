using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SousChefBackend.Data;
using SousChefBackend.Models;

namespace SousChefBackend.Controllers;

[ApiController]
[Route("api/[controller]")] // 路由前缀: api/StandardLibrary
public class StandardLibraryController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public StandardLibraryController(ApplicationDbContext context)
    {
        _context = context;
    }

    // 1. 获取所有标准食材 (测试重点)
    // GET: api/StandardLibrary/ingredients
    [HttpGet("ingredients")]
    public async Task<ActionResult<List<StandardIngredient>>> GetIngredients()
    {
        // 查库并返回列表
        return await _context.StandardIngredients.ToListAsync();
    }

}