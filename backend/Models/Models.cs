using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;
namespace Backend.Models;
// Tuan 7 Buoc 1: User = IdentityUser + Initials
public class User : IdentityUser { public string? Initials { get; set; } }
// Tuan 6 Product -> Employee ; Category -> Department
public class Department { public int Id { get; set; } public string? Name { get; set; } }
public class Employee {
  public int Id { get; set; } public string? Name { get; set; } public string? Email { get; set; }
  public string Role { get; set; } = "Employee"; public int? DepartmentId { get; set; } public Department? Department { get; set; }
  public string Position { get; set; } = "Nhan vien";
}
public class Attendance {
  public int Id { get; set; } public int EmployeeId { get; set; } public DateTime Date { get; set; }
  public DateTime? CheckIn { get; set; } public DateTime? CheckOut { get; set; }
  public string Status { get; set; } = "Di lam"; public string Note { get; set; } = "";
}
public class LeaveRequest {
  public int Id { get; set; } public int EmployeeId { get; set; } public DateTime From { get; set; } public DateTime To { get; set; }
  public string Reason { get; set; } = ""; public string Status { get; set; } = "Cho duyet";
}
public class Appointment {
  public int Id { get; set; } public string CustomerName { get; set; } = ""; public string CustomerEmail { get; set; } = "";
  public DateTime Date { get; set; } public string Reason { get; set; } = ""; public string Status { get; set; } = "Cho xac nhan";
}
public class Post {
  public int Id { get; set; } public string Title { get; set; } = ""; public string Content { get; set; } = "";
  public string Author { get; set; } = ""; public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
public class ApplicationDbContext : IdentityDbContext<User> {
  public ApplicationDbContext(DbContextOptions<ApplicationDbContext> o) : base(o) {}
  public DbSet<Employee> Employees => Set<Employee>(); public DbSet<Department> Departments => Set<Department>();
  public DbSet<Attendance> Attendances => Set<Attendance>(); public DbSet<LeaveRequest> Leaves => Set<LeaveRequest>();
  public DbSet<Appointment> Appointments => Set<Appointment>(); public DbSet<Post> Posts => Set<Post>();
  protected override void OnModelCreating(ModelBuilder b) { base.OnModelCreating(b); b.Entity<User>().Property(u => u.Initials).HasMaxLength(5); b.HasDefaultSchema("identity"); }
}
public class LoginModel { [Required] public string Username { get; set; } = ""; [Required] public string Password { get; set; } = ""; }
public class RegistrationModel { [Required] public string Username { get; set; } = ""; [Required, EmailAddress] public string Email { get; set; } = ""; [Required, MinLength(6)] public string Password { get; set; } = ""; public string? Initials { get; set; } public string? Role { get; set; } }
