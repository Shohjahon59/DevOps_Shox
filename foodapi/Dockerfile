FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["FoodApi/FoodApi.csproj", "FoodApi/"]
RUN dotnet restore "FoodApi/FoodApi.csproj"
COPY . .
WORKDIR "/src/FoodApi"
RUN dotnet build "FoodApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "FoodApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "FoodApi.dll"]