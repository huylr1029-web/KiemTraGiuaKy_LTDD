using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Backend.Models;
using Backend.Repositories;
namespace Backend.Controllers;
[Route("api/[controller]")] [ApiController] [Authorize]
public class EmployeeApiController : ControllerBase {
  private readonly IEmployeeRepository _r; private readonly ApplicationDbContext _db;
  public EmployeeApiController(IEmployeeRepository r, ApplicationDbContext db) { _r = r; _db = db; }
  [HttpGet] public async Task<IActionResult> Get() => Ok(await _r.GetAllAsync());
  [HttpGet("me")] public async Task<IActionResult> Me() {
    var name = User.Identity?.Name;
    var e = await _db.Employees.FirstOrDefaultAsync(x => x.Email == name || x.Name == name);
    return e == null ? NotFound() : Ok(e);
  }
  [HttpGet("{id:int}")] public async Task<IActionResult> GetById(int id) { var e = await _r.GetByIdAsync(id); return e == null ? NotFound() : Ok(e); }
  [HttpGet("search")] public async Task<IActionResult> Search([FromQuery] string name) { var all = await _r.GetAllAsync(); return Ok(all.Where(e => (e.Name ?? "").Contains(name, StringComparison.OrdinalIgnoreCase))); }
  [HttpPost] [Authorize(Roles = "Admin")] public async Task<IActionResult> Add([FromBody] Employee e) { await _r.AddAsync(e); return CreatedAtAction(nameof(GetById), new { id = e.Id }, e); }
  [HttpPut("{id:int}")] [Authorize(Roles = "Admin")] public async Task<IActionResult> Update(int id, [FromBody] Employee e) { if (id != e.Id) return BadRequest(); await _r.UpdateAsync(e); return NoContent(); }
  [HttpDelete("{id:int}")] [Authorize(Roles = "Admin")] public async Task<IActionResult> Delete(int id) { await _r.DeleteAsync(id); return NoContent(); }
}
[Route("api/[controller]")] [ApiController] [Authorize]
public class DepartmentApiController : ControllerBase {
  private readonly ApplicationDbContext _db; public DepartmentApiController(ApplicationDbContext db) => _db = db;
  [HttpGet] public async Task<IActionResult> Get() => Ok(await _db.Departments.ToListAsync());
  [HttpPost] [Authorize(Roles = "Admin")] public async Task<IActionResult> Add([FromBody] Department d) { _db.Departments.Add(d); await _db.SaveChangesAsync(); return Ok(d); }
  [HttpPut("{id:int}")] [Authorize(Roles = "Admin")] public async Task<IActionResult> Update(int id, [FromBody] Department d) { if (id != d.Id) return BadRequest(); _db.Entry(d).State = EntityState.Modified; await _db.SaveChangesAsync(); return NoContent(); }
  // Tuan 7 bai tap 8: xoa phong -> nhan vien ve null (khong xoa nhan vien).
  [HttpDelete("{id:int}")] [Authorize(Roles = "Admin")] public async Task<IActionResult> Delete(int id) {
    var emps = await _db.Employees.Where(e => e.DepartmentId == id).ToListAsync();
    foreach (var e in emps) e.DepartmentId = null;
    var d = await _db.Departments.FindAsync(id); if (d != null) _db.Departments.Remove(d);
    await _db.SaveChangesAsync(); return NoContent();
  }
}
[Route("api/[controller]")] [ApiController] [Authorize]
public class AttendanceApiController : ControllerBase {
  private readonly IAttendanceRepository _r; private readonly ApplicationDbContext _db;
  public AttendanceApiController(IAttendanceRepository r, ApplicationDbContext db) { _r = r; _db = db; }
  [HttpGet] public async Task<IActionResult> Get([FromQuery] int? employeeId) {
    var all = await _r.GetAllAsync();
    if (employeeId != null) all = all.Where(a => a.EmployeeId == employeeId);
    var names = await _db.Employees.ToDictionaryAsync(e => e.Id, e => e.Name ?? "");
    return Ok(all.Select(a => new { a.Id, a.EmployeeId, EmployeeName = names.TryGetValue(a.EmployeeId, out var n) ? n : "", a.Date, a.CheckIn, a.CheckOut, a.Status, a.Note }));
  }
  [HttpPost] public async Task<IActionResult> Add([FromBody] Attendance a) { await _r.AddAsync(a); return Ok(a); }
  [HttpPut("{id:int}")] [Authorize(Roles = "Admin")] public async Task<IActionResult> Update(int id, [FromBody] Attendance a) { if (id != a.Id) return BadRequest(); await _r.UpdateAsync(a); return NoContent(); }
  [HttpDelete("{id:int}")] [Authorize(Roles = "Admin")] public async Task<IActionResult> Delete(int id) { await _r.DeleteAsync(id); return NoContent(); }
}
[Route("api/[controller]")] [ApiController] [Authorize]
public class AppointmentApiController : ControllerBase {
  private readonly ApplicationDbContext _db; public AppointmentApiController(ApplicationDbContext db) => _db = db;
  [HttpGet] public async Task<IActionResult> Get([FromQuery] string? email) {
    var q = _db.Appointments.AsQueryable();
    if (!string.IsNullOrEmpty(email)) q = q.Where(a => a.CustomerEmail == email);
    return Ok(await q.OrderByDescending(a => a.Date).ToListAsync());
  }
  [HttpPost] public async Task<IActionResult> Add([FromBody] Appointment a) { _db.Appointments.Add(a); await _db.SaveChangesAsync(); return Ok(a); }
  [HttpPut("{id:int}")] [Authorize(Roles = "Admin")] public async Task<IActionResult> Update(int id, [FromBody] Appointment a) { if (id != a.Id) return BadRequest(); _db.Entry(a).State = EntityState.Modified; await _db.SaveChangesAsync(); return NoContent(); }
  [HttpDelete("{id:int}")] [Authorize(Roles = "Admin")] public async Task<IActionResult> Delete(int id) { var a = await _db.Appointments.FindAsync(id); if (a != null) _db.Appointments.Remove(a); await _db.SaveChangesAsync(); return NoContent(); }
}
[Route("api/[controller]")] [ApiController] [Authorize]
public class PostApiController : ControllerBase {
  private readonly ApplicationDbContext _db; public PostApiController(ApplicationDbContext db) => _db = db;
  [HttpGet] public async Task<IActionResult> Get() => Ok(await _db.Posts.OrderByDescending(p => p.CreatedAt).ToListAsync());
  [HttpPost] public async Task<IActionResult> Add([FromBody] Post p) { p.CreatedAt = DateTime.UtcNow; _db.Posts.Add(p); await _db.SaveChangesAsync(); return Ok(p); }
  [HttpPut("{id:int}")] [Authorize(Roles = "Admin")] public async Task<IActionResult> Update(int id, [FromBody] Post p) { if (id != p.Id) return BadRequest(); _db.Entry(p).State = EntityState.Modified; await _db.SaveChangesAsync(); return NoContent(); }
  [HttpDelete("{id:int}")] [Authorize(Roles = "Admin")] public async Task<IActionResult> Delete(int id) { var p = await _db.Posts.FindAsync(id); if (p != null) _db.Posts.Remove(p); await _db.SaveChangesAsync(); return NoContent(); }
}
[Route("api/[controller]")] [ApiController] [Authorize]
public class LeaveApiController : ControllerBase {
  private readonly ApplicationDbContext _db; public LeaveApiController(ApplicationDbContext db) => _db = db;
  [HttpGet] public async Task<IActionResult> Get([FromQuery] int? employeeId) {
    var q = _db.Leaves.AsQueryable(); if (employeeId != null) q = q.Where(l => l.EmployeeId == employeeId);
    var list = await q.ToListAsync(); var names = await _db.Employees.ToDictionaryAsync(e => e.Id, e => e.Name ?? "");
    return Ok(list.Select(l => new { l.Id, l.EmployeeId, EmployeeName = names.TryGetValue(l.EmployeeId, out var n) ? n : "", l.From, l.To, l.Reason, l.Status }));
  }
  [HttpPost] public async Task<IActionResult> Add([FromBody] LeaveRequest l) { _db.Leaves.Add(l); await _db.SaveChangesAsync(); return Ok(l); }
  [HttpPut("{id:int}")] public async Task<IActionResult> Update(int id, [FromBody] LeaveRequest l) { if (id != l.Id) return BadRequest(); _db.Entry(l).State = EntityState.Modified; await _db.SaveChangesAsync(); return NoContent(); }
  [HttpDelete("{id:int}")] public async Task<IActionResult> Delete(int id) { var l = await _db.Leaves.FindAsync(id); if (l != null) _db.Leaves.Remove(l); await _db.SaveChangesAsync(); return NoContent(); }
}
