using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SousChefBackend.Data;
using SousChefBackend.DTOs.User;
using SousChefBackend.Models;
using System.Security.Claims;

namespace SousChefBackend.Controllers;

[ApiController]
[Route("api/ums/user")]
[Authorize]
public class UserController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public UserController(ApplicationDbContext context)
    {
        _context = context;
    }

    private long GetCurrentUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
        return userIdClaim != null ? long.Parse(userIdClaim.Value) : 0;
    }

    [HttpGet]
    public async Task<IActionResult> GetUserBriefInfo([FromQuery] long? id)
    {
        var userId = id ?? GetCurrentUserId();
        if (userId == 0)
        {
            return Unauthorized();
        }

        var user = await _context.Users.FindAsync(userId);
        if (user == null)
        {
            return NotFound(new { message = "User not found" });
        }

        return Ok(new UserBriefInfoResponse
        {
            UserId = user.UserId,
            UserName = user.Username,
            Email = user.Email,
            Profile = new UserProfile
            {
                Age = user.Age,
                Height = user.Height,
                Weight = user.Weight
            }
        });
    }

    [HttpPut]
    public async Task<IActionResult> UpdateUserInfo([FromQuery] long? id, [FromBody] UserBriefInfoResponse request)
    {
        var userId = id ?? GetCurrentUserId();
        if (userId == 0)
        {
            return Unauthorized();
        }

        var user = await _context.Users.FindAsync(userId);
        if (user == null)
        {
            return NotFound(new { message = "User not found" });
        }

        if (request.Profile != null)
        {
            user.Age = request.Profile.Age;
            user.Height = request.Profile.Height;
            user.Weight = request.Profile.Weight;
        }

        user.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return Ok(new { userId = user.UserId, message = "User info updated successfully" });
    }

    [HttpGet("preferences")]
    public async Task<IActionResult> GetUserPreferences([FromQuery] long? id)
    {
        var userId = id ?? GetCurrentUserId();
        if (userId == 0)
        {
            return Unauthorized();
        }

        var preferences = await _context.UserPreferences
            .Where(p => p.UserId == userId)
            .ToListAsync();

        var response = new UserPreferencesResponse { UserId = userId };
        
        foreach (var pref in preferences)
        {
            switch (pref.PreferenceType)
            {
                case "dietaryType":
                    response.Preferences.DietaryType = pref.PreferenceValue;
                    break;
                case "cuisineTypes":
                    response.Preferences.CuisineTypes.Add(pref.PreferenceValue);
                    break;
                case "spiceLevel":
                    response.Preferences.SpiceLevel = pref.PreferenceValue;
                    break;
                case "cookingTimePreference":
                    response.Preferences.CookingTimePreference = pref.PreferenceValue;
                    break;
            }
        }

        return Ok(response);
    }

    [HttpPut("preferences")]
    public async Task<IActionResult> UpdateUserPreferences([FromQuery] long? id, [FromBody] UserPreferences request)
    {
        var userId = id ?? GetCurrentUserId();
        if (userId == 0)
        {
            return Unauthorized();
        }

        // Remove existing preferences
        var existingPrefs = await _context.UserPreferences
            .Where(p => p.UserId == userId)
            .ToListAsync();
        _context.UserPreferences.RemoveRange(existingPrefs);

        // Add new preferences
        if (!string.IsNullOrEmpty(request.DietaryType))
        {
            _context.UserPreferences.Add(new UserPreference
            {
                UserId = userId,
                PreferenceType = "dietaryType",
                PreferenceValue = request.DietaryType
            });
        }

        if (!string.IsNullOrEmpty(request.SpiceLevel))
        {
            _context.UserPreferences.Add(new UserPreference
            {
                UserId = userId,
                PreferenceType = "spiceLevel",
                PreferenceValue = request.SpiceLevel
            });
        }

        if (!string.IsNullOrEmpty(request.CookingTimePreference))
        {
            _context.UserPreferences.Add(new UserPreference
            {
                UserId = userId,
                PreferenceType = "cookingTimePreference",
                PreferenceValue = request.CookingTimePreference
            });
        }

        foreach (var cuisine in request.CuisineTypes)
        {
            _context.UserPreferences.Add(new UserPreference
            {
                UserId = userId,
                PreferenceType = "cuisineTypes",
                PreferenceValue = cuisine
            });
        }

        await _context.SaveChangesAsync();

        return Ok(new { userId, message = "User preferences updated successfully" });
    }

    [HttpGet("taboos")]
    public async Task<IActionResult> GetUserTaboos([FromQuery] long? id)
    {
        var userId = id ?? GetCurrentUserId();
        if (userId == 0)
        {
            return Unauthorized();
        }

        var taboos = await _context.UserTaboos
            .Where(t => t.UserId == userId)
            .Select(t => t.Taboo)
            .ToListAsync();

        return Ok(new UserTaboosResponse
        {
            UserId = userId,
            Taboos = taboos
        });
    }

    [HttpPut("taboos")]
    public async Task<IActionResult> UpdateUserTaboos([FromQuery] long? id, [FromBody] UserTaboosResponse request)
    {
        var userId = id ?? GetCurrentUserId();
        if (userId == 0)
        {
            return Unauthorized();
        }

        // Remove existing taboos
        var existingTaboos = await _context.UserTaboos
            .Where(t => t.UserId == userId)
            .ToListAsync();
        _context.UserTaboos.RemoveRange(existingTaboos);

        // Add new taboos
        foreach (var taboo in request.Taboos)
        {
            _context.UserTaboos.Add(new UserTaboo
            {
                UserId = userId,
                Taboo = taboo
            });
        }

        await _context.SaveChangesAsync();

        return Ok(new { userId, message = "User taboos updated successfully" });
    }

    [HttpGet("allergies")]
    public async Task<IActionResult> GetUserAllergies([FromQuery] long? id)
    {
        var userId = id ?? GetCurrentUserId();
        if (userId == 0)
        {
            return Unauthorized();
        }

        var allergies = await _context.UserAllergies
            .Where(a => a.UserId == userId)
            .Select(a => a.Allergy)
            .ToListAsync();

        return Ok(new UserAllergiesResponse
        {
            UserId = userId,
            Allergies = allergies
        });
    }

    [HttpPut("allergies")]
    public async Task<IActionResult> UpdateUserAllergies([FromQuery] long? id, [FromBody] UserAllergiesResponse request)
    {
        var userId = id ?? GetCurrentUserId();
        if (userId == 0)
        {
            return Unauthorized();
        }

        // Remove existing allergies
        var existingAllergies = await _context.UserAllergies
            .Where(a => a.UserId == userId)
            .ToListAsync();
        _context.UserAllergies.RemoveRange(existingAllergies);

        // Add new allergies
        foreach (var allergy in request.Allergies)
        {
            _context.UserAllergies.Add(new UserAllergy
            {
                UserId = userId,
                Allergy = allergy
            });
        }

        await _context.SaveChangesAsync();

        return Ok(new { userId, message = "User allergies updated successfully" });
    }
}

