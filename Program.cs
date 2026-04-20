using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using LH_PET_WEB.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.IdentityModel.Tokens;
using LH_PET_WEB.Services;

var builder = WebApplication.CreateBuilder(args);

var connectionString = "Server=127.0.0.1;Uid=root;Pwd=root;Database=db_vetplus;";

builder.Services.AddDbContext<ContextoBanco>(options =>
    options.UseMySql(
        connectionString,
        ServerVersion.AutoDetect(connectionString)
    ));

builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddControllersWithViews();

builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options => {
        options.LoginPath = "/Autenticacao/Login";
        options.AccessDeniedPath = "/Autenticacao/AcessoNegado";
        options.ExpireTimeSpan = TimeSpan.FromHours(8);
    }) 
    .AddJwtBearer(options => {
        options.TokenValidationParameters = new TokenValidationParameters {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"] ?? "ChaveSuperSecretaDeTeste123!")),
            ValidateIssuer = false,
            ValidateAudience = false
        };
    });

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var contexto = scope.ServiceProvider.GetRequiredService<ContextoBanco>();
    var config = scope.ServiceProvider.GetRequiredService<IConfiguration>();

    var emailAdmin = config["AdminInicial:Email"] ?? "admin@admin.com";
    var senhaAdmin = config["AdminInicial:Senha"] ?? "admin123";

    try 
    {
        if (!contexto.Usuarios.Any(u => u.Email == emailAdmin))
        {
            contexto.Usuarios.Add(new LH_PET_WEB.Models.Usuario
            {
                Nome = "Administrador",
                Email = emailAdmin,
                SenhaHash = BCrypt.Net.BCrypt.HashPassword(senhaAdmin),
                Perfil = "Admin",
                Ativo = true,
                SenhaTemporaria = false
            });
            contexto.SaveChanges();
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Nota: Verifique se os Models coincidem com as colunas do db_vetplus. Erro: {ex.Message}");
    }
}

app.UseHttpsRedirection();
app.UseStaticFiles(); 
app.UseRouting();
app.UseAuthentication(); 
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();