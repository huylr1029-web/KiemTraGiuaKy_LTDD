# Build + chay backend ASP.NET tren server Linux (Render / Docker).
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY backend/*.csproj ./
RUN dotnet restore
COPY backend/. ./
RUN dotnet publish -c Release -o /app/publish
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/publish ./
# Render cap PORT qua bien moi truong; app phai nghe dung PORT do.
CMD sh -c "ASPNETCORE_URLS=http://+:${PORT:-8080} dotnet le_thanh_huy_0827_backend.dll"
