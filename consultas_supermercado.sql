-- Facturación y ganancia por mes
SELECT
    c.NombreMes,
    c.Mes,
    COUNT(*) AS CantidadVentas,
    SUM(v.Cantidad) AS UnidadesVendidas,
    ROUND(SUM(v.Cantidad * v.PrecioUnitario), 0) AS Facturacion,
    ROUND(SUM(v.Cantidad * v.CostoUnitario), 0) AS Costo,
    ROUND(SUM(v.Cantidad * (v.PrecioUnitario - v.CostoUnitario)), 0) AS Ganancia,
    ROUND(SUM(v.Cantidad * (v.PrecioUnitario - v.CostoUnitario)) * 100.0 /
          SUM(v.Cantidad * v.PrecioUnitario), 1) AS MargenPct
FROM Ventas v
JOIN Calendario c ON c.Fecha = v.Fecha
GROUP BY c.Mes, c.NombreMes
ORDER BY c.Mes;


-- Facturación por provincia y sucursal
SELECT
    s.Provincia,
    s.Nombre AS Sucursal,
    s.Formato,
    COUNT(*) AS CantidadVentas,
    ROUND(SUM(v.Cantidad * v.PrecioUnitario), 0) AS Facturacion,
    ROUND(SUM(v.Cantidad * v.PrecioUnitario) / COUNT(*), 0) AS TicketPromedio
FROM Ventas v
JOIN Sucursales s ON s.SucursalID = v.SucursalID
GROUP BY s.Provincia, s.Nombre, s.Formato
ORDER BY Facturacion DESC;


-- Top 5 productos más vendidos por facturación
SELECT TOP 5
    p.Nombre,
    p.Categoria,
    SUM(v.Cantidad) AS UnidadesVendidas,
    ROUND(SUM(v.Cantidad * v.PrecioUnitario), 0) AS Facturacion,
    ROUND(SUM(v.Cantidad * (v.PrecioUnitario - v.CostoUnitario)), 0) AS Ganancia
FROM Ventas v
JOIN Productos p ON p.ProductoID = v.ProductoID
GROUP BY p.Nombre, p.Categoria
ORDER BY Facturacion DESC;


-- Facturación por categoría
SELECT
    p.Categoria,
    COUNT(*) AS CantidadVentas,
    SUM(v.Cantidad) AS UnidadesVendidas,
    ROUND(SUM(v.Cantidad * v.PrecioUnitario), 0) AS Facturacion,
    ROUND(SUM(v.Cantidad * (v.PrecioUnitario - v.CostoUnitario)) * 100.0 /
          SUM(v.Cantidad * v.PrecioUnitario), 1) AS MargenPct
FROM Ventas v
JOIN Productos p ON p.ProductoID = v.ProductoID
GROUP BY p.Categoria
ORDER BY Facturacion DESC;


-- Facturación mensual con variación respecto al mes anterior
SELECT
    c.NombreMes,
    c.Mes,
    ROUND(SUM(v.Cantidad * v.PrecioUnitario), 0) AS Facturacion,
    ROUND(LAG(SUM(v.Cantidad * v.PrecioUnitario)) 
        OVER (ORDER BY c.Mes), 0) AS FacturacionMesAnterior,
    ROUND(
        (SUM(v.Cantidad * v.PrecioUnitario) - 
         LAG(SUM(v.Cantidad * v.PrecioUnitario)) OVER (ORDER BY c.Mes)) * 100.0 /
         NULLIF(LAG(SUM(v.Cantidad * v.PrecioUnitario)) OVER (ORDER BY c.Mes), 0)
    , 1) AS VariacionPct
FROM Ventas v
JOIN Calendario c ON c.Fecha = v.Fecha
GROUP BY c.Mes, c.NombreMes
ORDER BY c.Mes;