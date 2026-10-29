# Backend - Tuan 6 + Tuan 7 (ASP.NET Core 8) - NGUON SU THAT DUY NHAT
Flutter KHONG con du lieu local: moi nhan vien, phong ban, cham cong, don nghi
deu doc/ghi qua API nay. SharedPreferences o app chi luu JWT token (theo Tuan 7).

## Chay local CHI DE DEV/BUILD truoc khi deploy (KHONG phai cach nop bai)
Ban nop bat buoc dung backend da deploy public tren Render (xem docs/DEPLOY.md).
Doan duoi chi de lap trinh vien kiem tra backend tren may minh truoc khi deploy:
```bash
cd backend
cp appsettings.example.json appsettings.json
# Sua trong appsettings.json: ConnectionStrings, JWTKey.Secret, AdminSeed, Google (neu dung OAuth)
dotnet restore
dotnet ef migrations add Initial
dotnet ef database update
dotnet run   # Chi kiem tra local: Swagger o https://localhost:5001/swagger, xem log OTP o console nay
```
- Admin dau tien: backend tu tao khi co AdminSeed:Email/Password trong appsettings.json.
  Dung tai khoan do dang nhap, roi Admin tao/sua nhan vien qua API.
- Nguoi dung dang ky qua app: backend tu tao ho so Employee tuong ung, role ep ve
  Employee/Customer (khong tu gan Admin qua API dang ky).

## OTP (de bai muc 2)
- POST /api/Authenticate/login: kiem tra mat khau, sinh OTP 6 so, het han 5 phut.
- POST /api/Authenticate/verify-otp: dung moi cap JWT.
- Ban dev: OTP in ra console cua backend (`[OTP-DEV] ...`), KHONG tra ve client.
  Ban that: thay dong Console.WriteLine bang Twilio/Vonage (SMS) hoac SMTP/SendGrid (Email).

## OAuth2.0 (de bai muc 1)
Xem docs/OAUTH_SETUP.md. Luong Authorization Code thu cong o AuthenticateController:
external -> Google -> external-callback -> doi code -> cap JWT -> redirect ve app.

## API chinh
- POST /api/Authenticate/register, /login, /request-otp, /verify-otp, GET /external
- GET/POST/PUT/DELETE /api/EmployeeApi (PUT/DELETE chi Admin), GET /api/EmployeeApi/me,
  GET /api/EmployeeApi/search?name=
- GET/POST/PUT/DELETE /api/DepartmentApi (PUT/DELETE chi Admin; xoa phong -> NV ve null)
- GET/POST/PUT/DELETE /api/AttendanceApi (PUT/DELETE chi Admin), GET ?employeeId=
- GET/POST/PUT/DELETE /api/LeaveApi, GET ?employeeId=
- GET/POST/PUT/DELETE /api/AppointmentApi (PUT/DELETE chi Admin), GET ?email=
- GET/POST/PUT/DELETE /api/PostApi (PUT/DELETE chi Admin; bai dang Tuan 6)
