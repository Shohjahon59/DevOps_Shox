using Prometheus;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.UseRouting();

// HTTP metrics (requests, duration, etc.)
app.UseHttpMetrics();

// ✅ Custom metrics (static/readonlysiz)
var ordersCreated = Metrics.CreateCounter(
    "foodapi_orders_created_total",
    "Total number of orders created");

var orderDuration = Metrics.CreateHistogram(
    "foodapi_order_duration_seconds",
    "Order processing duration",
    new HistogramConfiguration
    {
        Buckets = Histogram.ExponentialBuckets(0.01, 2, 10)
    });

app.MapGet("/health", () => Results.Ok(new { status = "ok" }));

app.MapPost("/orders", () =>
{
    using (orderDuration.NewTimer())
    {
        ordersCreated.Inc();
        Console.WriteLine("OrderCreated"); // Loki uchun log
        return Results.Ok(new { message = "created" });
    }
});

app.MapMetrics("/metrics");

app.Run();
