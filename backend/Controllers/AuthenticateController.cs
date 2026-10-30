using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.Collections.Concurrent;
using System.Net;
using System.Net.Mail;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Backend.Models;
namespace Backend.Controllers;
[Route("api/[controller]")] [ApiController]
public class AuthenticateController : ControllerBase {
  private readonly UserManager<User> _um; private readonly RoleManager<IdentityRole> _rm; private readonly IConfiguration _cfg; private readonly ApplicationDbContext _db;
  // OTP chi luu o server, het han 5 phut. Ban production thay bang bang OTP trong DB + dich vu SMS/Email.
  private static readonly ConcurrentDictionary<string, (string Code, DateTime Exp)> _otps = new();
  public AuthenticateController(UserManager<User> um, RoleManager<IdentityRole> rm, IConfiguration cfg, ApplicationDbContext db) { _um = um; _rm = rm; _cfg = cfg; _db = db; }
  [HttpPost("register")] public async Task<IActionResult> Register([FromBody] RegistrationModel m) {
    if (!ModelState.IsValid) return BadRequest(ModelState);
    if (await _um.FindByNameAsync(m.Username) != null) return BadRequest(new { Status = false, Message = "User already exists" });
    var role = m.Role == "Customer" || m.Role == "Employee" ? m.Role : "Employee";
    var user = new User { UserName = m.Username, Email = m.Email, Initials = m.Initials };
    var r = await _um.CreateAsync(user, m.Password); if (!r.Succeeded) return StatusCode(500, new { Status = false, Message = "User creation failed" });
    if (!await _rm.RoleExistsAsync(role)) await _rm.CreateAsync(new IdentityRole(role));
    await _um.AddToRoleAsync(user, role);
    // Tao ho so Employee tuong ung de EmployeeApi/me tra ve duoc (nguon su that duy nhat la DB).
    _db.Employees.Add(new Employee { Name = m.Username, Email = m.Email, Role = role });
    await _db.SaveChangesAsync();
    return Ok(new { Status = true, Message = "User created successfully" });
  }
  // Sinh OTP va gui that qua Email (SMTP) neu da cau hinh Smtp:*.
  // Neu chua cau hinh SMTP hoac gui loi: in ra log backend (ban dev) de van demo duoc,
  // va KHONG BAO GIO tra ma ve client. SMS that: thay the ham nay bang Twilio/Vonage.
  private async Task GenerateAndSendOtpAsync(User user) {
    var code = Random.Shared.Next(100000, 999999).ToString();
    _otps[user.UserName!] = (code, DateTime.UtcNow.AddMinutes(5));
    var host = _cfg["Smtp:Host"]; var smtpUser = _cfg["Smtp:User"]; var smtpPass = _cfg["Smtp:Pass"];
    if (string.IsNullOrEmpty(host) || string.IsNullOrEmpty(smtpUser) || string.IsNullOrEmpty(smtpPass) || string.IsNullOrEmpty(user.Email)) {
      Console.WriteLine($"[OTP-DEV] {user.UserName}: {code} (het han 5 phut) - chua cau hinh SMTP, xem ma o log Render/backend");
      return;
    }
    try {
      var port = int.TryParse(_cfg["Smtp:Port"], out var p) ? p : 587;
      var ssl = !bool.TryParse(_cfg["Smtp:EnableSsl"], out var s) || s;
      using var client = new SmtpClient(host, port) { EnableSsl = ssl, UseDefaultCredentials = false, Credentials = new NetworkCredential(smtpUser, smtpPass), Timeout = 10000 };
      using var msg = new MailMessage(_cfg["Smtp:From"] ?? smtpUser, user.Email, "Ma OTP dang nhap - Cham cong",
        $"Xin chao {user.UserName},\n\nMa OTP cua ban la: {code}\nMa het han sau 5 phut. Khong chia se ma nay cho ai.\n\nHe thong cham cong le_thanh_huy_0827");
      await client.SendMailAsync(msg);
      Console.WriteLine($"[OTP-EMAIL] Da gui OTP qua Email toi {user.Email}");
    } catch (Exception ex) {
      Console.WriteLine($"[OTP-DEV] Gui Email loi ({ex.Message}) - ma du phong: {user.UserName}: {code} (het han 5 phut)");
    }
  }
  // Buoc 1: chi kiem tra mat khau + sinh OTP, KHONG tra token.
  [HttpPost("login")] public async Task<IActionResult> Login([FromBody] LoginModel m) {
    var user = await _um.FindByNameAsync(m.Username);
    if (user == null || !await _um.CheckPasswordAsync(user, m.Password)) return Unauthorized(new { Status = false, Message = "Invalid username or password" });
    await GenerateAndSendOtpAsync(user);
    return Ok(new { Status = true, RequiresOtp = true, Message = "OTP da duoc gui" });
  }
  [HttpPost("request-otp")] public async Task<IActionResult> RequestOtp([FromBody] LoginModel m) {
    var user = await _um.FindByNameAsync(m.Username); if (user == null) return BadRequest(new { Message = "User not found" });
    await GenerateAndSendOtpAsync(user);
    return Ok(new { Status = true, Message = "OTP da duoc gui" });
  }
  // Cai dat app: xac minh lai mat khau truoc khi bat dang nhap sinh trac.
  // Chi kiem tra mat khau cua chinh tai khoan dang co JWT, KHONG gui OTP moi,
  // KHONG cap token moi. Sai mat khau -> 401, khong bat duoc sinh trac.
  [HttpPost("verify-password")] [Microsoft.AspNetCore.Authorization.Authorize] public async Task<IActionResult> VerifyPassword([FromBody] VerifyPasswordModel m) {
    var user = await _um.GetUserAsync(User); if (user == null) return Unauthorized();
    if (string.IsNullOrEmpty(m.Password)) return BadRequest(new { Message = "Chua nhap mat khau" });
    return await _um.CheckPasswordAsync(user, m.Password)
      ? Ok(new { Status = true, Message = "Mat khau dung" })
      : Unauthorized(new { Status = false, Message = "Sai mat khau" });
  }
  // Buoc 2: verify OTP dung moi cap JWT.
  [HttpPost("verify-otp")] public async Task<IActionResult> VerifyOtp([FromBody] OtpModel m) {
    if (!_otps.TryGetValue(m.Username, out var otp) || otp.Exp < DateTime.UtcNow || otp.Code != m.Code)
      return Unauthorized(new { Status = false, Message = "OTP sai hoac het han" });
    _otps.TryRemove(m.Username, out _);
    var user = await _um.FindByNameAsync(m.Username); if (user == null) return Unauthorized();
    return Ok(new { Status = true, Token = await GenerateJwt(user) });
  }
  private async Task<string> GenerateJwt(User user) {
    var roles = await _um.GetRolesAsync(user);
    var claims = new List<Claim> { new(ClaimTypes.Name, user.UserName!), new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()) };
    claims.AddRange(roles.Select(r => new Claim(ClaimTypes.Role, r)));
    var jwt = _cfg.GetSection("JWTKey"); var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt["Secret"]!));
    var token = new JwtSecurityToken(issuer: jwt["ValidIssuer"], audience: jwt["ValidAudience"], claims: claims, expires: DateTime.UtcNow.AddHours(double.Parse(jwt["TokenExpiryTimeInHour"]!)), signingCredentials: new SigningCredentials(key, SecurityAlgorithms.HmacSha256));
    return new JwtSecurityTokenHandler().WriteToken(token);
  }
  // OAuth2.0 thu cong (Authorization Code, khong dung cookie handler):
  // 1) /external redirect sang Google; 2) Google tra code ve /external-callback;
  // 3) backend doi code lay access_token + email tu userinfo; 4) cap JWT noi bo
  // roi redirect ve scheme cua app: lethanhhuy0827://auth?token=...
  // Can dang ky redirect_uri nay trong Google Cloud Console (OAuth client).
  [HttpGet("external")] public IActionResult ExternalLogin([FromQuery] string provider) {
    if (provider != "Google") return BadRequest("Chi ho tro Google trong ban nay");
    var clientId = _cfg["Google:ClientId"]; if (string.IsNullOrEmpty(clientId)) return BadRequest("Backend chua cau hinh Google:ClientId");
    var redirectUri = $"{Request.Scheme}://{Request.Host}/api/Authenticate/external-callback";
    var url = "https://accounts.google.com/o/oauth2/v2/auth?client_id=" + Uri.EscapeDataString(clientId)
      + "&redirect_uri=" + Uri.EscapeDataString(redirectUri)
      + "&response_type=code&scope=" + Uri.EscapeDataString("openid email profile") + "&access_type=offline";
    return Redirect(url);
  }
  [HttpGet("external-callback")] public async Task<IActionResult> ExternalCallback([FromQuery] string? code, [FromQuery] string? error) {
    if (error != null || string.IsNullOrEmpty(code)) return BadRequest("Google dang nhap bi huy hoac loi");
    var clientId = _cfg["Google:ClientId"]; var secret = _cfg["Google:ClientSecret"];
    if (string.IsNullOrEmpty(clientId) || string.IsNullOrEmpty(secret)) return BadRequest("Backend chua cau hinh Google");
    var redirectUri = $"{Request.Scheme}://{Request.Host}/api/Authenticate/external-callback";
    using var http = new HttpClient();
    var tokenRes = await http.PostAsync("https://oauth2.googleapis.com/token", new FormUrlEncodedContent(new Dictionary<string, string> {
      ["code"] = code, ["client_id"] = clientId, ["client_secret"] = secret, ["redirect_uri"] = redirectUri, ["grant_type"] = "authorization_code" }));
    if (!tokenRes.IsSuccessStatusCode) return BadRequest("Doi code Google that bai");
    var tokenJson = System.Text.Json.JsonDocument.Parse(await tokenRes.Content.ReadAsStringAsync());
    var accessToken = tokenJson.RootElement.GetProperty("access_token").GetString();
    var userReq = new HttpRequestMessage(HttpMethod.Get, "https://openidconnect.googleapis.com/v1/userinfo");
    userReq.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", accessToken);
    var userRes = await http.SendAsync(userReq); if (!userRes.IsSuccessStatusCode) return BadRequest("Khong lay duoc thong tin Google");
    var userJson = System.Text.Json.JsonDocument.Parse(await userRes.Content.ReadAsStringAsync());
    var email = userJson.RootElement.GetProperty("email").GetString(); if (email == null) return BadRequest("Khong lay duoc email tu Google");
    var user = await _um.FindByEmailAsync(email);
    if (user == null) {
      user = new User { UserName = email, Email = email };
      var r = await _um.CreateAsync(user); if (!r.Succeeded) return BadRequest("Khong tao duoc user");
      await _um.AddToRoleAsync(user, "Employee");
      _db.Employees.Add(new Employee { Name = email, Email = email, Role = "Employee" }); await _db.SaveChangesAsync();
    }
    var token = await GenerateJwt(user);
    return Redirect($"lethanhhuy0827://auth?token={Uri.EscapeDataString(token)}");
  }
}
public class OtpModel { public string Username { get; set; } = ""; public string Code { get; set; } = ""; }
public class VerifyPasswordModel { public string Password { get; set; } = ""; }
