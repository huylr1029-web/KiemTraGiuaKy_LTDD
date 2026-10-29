using Microsoft.EntityFrameworkCore;
using Backend.Models;
namespace Backend.Repositories;
// Tuan 6: Repository Pattern (giong IProductRepository/ProductRepository)
public interface IEmployeeRepository { Task<IEnumerable<Employee>> GetAllAsync(); Task<Employee?> GetByIdAsync(int id); Task AddAsync(Employee e); Task UpdateAsync(Employee e); Task DeleteAsync(int id); }
public class EmployeeRepository : IEmployeeRepository {
  private readonly ApplicationDbContext _c; public EmployeeRepository(ApplicationDbContext c) => _c = c;
  public async Task<IEnumerable<Employee>> GetAllAsync() => await _c.Employees.Include(e => e.Department).ToListAsync();
  public async Task<Employee?> GetByIdAsync(int id) => await _c.Employees.FindAsync(id);
  public async Task AddAsync(Employee e) { _c.Employees.Add(e); await _c.SaveChangesAsync(); }
  public async Task UpdateAsync(Employee e) { _c.Entry(e).State = EntityState.Modified; await _c.SaveChangesAsync(); }
  public async Task DeleteAsync(int id) { var e = await _c.Employees.FindAsync(id); if (e != null) { _c.Employees.Remove(e); await _c.SaveChangesAsync(); } }
}
public interface IAttendanceRepository { Task<IEnumerable<Attendance>> GetAllAsync(); Task AddAsync(Attendance a); Task UpdateAsync(Attendance a); Task DeleteAsync(int id); }
public class AttendanceRepository : IAttendanceRepository {
  private readonly ApplicationDbContext _c; public AttendanceRepository(ApplicationDbContext c) => _c = c;
  public async Task<IEnumerable<Attendance>> GetAllAsync() => await _c.Attendances.ToListAsync();
  public async Task AddAsync(Attendance a) { _c.Attendances.Add(a); await _c.SaveChangesAsync(); }
  public async Task UpdateAsync(Attendance a) { _c.Entry(a).State = EntityState.Modified; await _c.SaveChangesAsync(); }
  public async Task DeleteAsync(int id) { var a = await _c.Attendances.FindAsync(id); if (a != null) { _c.Attendances.Remove(a); await _c.SaveChangesAsync(); } }
}
