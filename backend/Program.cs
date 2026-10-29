// Tuan 7 Buoc 4 + Buoc 8 (da gop, bo MapIdentityApi vi da tu config Identity):
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Backend.Models;
using Backend.Repositories;
var builder = WebApplication.CreateBuilder(args);
var conn = builder.Configuration.GetConnectionString("DefaultConnection") ?? "";
// Deploy Linux (Render/Docker) dung SQLite khi connection string bat dau bang "Data Source=",
// may Windows cua sinh vien van dung SQL Server nhu giao trinh Tuan 6.
builder.Services.AddDbContext<ApplicationDbContext>(o => { if (conn.StartsWith("Data Source=")) o.UseSqlite(conn); else o.UseSqlServer(conn); });
builder.Services.AddIdentity<User, IdentityRole>().AddEntityFrameworkStores<ApplicationDbContext>().AddDefaultTokenProviders();
builder.Services.AddControllers();
builder.Services.AddScoped<IEmployeeRepository, EmployeeRepository>();
builder.Services.AddScoped<IAttendanceRepository, AttendanceRepository>();
builder.Services.AddEndpointsApiExplorer(); builder.Services.AddSwaggerGen();
builder.Services.AddCors(o => o.AddPolicy("MyAllowOrigins", p => p.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod()));
var jwt = builder.Configuration.GetSection("JWTKey"); var key = Encoding.UTF8.GetBytes(jwt["Secret"]!);
builder.Services.AddAuthentication(o => { o.DefaultAuthenticateScheme = "Bearer"; o.DefaultChallengeScheme = "Bearer"; })
  .AddJwtBearer("Bearer", o => o.TokenValidationParameters = new TokenValidationParameters { ValidateIssuer = true, ValidateAudience = true, ValidateLifetime = true, ValidateIssuerSigningKey = true, ValidIssuer = jwt["ValidIssuer"], ValidAudience = jwt["ValidAudience"], IssuerSigningKey = new SymmetricSecurityKey(key) });
builder.Services.AddAuthorization();
var app = builder.Build();
app.MapGet("/health", () => Results.Ok("ok"));
using (var scope = app.Services.CreateScope()) {
  scope.ServiceProvider.GetRequiredService<ApplicationDbContext>().Database.EnsureCreated();
  var rm = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();
  foreach (var r in new[] { "Admin", "Employee", "Customer" }) if (!await rm.RoleExistsAsync(r)) await rm.CreateAsync(new IdentityRole(r));
  // Seed Admin duy nhat tu cau hinh (dev): dat AdminSeed:Email/Password trong appsettings.json, khong hard-code mat khau o code.
  var um = scope.ServiceProvider.GetRequiredService<UserManager<User>>();
  var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
  var seedEmail = app.Configuration["AdminSeed:Email"]; var seedPass = app.Configuration["AdminSeed:Password"];
  if (!string.IsNullOrEmpty(seedEmail) && !string.IsNullOrEmpty(seedPass) && await um.FindByEmailAsync(seedEmail) == null) {
    var admin = new User { UserName = seedEmail, Email = seedEmail };
    if ((await um.CreateAsync(admin, seedPass)).Succeeded) {
      await um.AddToRoleAsync(admin, "Admin");
      db.Employees.Add(new Employee { Name = seedEmail, Email = seedEmail, Role = "Admin" }); await db.SaveChangesAsync();
    }
  }
}
if (app.Environment.IsDevelopment()) { app.UseSwagger(); app.UseSwaggerUI(); }
// Khong UseHttpsRedirection khi chay sau Cloudflare/Render (TLS ket thuc o edge), tranh loop redirect.
app.UseCors("MyAllowOrigins"); app.UseAuthentication(); app.UseAuthorization(); app.MapControllers(); app.Run();
app.UseRouting();
app.UseCors("MyAllowOrigins");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();