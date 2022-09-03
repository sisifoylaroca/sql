/*
File 'belero_sql_facturacion.sql'
Benito Cuezva Rubio and Jorge Ara Arteaga
November 2020
*/
-- FUNCIONA
SELECT
    'Facturación CRM' AS Capitulo,
    fc.id_asunto AS CodAsunto,
    fc.asunto AS Asunto,
    s.id_subasunto AS CodSubasunto,
    fc.subasunto AS Subasunto,
    fc.f_factura AS FechaFactura,
    fc.neto_factura AS NetoFactura
FROM
    intranet.facturas_crm AS fc
LEFT JOIN intranet.subasuntos AS s ON
    fc.id_asunto_crm = s.id_asunto_crm
WHERE
    fc.id_asunto IS NOT NULL
    AND fc.f_factura >= '2017-01-01'
ORDER BY
    fc.id_asunto ASC,
    f_factura ASC ;

/*
File 'belero_sql_analitica.sql'
Benito Cuezva Rubio and Jorge Ara Arteaga
November 2020
*/

-- ANALÍTICA = PÉRDIDAS + AVERÍAS (y por ahora, solamente de herramienta inventariable)
-- ROTA
SELECT
    he.id_producto AS IdProducto,
    he.id_historico_estado_producto AS NumeroEstado,
    he.fh_cambio_estado_ini AS FechaHoraInicioEstado,
    he.fh_cambio_estado_fin AS FechaHoraFinEstado,
    he.id_estado AS CodEstado,
    e.estado AS Estado,
    e.estado_grupo AS EstadoGrupo,
    he.importe_analitico_cargo AS Cargo,
    he.importe_analitico_abono AS Abono,
    IFNULL(he.importe_analitico_cargo, 0) - IFNULL(he.importe_analitico_abono, 0) AS CosteNeto,
    he.id_albaran_analitico_cargo AS CodAlbaranCargo,
    -- aac.id_tipo_albaran_analitico AS CodTipoAlbaranCargo,
    NULL AS CodTipoAlbaranCargo,
    taac.tipo_albaran_analitico AS TipoAlbaranCargo,
    he.id_albaran_analitico_abono AS CodAlbaranAbono,
    aaa.id_tipo_albaran_analitico AS CodTipoAlbaranAbono,
    taaa.tipo_albaran_analitico AS TipoAlbaranAbono,
    he.cod_empleado_cargo AS CodEmpleadoCargo,
    he.cod_empleado_abono AS CodEmpleadoAbono,
    he.id_subasunto_cargo AS CodSubasuntoCargo,
    he.id_subasunto_abono AS CodSubasuntoAbono
FROM
    intranet.historico_estados AS he
LEFT JOIN intranet.estados AS e ON
    he.id_estado = e.id_estado
LEFT JOIN intranet.albaranes_analiticos AS aac ON
    aac.id_albaran_analitico = he.id_albaran_analitico_cargo
LEFT JOIN intranet.albaranes_analiticos AS aaa ON
    aaa.id_albaran_analitico = he.id_albaran_analitico_abono
LEFT JOIN intranet.tipos_albaranes_analiticos AS taac ON
    aac.id_tipo_albaran_analitico = taac.id_tipo_albaran_analitico
LEFT JOIN intranet.tipos_albaranes_analiticos AS taaa ON
    aaa.id_tipo_albaran_analitico = taaa.id_tipo_albaran_analitico
WHERE
    he.fh_cambio_estado_ini >= '2017-01-01'
ORDER BY
    he.id_producto ASC,
    he.id_historico_estado_producto ASC ;
    

/*
File 'belero_sql_compras.sql'
Benito Cuezva Rubio and Jorge Ara Arteaga
November 2020
*/

-- ROTA

SELECT
    'Compras' AS Capitulo,
    x.Origen,
    x.CodAsunto,
    x.Asunto,
    x.Fecha,
    ROUND(x.ImportePedido, 3) AS ImportePedido,
    ROUND(x.ImporteAlbaranado, 3) AS ImporteAlbaranado,
    x.GrupoAgrupacion,
    x.Familia,
    x.Subfamilia,
    x.CodProveedor
FROM
(
    -- FIRST BLOCK: MURANO ONLY (everything bought to providers)

    SELECT
    'Murano' AS Origen,
    m.CodAsunto,
    m.Asunto,
    m.Fecha,
    SUM(m.ImportePedido) AS ImportePedido,
    SUM(m.ImporteAlbaranado) AS ImporteAlbaranado,
    m.GrupoAgrupacion,
    m.Familia,
    m.Subfamilia,
    m.CodProveedor
FROM
    (
    SELECT
        mlpp.CodigoEmpresa AS CodEmpresa,
        mlpp.EjercicioPedido AS Ejercicio,
        mlpp.SeriePedido AS CodDelegacion,
        d.delegacion AS Delegacion,
        mlpp.NumeroPedido AS NumeroPedido,
        mlpp.FechaPedido AS FechaHoraPedido,
        STR_TO_DATE(CONCAT(SUBSTRING(mlpp.FechaPedido, 1, 8), 15), '%Y-%m-%d') AS Fecha,
        a.id_asunto AS CodAsunto,
        TRIM(mlpp.CodigoProyecto) AS Asunto,
        TRIM(TRAILING '\r\n' FROM mlpp.CodigodelProveedor) AS CodProveedor,
        mlpp.CodigoArticulo AS CodArticulo,
        ma.DescripcionArticulo AS Articulo,
        ma.TipoArticulo AS CodTipo,
        ma.CodigoFamilia AS CodFamilia,
        mff.Descripcion AS Familia,
        ma.CodigoSubfamilia AS CodSubfamilia,
        mfs.Descripcion AS Subfamilia,
        mg.id_agrupacion AS CodAgrupacion,
        mg.nombre AS Agrupacion,
        mg.grupo AS GrupoAgrupacion,
        IFNULL(mlpp.BaseImponible, 0) AS ImportePedido,
        IFNULL(mlap.BaseImponible, 0) AS ImporteAlbaranado
    FROM
        murano.murano_LineasPedidoProveedor AS mlpp
    LEFT JOIN murano.murano_Articulos AS ma ON
        ma.CodigoEmpresa = mlpp.CodigoEmpresa
        AND ma.CodigoArticulo = mlpp.CodigoArticulo
    LEFT JOIN murano.murano_Familias AS mfs ON
        mfs.CodigoEmpresa = ma.CodigoEmpresa
        AND mfs.CodigoFamilia = ma.CodigoFamilia
        AND mfs.CodigoSubfamilia = ma.CodigoSubfamilia
    LEFT JOIN murano.murano_Familias AS mff ON
        mff.CodigoEmpresa = mfs.CodigoEmpresa
        AND mff.CodigoFamilia = mfs.CodigoFamilia
        AND mff.CodigoSubfamilia = '**********'
    LEFT JOIN murano.murano_productos_agrupados AS mpa ON
        mpa.idfamilia = mff.idFamilia
        OR mpa.idSubfamilia = mfs.idFamilia
    LEFT JOIN murano.murano_agrupaciones AS mg ON
        mg.id_agrupacion = IFNULL(mpa.id_agrupacion, 16)
    LEFT JOIN murano.murano_LineasAlbaranProveedor AS mlap ON
        mlpp.LineasPosicion = mlap.LineaPedido
    LEFT JOIN intranet.delegaciones AS d ON
        d.cod_delegacion_compras = mlpp.SeriePedido
    LEFT JOIN intranet.asuntos AS a ON
        a.asunto = TRIM(mlpp.CodigoProyecto)
    WHERE
        mlpp.CodigoEmpresa = 1001
    ORDER BY
        mlpp.CodigoEmpresa,
        mlpp.EjercicioPedido,
        mlpp.SeriePedido,
        mlpp.NumeroPedido ) AS m
WHERE
    m.CodAsunto IS NOT NULL
GROUP BY
    m.CodAsunto,
    m.Fecha,
    m.GrupoAgrupacion,
    m.Familia,
    m.Subfamilia,
    m.CodProveedor

    UNION ALL

    -- SECOND BLOCK: INVENTARIO ONLY (to be removed from Murano)

    SELECT
    'Herramienta inventariable' AS Origen,
    i.CodAsuntoAnalitico AS CodAsunto,
    mc.Asunto,
    i.Fecha,
    -1 * SUM(ABS(i.Coste)) AS ImportePedido,
    -1 * SUM(ABS(i.Coste)) AS ImporteAlbaranado,
    i.TipoProducto AS GrupoAgrupacion,
    i.TipoProducto AS Familia,
    i.TipoProducto AS Subfamilia,
    NULL AS CodProveedor
FROM
    (
    SELECT
        DISTINCT(TRIM(mlpp.CodigoProyecto)) AS Asunto
    FROM
        murano.murano_LineasPedidoProveedor AS mlpp ) AS mc
INNER JOIN (
    SELECT
        mi.idProducto AS CodProducto,
        i.coste_neto AS Coste,
        tp.id_tipo_producto AS CodTipoProducto,
        tp.tipo_producto AS TipoProducto,
        tp.is_imputable_analitica AS EsImputableAnalitica,
        mi.fh_mov AS FechaHoraPrimerMovimiento,
        STR_TO_DATE(CONCAT(SUBSTRING(mi.fh_mov, 1, 8), 15), '%Y-%m-%d') AS Fecha,
        mi.id_asunto_orig AS CodAsunto,
        a1.asunto AS Asunto,
        IFNULL(a1.id_asunto_analitico_equiv, mi.id_asunto_orig) AS CodAsuntoAnalitico,
        a2.asunto AS AsuntoAnalitico
    FROM
        intranet.mov_inventario AS mi
    INNER JOIN (
        SELECT
            mi.idProducto AS CodProducto,
            MIN(mi.id_mov_idProducto) AS NumeroPrimerMovimiento
        FROM
            intranet.mov_inventario AS mi
        GROUP BY
            mi.idProducto
        ORDER BY
            mi.idProducto ) AS mi2 ON
        mi2.CodProducto = mi.idProducto
        AND mi2.NumeroPrimerMovimiento = mi.id_mov_idProducto
    LEFT JOIN intranet.inventario AS i ON
        mi.idProducto = i.idProducto
    LEFT JOIN intranet.productos AS p ON
        i.cod_producto = p.cod_producto
    LEFT JOIN intranet.tipos_productos AS tp ON
        p.id_tipo_producto = tp.id_tipo_producto
    LEFT JOIN intranet.asuntos AS a1 ON
        a1.id_asunto = mi.id_asunto_orig
    LEFT JOIN intranet.asuntos AS a2 ON
        a2.id_asunto = IFNULL(a1.id_asunto_analitico_equiv, mi.id_asunto_orig)
    LEFT JOIN intranet.empresas AS e ON
        a2.id_empresa = e.id_empresa
    WHERE
        tp.is_imputable_analitica = 0
        AND e.id_empresa = 1
    ORDER BY
        mi.idProducto ) AS i ON
    mc.Asunto = i.AsuntoAnalitico
GROUP BY
    i.CodAsuntoAnalitico,
    i.Fecha,
    i.TipoProducto

    UNION ALL

    -- THIRD BLOCK: GRANELES ONLY (to be removed from Murano)

    SELECT
    'Herramienta granel' AS Origen,
    mg.CodAsuntoAnalitico AS CodAsunto,
    mc.Asunto,
    mg.Fecha,
    -1 * SUM(ABS(mg.Coste)) AS ImportePedido,
    -1 * SUM(ABS(mg.Coste)) AS ImporteAlbaranado,
    mg.TipoProducto AS GrupoAgrupacion,
    mg.TipoProducto AS Familia,
    mg.TipoProducto AS Subfamilia,
    NULL AS CodProveedor
FROM
    (
    SELECT
        DISTINCT(TRIM(mlpp.CodigoProyecto)) AS Asunto
    FROM
        murano.murano_LineasPedidoProveedor AS mlpp
    WHERE
        mlpp.CodigoEmpresa = 1001 ) AS mc
INNER JOIN (
    SELECT
        mg.id_movimiento AS CodMovimiento,
        mg.fh_mov AS FechaHoraMovimiento,
        STR_TO_DATE(CONCAT(SUBSTRING(mg.fh_mov, 1, 8), 15), '%Y-%m-%d') AS Fecha,
        mg.cod_producto AS CodProducto,
        tp.id_tipo_producto AS CodTipoProducto,
        tp.tipo_producto AS TipoProducto,
        tp.is_imputable_analitica AS EsImputableAnalitica,
        -1 * ABS(mg.cantidad) AS CantidadTotalMovimiento,
        ABS(mg.coste_medio) AS CosteUnitario,
        mg.id_asunto_orig AS CodAsuntoMovimiento,
        mg.cod_empleado_orig AS CodEmpleadoOrigen,
        hc.id_historico_contrato AS CodHistoricoContrato,
        hc.f_alta AS FechaAltaContrato,
        hc.f_baja AS FechaBajaContrato,
        hp.id_hist_picaje AS CodHistoricoPicaje,
        hp.f_picaje AS FechaPicaje,
        hp.id_subasunto AS CodSubasunto,
        s.id_asunto AS CodAsuntoEmpleado,
        IF(mg.id_asunto_orig IS NOT NULL,
        mg.id_asunto_orig,
        s.id_asunto) AS CodAsunto,
        IFNULL(a1.id_asunto_analitico_equiv, a1.id_asunto) AS CodAsuntoAnalitico,
        a2.asunto AS AsuntoAnalitico,
        COUNT(*) OVER(PARTITION BY mg.id_movimiento) AS NumeroPicajesMovimiento,
        -1 * ABS(mg.cantidad) / COUNT(*) OVER(PARTITION BY mg.id_movimiento) AS CantidadTotalAsunto,
        -1 * ABS(mg.coste_medio) * ABS(mg.cantidad) / COUNT(*) OVER(PARTITION BY mg.id_movimiento) AS Coste
    FROM
        intranet.movimientos_granel AS mg
    LEFT JOIN intranet.historico_contratos AS hc ON
        mg.cod_empleado_orig = hc.cod_empleado
        AND mg.id_asunto_orig IS NULL
        AND (DATE(mg.fh_mov) >= hc.f_alta
            AND DATE(mg.fh_mov) <= IFNULL(hc.f_baja, DATE(NOW() + INTERVAL 100 YEAR)))
    LEFT JOIN intranet.historico_picajes AS hp ON
        hc.id_historico_contrato = hp.id_historico_contrato
            AND hp.f_picaje = DATE(mg.fh_mov)
        LEFT JOIN intranet.subasuntos AS s ON
            s.id_subasunto = hp.id_subasunto
        LEFT JOIN intranet.productos AS p ON
            mg.cod_producto = p.cod_producto
        LEFT JOIN intranet.tipos_productos AS tp ON
            p.id_tipo_producto = tp.id_tipo_producto
        LEFT JOIN intranet.asuntos AS a1 ON
            a1.id_asunto = IF(mg.id_asunto_orig IS NOT NULL,
            mg.id_asunto_orig,
            s.id_asunto)
        LEFT JOIN intranet.asuntos AS a2 ON
            a2.id_asunto = IFNULL(a1.id_asunto_analitico_equiv, a1.id_asunto)
        WHERE
            tp.is_imputable_analitica = 0
        ORDER BY
            mg.id_movimiento ASC ) AS mg ON
    mc.Asunto = mg.AsuntoAnalitico
GROUP BY
    mg.CodAsuntoAnalitico,
    mg.Fecha,
    mg.TipoProducto

    UNION ALL

    -- FOURTH BLOCK: ANALITICA ONLY (to be added to Murano)

    SELECT
        'Analitica' AS Origen,
        a.CodAsuntoAnalitico AS CodAsunto,
        a.AsuntoAnalitico AS Asunto,
        a.Fecha,
        SUM(a.Coste) AS ImportePedido,
        SUM(a.Coste) AS ImporteAlbaranado,
        a.TipoProducto AS GrupoAgrupacion,
        a.TipoProducto AS Familia,
        a.TipoProducto AS Sbufamilia,
        NULL AS CodProveedor
    FROM
    (
        SELECT
            mg.CodProducto,
            mg.CantidadTotalAsunto * mg.CosteUnitario AS Coste,
            tp.id_tipo_producto AS CodTipoProducto,
            tp.tipo_producto AS TipoProducto,
            tp.is_imputable_analitica AS EsImputableAnalitica,
            mg.FechaHoraMovimiento,
            CONCAT(SUBSTRING(mg.FechaHoraMovimiento, 1, 8), 15) AS Fecha,
            mg.CodAsunto,
            a1.asunto AS Asunto,
            IFNULL(a1.id_asunto_analitico_equiv, mg.CodAsunto) AS CodAsuntoAnalitico,
            a2.asunto AS AsuntoAnalitico
        FROM 
        (
            SELECT 
                mg.id_movimiento AS CodMovimiento,
                mg.fh_mov AS FechaHoraMovimiento,
                mg.cod_producto AS CodProducto,
                ABS(mg.cantidad) AS CantidadTotalMovimiento,
                ABS(mg.coste_medio) AS CosteUnitario,
                mg.id_asunto_dest AS CodAsuntoMovimiento,
                mg.cod_empleado_dest AS CodEmpleado,
                hc.id_historico_contrato AS CodHistoricoContrato,
                hc.f_alta AS FechaAltaContrato,
                hc.f_baja AS FechaBajaContrato,
                hp.id_hist_picaje AS CodHistoricoPicaje,
                hp.f_picaje AS FechaPicaje,
                hp.id_subasunto AS CodSubasunto,
                a.id_asunto AS CodAsuntoEmpleado,
                IF(mg.id_asunto_dest IS NOT NULL, mg.id_asunto_dest, a.id_asunto) AS CodAsunto,
                COUNT(*) OVER(PARTITION BY mg.id_movimiento) AS NumeroPicajesMovimiento,
                ABS(mg.cantidad) / COUNT(*) OVER(PARTITION BY mg.id_movimiento) AS CantidadTotalAsunto
            FROM intranet.movimientos_granel AS mg
            LEFT JOIN intranet.historico_contratos AS hc ON mg.cod_empleado_dest = hc.cod_empleado AND mg.id_asunto_dest IS NULL AND (DATE(mg.fh_mov) >= hc.f_alta AND DATE(mg.fh_mov) <= IFNULL(hc.f_baja, DATE(NOW() + INTERVAL 100 YEAR)))
            LEFT JOIN intranet.historico_picajes AS hp ON hc.id_historico_contrato = hp.id_historico_contrato AND hp.f_picaje = DATE(mg.fh_mov)
            LEFT JOIN intranet.subasuntos AS s ON s.id_subasunto = hp.id_subasunto
            LEFT JOIN intranet.asuntos AS a ON s.id_asunto = a.id_asunto

            UNION ALL

            SELECT
    mg.id_movimiento AS CodMovimiento,
    mg.fh_mov AS FechaHoraMovimiento,
    mg.cod_producto AS CodProducto,
    -1 * ABS(mg.cantidad) AS CantidadTotalMovimiento,
    ABS(mg.coste_medio) AS CosteUnitario,
    mg.id_asunto_orig AS CodAsuntoMovimiento,
    mg.cod_empleado_orig AS CodEmpleado,
    hc.id_historico_contrato AS CodHistoricoContrato,
    hc.f_alta AS FechaAltaContrato,
    hc.f_baja AS FechaBajaContrato,
    hp.id_hist_picaje AS CodHistoricoPicaje,
    hp.f_picaje AS FechaPicaje,
    hp.id_subasunto AS CodSubasunto,
    a.id_asunto AS CodAsuntoEmpleado,
    IF(mg.id_asunto_orig IS NOT NULL,
    mg.id_asunto_orig,
    a.id_asunto) AS CodAsunto,
    COUNT(*) OVER(PARTITION BY mg.id_movimiento) AS NumeroPicajesMovimiento,
    -1 * ABS(mg.cantidad) / COUNT(*) OVER(PARTITION BY mg.id_movimiento) AS CantidadTotalAsunto
FROM
    intranet.movimientos_granel AS mg
LEFT JOIN intranet.historico_contratos AS hc ON
    mg.cod_empleado_orig = hc.cod_empleado
    AND mg.id_asunto_orig IS NULL
    AND (DATE(mg.fh_mov) >= hc.f_alta
        AND DATE(mg.fh_mov) <= IFNULL(hc.f_baja, DATE(NOW() + INTERVAL 100 YEAR)))
LEFT JOIN intranet.historico_picajes AS hp ON
    hc.id_historico_contrato = hp.id_historico_contrato
    AND hp.f_picaje = DATE(mg.fh_mov)
LEFT JOIN intranet.subasuntos AS s ON
    s.id_subasunto = hp.id_subasunto
LEFT JOIN intranet.asuntos AS a ON
    s.id_asunto = a.id_asunto ) AS mg
LEFT JOIN intranet.asuntos AS a1 ON
    a1.id_asunto = mg.CodAsunto
LEFT JOIN intranet.asuntos AS a2 ON
    a2.id_asunto = IFNULL(a1.id_asunto_analitico_equiv, mg.CodAsunto)
LEFT JOIN intranet.empresas AS e ON
    a2.id_empresa = e.id_empresa
LEFT JOIN intranet.productos AS p ON
    p.cod_producto = mg.CodProducto
LEFT JOIN intranet.tipos_productos AS tp ON
    p.id_tipo_producto = tp.id_tipo_producto
WHERE
    a2.id_empresa = 1
    AND tp.is_imputable_analitica = 1 ) AS a
GROUP BY
    a.CodAsuntoAnalitico,
    a.Fecha,
    a.TipoProducto ) AS x
WHERE
    x.CodAsunto IS NOT NULL
    AND x.Fecha >= '2017-01-01'
ORDER BY
    x.CodAsunto ASC,
    x.Fecha ASC ;


/*
File 'belero_sql_horas.sql'
Benito Cuezva Rubio and Jorge Ara Arteaga
November 2020
*/
-- ROTA

SELECT
    'Horas' AS Capitulo,
    h.CodDesglosePicaje,
    h.CodHistoricoPicaje,
    h.CodTipoHora,
    h.Horas,
    ROUND(h.PrecioHoraCondiciones, 3) AS PrecioHoraCondiciones,
    ROUND(h.PrecioHoraExcel, 3) AS PrecioHoraExcel,
    ROUND(IF(h.PrecioHoraExcel IS NOT NULL AND h.PrecioHoraExcel > 0, h.PrecioHoraExcel, h.PrecioHoraCondiciones), 3) AS PrecioHoraCombinado,
    h.CodEmpresa,
    h.Empresa
FROM
    (
    SELECT
        hp.f_picaje AS FechaPicaje,
        EXTRACT(YEAR_MONTH FROM hp.f_picaje) AS AñoMesFechaPicaje,
        hp.id_historico_contrato AS CodHistoricoContrato,
        a.id_asunto AS CodAsunto,
        a.id_asunto_analitico_equiv AS CodAsuntoAnalitico,
        a.asunto AS Asunto,
        hp.id_subasunto AS CodSubasunto,
        s.subasunto AS Subasunto,
        dp.id_desglose_picaje AS CodDesglosePicaje,
        dp.id_historico_picaje AS CodHistoricoPicaje,
        dp.id_tipo_hora AS CodTipoHora,
        ath.agrupacion_precio AS GrupoHora,
        dp.horas AS Horas,
        hc.cod_empleado AS CodEmpleado,
        IF(hc.d_i = 'I',
        hc.d_i,
        'D') AS TipoEmpleado,
        IF(ath.agrupacion_precio = 'Convencionales',
        IF(hcc.PrecioHoraNormalContrato IS NOT NULL,
        hcc.PrecioHoraNormalContrato,
        IF(hcc.PrecioHoraNormalContratoAnterior IS NOT NULL,
        hcc.PrecioHoraNormalContratoAnterior,
        hcd.PrecioHoraNormalDefecto)),
        IF(ath.agrupacion_precio = 'Extras',
        IF(hcc.PrecioHoraExtraNormalContrato IS NOT NULL,
        hcc.PrecioHoraExtraNormalContrato,
        IF(hcc.PrecioHoraExtraNormalContratoAnterior IS NOT NULL,
        hcc.PrecioHoraExtraNormalContratoAnterior,
        hcd.PrecioHoraExtraNormalDefecto)),
        IF(ath.agrupacion_precio = 'Festivas',
        IF(hcc.PrecioHoraExtraFestivaContrato IS NOT NULL,
        hcc.PrecioHoraExtraFestivaContrato,
        IF(hcc.PrecioHoraExtraFestivaContratoAnterior IS NOT NULL,
        hcc.PrecioHoraExtraFestivaContratoAnterior,
        hcd.PrecioHoraExtraFestivaDefecto)),
        0))) AS PrecioHoraCondiciones,
        IF(ath.agrupacion_precio = 'Convencionales',
        fe.PrecioHoraNormalExcel,
        IF(ath.agrupacion_precio = 'Extras',
        fe.PrecioHoraExtraNormalExcel,
        IF(ath.agrupacion_precio = 'Festivas',
        fe.PrecioHoraExtraFestivaExcel,
        0))) AS PrecioHoraExcel,
        a.id_empresa AS CodEmpresa,
        e.empresa AS Empresa
    FROM
        intranet.desglose_picaje AS dp
    LEFT JOIN intranet.historico_picajes AS hp ON
        dp.id_historico_picaje = hp.id_hist_picaje
    LEFT JOIN intranet.subasuntos AS s ON
        hp.id_subasunto = s.id_subasunto
    LEFT JOIN intranet.asuntos AS a ON
        a.id_asunto = s.id_asunto
    LEFT JOIN intranet.empresas AS e ON
        a.id_empresa = e.id_empresa
    LEFT JOIN intranet.tipos_horas AS th ON
        dp.id_tipo_hora = th.id_tipo_hora
    LEFT JOIN intranet.agrupacion_tipos_horas AS ath ON
        th.id_agrupacion_tipo_hora = ath.id_agrupacion_horas
    LEFT JOIN intranet.historico_contratos AS hc ON
        hc.id_historico_contrato = hp.id_historico_contrato
    LEFT JOIN (
        -- CONDICIONES CONTRATOS
        SELECT
            hcc.id_historico_contrato AS CodHistoricoContrato,
            hcc.f_ini_condicion AS FechaInicioContrato,
            hcc.f_fin_condicion AS FechaFinContrato,
            hcc.coste_hn AS PrecioHoraNormalContrato,
            hcc.coste_hen AS PrecioHoraExtraNormalContrato,
            hcc.coste_hef AS PrecioHoraExtraFestivaContrato,
            LAG(hcc.f_ini_condicion, 1) OVER (PARTITION BY hcc.id_historico_contrato
        ORDER BY
            hcc.f_ini_condicion) AS FechaInicioContratoAnterior,
            LAG(hcc.f_fin_condicion, 1) OVER (PARTITION BY hcc.id_historico_contrato
        ORDER BY
            hcc.f_ini_condicion) AS FechaFinContratoAnterior,
            LAG(hcc.coste_hn, 1) OVER (PARTITION BY hcc.id_historico_contrato
        ORDER BY
            hcc.f_ini_condicion) AS PrecioHoraNormalContratoAnterior,
            LAG(hcc.coste_hen, 1) OVER (PARTITION BY hcc.id_historico_contrato
        ORDER BY
            hcc.f_ini_condicion) AS PrecioHoraExtraNormalContratoAnterior,
            LAG(hcc.coste_hef, 1) OVER (PARTITION BY hcc.id_historico_contrato
        ORDER BY
            hcc.f_ini_condicion) AS PrecioHoraExtraFestivaContratoAnterior
        FROM
            intranet.historico_contratos_condiciones AS hcc
        ORDER BY
            hcc.id_historico_contrato ASC,
            hcc.f_ini_condicion ASC ) AS hcc ON
        hcc.CodHistoricoContrato = hc.id_historico_contrato
        AND ((hp.f_picaje >= hcc.FechaInicioContrato)
            AND (hp.f_picaje <= IFNULL(hcc.FechaFinContrato, DATE(NOW() + INTERVAL 100 YEAR))))
    LEFT JOIN (
        -- CONDICIONES DEFECTO
        SELECT
            IFNULL(hcd.d_i, 'D') AS TipoEmpleado,
            hcd.f_inicio AS FechaInicioPeriodoDefecto,
            hcd.f_fin AS FechaFinPeriodoDefecto,
            hcd.coste_hn AS PrecioHoraNormalDefecto,
            hcd.coste_hen AS PrecioHoraExtraNormalDefecto,
            hcd.coste_hef AS PrecioHoraExtraFestivaDefecto
        FROM
            intranet.historico_condicionesPeriodos_defecto AS hcd ) AS hcd ON
        hcd.TipoEmpleado = IF(hc.d_i = 'I',
        hc.d_i,
        'D')
        AND ((hp.f_picaje >= hcd.FechaInicioPeriodoDefecto)
            AND (hp.f_picaje <= IFNULL(hcd.FechaFinPeriodoDefecto, DATE(NOW() + INTERVAL 100 YEAR))))
    LEFT JOIN (
        -- FICHEROS EXCEL GESTORÍA
        SELECT
            fe.CodEmpleado,
            fe.AñoMesFechaFicheroExcel,
            fe.AñoMesFechaPicaje,
            AVG(fe.PrecioHoraNormalExcel) AS PrecioHoraNormalExcel,
            AVG(fe.PrecioHoraExtraNormalExcel) AS PrecioHoraExtraNormalExcel,
            AVG(fe.PrecioHoraExtraFestivaExcel) AS PrecioHoraExtraFestivaExcel
        FROM
            (
            SELECT
                IFNULL(e.cod_empleado, dfe.cod_empleado) AS CodEmpleado,
                dfe.cod_empleado AS CodEmpleadoGestoria,
                fe.FechaRealFicheroExcel,
                EXTRACT(YEAR_MONTH FROM fe.FechaRealFicheroExcel) AS AñoMesFechaFicheroExcel,
                EXTRACT(YEAR_MONTH FROM fe.FechaRealFicheroExcel - INTERVAL 1 MONTH) AS AñoMesFechaPicaje,
                IF(dfe.d_i = 'I',
                dfe.d_i,
                'D') AS TipoEmpleado,
                dfe.coste_hn AS PrecioHoraNormalExcel,
                dfe.coste_hen AS PrecioHoraExtraNormalExcel,
                dfe.coste_hef AS PrecioHoraExtraFestivaExcel
            FROM
                (
                SELECT
                    MAX(fe.id_fichero) AS CodFicheroExcel,
                    CAST(fe.fecha AS DATE) AS FechaRealFicheroExcel
                FROM
                    intranet.ficheros_excel AS fe
                INNER JOIN (
                    SELECT
                        MAX(fe.fecha) AS FechaRealFicheroExcel
                    FROM
                        intranet.ficheros_excel AS fe
                    WHERE
                        fe.id_tipo_fichero = 4
                        AND fe.nombre_fichero LIKE '%MEISA%'
                    GROUP BY
                        EXTRACT(YEAR_MONTH FROM fe.fecha)
                    ORDER BY
                        fe.fecha ASC ) AS fe2 ON
                    fe.fecha = fe2.FechaRealFicheroExcel
                GROUP BY
                    fe.fecha ) AS fe
            LEFT JOIN intranet.desglose_ficheros_excel AS dfe ON
                fe.CodFicheroExcel = dfe.id_fichero
            LEFT JOIN intranet.empleados AS e ON
                e.cod_RRHH = dfe.cod_empleado
            WHERE
                dfe.cod_empleado IS NOT NULL
            ORDER BY
                e.cod_empleado ASC,
                fe.FechaRealFicheroExcel ASC ) AS fe
        GROUP BY
            fe.CodEmpleado,
            fe.AñoMesFechaFicheroExcel
        ORDER BY
            fe.CodEmpleado ASC,
            fe.AñoMesFechaFicheroExcel ) AS fe ON
        fe.CodEmpleado = hc.cod_empleado
        AND EXTRACT(YEAR_MONTH FROM hp.f_picaje) = fe.AñoMesFechaPicaje
    WHERE
        a.id_empresa = 1
        AND hp.f_picaje >= '2017-01-01'
    ORDER BY
        hp.f_picaje ASC,
        hc.cod_empleado ASC ) AS h
ORDER BY
    h.CodDesglosePicaje ASC ;

/*
File 'belero_sql_hta_granel.sql'
Benito Cuezva Rubio and Jorge Ara Arteaga
November 2020
*/
-- Rota


SELECT
    'Herramienta granel' AS Capitulo,
    mg.CodAsunto,
    mg.CodProducto,
    mg.Fecha,
    mg.ComputaComoUso,
    mg.EstadoProducto,
    mg.EstadoGrupo,
    ROUND(SUM(mg.CosteAmortizacion), 3) AS CosteAmortizacion
FROM
(
    SELECT
        IFNULL(a1.id_asunto_analitico_equiv, a1.id_asunto) AS CodAsunto,
        IFNULL(a2.id_asunto_analitico_equiv, a2.id_asunto) AS CodAsunto2,
        mg.CodProducto,
        mg.FechaHoraMovimiento,
        CONCAT(SUBSTRING(mg.FechaHoraMovimiento, 1, 8), 15) AS Fecha,
        mg.CantidadTotalAsunto,
        mg.CosteUnitario,
        IF(IFNULL(a2.id_asunto_analitico_equiv, a2.id_asunto) IN (4504, 4505, 4506, 10730), 0, 1) AS ComputaComoUso,
        IF(IFNULL(a2.id_asunto_analitico_equiv, a2.id_asunto) = 4504, 'Perdido', IF(IFNULL(a2.id_asunto_analitico_equiv, a2.id_asunto) = 4505, 'Robado', IF(IFNULL(a2.id_asunto_analitico_equiv, a2.id_asunto) = 4506, 'Deteriorado', IF(IFNULL(a2.id_asunto_analitico_equiv, a2.id_asunto) = 10730, 'Repuesto', 'Usado')))) AS EstadoProducto,
        IF(IFNULL(a2.id_asunto_analitico_equiv, a2.id_asunto) = 4504, 'Perdido', IF(IFNULL(a2.id_asunto_analitico_equiv, a2.id_asunto) = 4505, 'Robado', IF(IFNULL(a2.id_asunto_analitico_equiv, a2.id_asunto) = 4506, 'Deteriorado', IF(IFNULL(a2.id_asunto_analitico_equiv, a2.id_asunto) = 10730, 'Repuesto', 'Usado')))) AS EstadoGrupo,
        IF(mg.CantidadTotalAsunto >= 0 OR IFNULL(a2.id_asunto_analitico_equiv, a2.id_asunto) IN (4504, 4505, 4506, 10730), 0.5 * mg.CosteUnitario * ABS(mg.CantidadTotalAsunto), 0) AS CosteAmortizacion
    FROM 
    (
        SELECT 
            mg.id_movimiento AS CodMovimiento,
            mg.fh_mov AS FechaHoraMovimiento,
            mg.cod_producto AS CodProducto,
            ABS(mg.cantidad) AS CantidadTotalMovimiento,
            ABS(mg.coste_medio) AS CosteUnitario,
            mg.id_asunto_dest AS CodAsuntoMovimiento,
            mg.cod_empleado_dest AS CodEmpleado,
            hc.id_historico_contrato AS CodHistoricoContrato,
            hc.f_alta AS FechaAltaContrato,
            hc.f_baja AS FechaBajaContrato,
            hp.id_hist_picaje AS CodHistoricoPicaje,
            hp.f_picaje AS FechaPicaje,
            hp.id_subasunto AS CodSubasunto,
            a.id_asunto AS CodAsuntoEmpleado,
            IF(mg.id_asunto_dest IS NOT NULL, mg.id_asunto_dest, a.id_asunto) AS CodAsunto,
            mg.id_asunto_orig AS CodAsunto2,
            COUNT(*) OVER(PARTITION BY mg.id_movimiento) AS NumeroPicajesMovimiento,
            ABS(mg.cantidad) / COUNT(*) OVER(PARTITION BY mg.id_movimiento) AS CantidadTotalAsunto
        FROM intranet.movimientos_granel AS mg
        LEFT JOIN intranet.historico_contratos AS hc ON mg.cod_empleado_dest = hc.cod_empleado AND mg.id_asunto_dest IS NULL AND (DATE(mg.fh_mov) >= hc.f_alta AND DATE(mg.fh_mov) <= IFNULL(hc.f_baja, DATE(NOW() + INTERVAL 100 YEAR)))
        LEFT JOIN intranet.historico_picajes AS hp ON hc.id_historico_contrato = hp.id_historico_contrato AND hp.f_picaje = DATE(mg.fh_mov)
        LEFT JOIN intranet.subasuntos AS s ON s.id_subasunto = hp.id_subasunto
        LEFT JOIN intranet.asuntos AS a ON s.id_asunto = a.id_asunto

        UNION ALL

        SELECT
    mg.id_movimiento AS CodMovimiento,
    mg.fh_mov AS FechaHoraMovimiento,
    mg.cod_producto AS CodProducto,
    -1 * ABS(mg.cantidad) AS CantidadTotalMovimiento,
    ABS(mg.coste_medio) AS CosteUnitario,
    mg.id_asunto_orig AS CodAsuntoMovimiento,
    mg.cod_empleado_orig AS CodEmpleado,
    hc.id_historico_contrato AS CodHistoricoContrato,
    hc.f_alta AS FechaAltaContrato,
    hc.f_baja AS FechaBajaContrato,
    hp.id_hist_picaje AS CodHistoricoPicaje,
    hp.f_picaje AS FechaPicaje,
    hp.id_subasunto AS CodSubasunto,
    a.id_asunto AS CodAsuntoEmpleado,
    IF(mg.id_asunto_orig IS NOT NULL,
    mg.id_asunto_orig,
    a.id_asunto) AS CodAsunto,
    mg.id_asunto_dest AS CodAsunto2,
    COUNT(*) OVER(PARTITION BY mg.id_movimiento) AS NumeroPicajesMovimiento,
    -1 * ABS(mg.cantidad) / COUNT(*) OVER(PARTITION BY mg.id_movimiento) AS CantidadTotalAsunto
FROM
    intranet.movimientos_granel AS mg
LEFT JOIN intranet.historico_contratos AS hc ON
    mg.cod_empleado_orig = hc.cod_empleado
    AND mg.id_asunto_orig IS NULL
    AND (DATE(mg.fh_mov) >= hc.f_alta
        AND DATE(mg.fh_mov) <= IFNULL(hc.f_baja, DATE(NOW() + INTERVAL 100 YEAR)))
LEFT JOIN intranet.historico_picajes AS hp ON
    hc.id_historico_contrato = hp.id_historico_contrato
    AND hp.f_picaje = DATE(mg.fh_mov)
LEFT JOIN intranet.subasuntos AS s ON
    s.id_subasunto = hp.id_subasunto
LEFT JOIN intranet.asuntos AS a ON
    s.id_asunto = a.id_asunto ) AS mg
LEFT JOIN intranet.asuntos AS a1 ON
    mg.CodAsunto = a1.id_asunto
LEFT JOIN intranet.asuntos AS a2 ON
    mg.CodAsunto2 = a2.id_asunto
LEFT JOIN intranet.productos AS p ON
    p.cod_producto = mg.CodProducto
WHERE
    a1.id_empresa = 1
    AND p.id_tipo_producto = 2
    AND mg.FechaHoraMovimiento >= '2017-01-01'
ORDER BY
    IFNULL(a1.id_asunto_analitico_equiv, a1.id_asunto) ASC,
    mg.CodProducto ASC,
    mg.FechaHoraMovimiento ASC ) AS mg
GROUP BY
    mg.CodAsunto,
    mg.CodProducto,
    mg.Fecha,
    mg.ComputaComoUso
ORDER BY
    mg.CodAsunto ASC,
    mg.CodProducto ASC,
    mg.Fecha ASC,
    mg.ComputaComoUso ASC ;

/*
File 'belero_sql_hta_inventariable.sql'
Benito Cuezva Rubio and Jorge Ara Arteaga
November 2020
*/
-- ROTA


-- Cost at each date
 SELECT
    mi.Capitulo,
    mi.IdProducto,
    mi.CodProducto,
    mi.Fecha,
    mi.CodAsunto,
    IFNULL(mi.ComputaComoUso, 1) AS ComputaComoUso,
    IFNULL(mi.EstadoFinal, 'Usado') AS Estado,
    IFNULL(mi.EstadoGrupoFinal, 'Usado') AS EstadoGrupo,
    ROUND(mi.CosteAmortizacionDiario * mi.DiasEnRegistroAmortizables + IF(mi.ComputaComoUso = 0, mi.CosteTotalResidual, 0), 3) AS CosteAmortizacion
FROM
    (
    SELECT
        f.Fecha,
        mi.*,
        IF (
        -- One movement only
(mi.EsPrimerMovimiento = 1)
        AND (mi.EsUltimoMovimiento = 1),
        IF (
        -- Not available (one date only)
 mi.ComputaComoUso = 0,
        mi.DiasAmortizacionConfiguracion,
        -- Is available (multiple dates)
 IF (
        -- To be paid off
 mi.EnAmortizacionAhora = 1,
        IF(EXTRACT(YEAR_MONTH FROM f.Fecha) = EXTRACT(YEAR_MONTH FROM mi.FechaHoraInicioMovimiento),
        DATEDIFF(LAST_DAY(f.Fecha), mi.FechaHoraInicioMovimiento),
        IF(EXTRACT(YEAR_MONTH FROM f.Fecha) = EXTRACT(YEAR_MONTH FROM NOW()),
        DAY(NOW()),
        DAY(LAST_DAY(f.Fecha)))),
        -- Already paid off
 IF(EXTRACT(YEAR_MONTH FROM f.Fecha) < EXTRACT(YEAR_MONTH FROM mi.FechaHoraFinAmortizacion),
        IF(EXTRACT(YEAR_MONTH FROM f.Fecha) = EXTRACT(YEAR_MONTH FROM mi.FechaHoraInicioMovimiento),
        DATEDIFF(LAST_DAY(f.Fecha), mi.FechaHoraInicioMovimiento),
        DAY(LAST_DAY(f.Fecha))),
        IF(EXTRACT(YEAR_MONTH FROM f.Fecha) = EXTRACT(YEAR_MONTH FROM mi.FechaHoraFinAmortizacion),
        DAY(mi.FechaHoraFinAmortizacion),
        0)) ) ),
        -- Several movements
 IF (
        -- Last movement, which is not available
 mi.ComputaComoUso = 0,
        IF (
        -- To be paid off
 mi.EnAmortizacionAhora = 1,
        DATEDIFF(mi.FechaHoraFinAmortizacion, mi.FechaHoraInicioMovimiento),
        -- Already paid off
 IF(mi.FechaHoraInicioMovimiento <= mi.FechaHoraFinAmortizacion,
        DATEDIFF(mi.FechaHoraFinAmortizacion, mi.FechaHoraInicioMovimiento),
        0) ),
        -- Any movement (be it the last or not), which are all available
 IF (
        -- Dates inside pay off period
 EXTRACT(YEAR_MONTH FROM f.Fecha) < EXTRACT(YEAR_MONTH FROM mi.FechaHoraFinAmortizacion),
        IF(EXTRACT(YEAR_MONTH FROM f.Fecha) = EXTRACT(YEAR_MONTH FROM mi.FechaHoraInicioMovimiento),
        IF(EXTRACT(YEAR_MONTH FROM f.Fecha) = EXTRACT(YEAR_MONTH FROM mi.FechaHoraFinMovimiento),
        DATEDIFF(mi.FechaHoraFinMovimiento, mi.FechaHoraInicioMovimiento),
        DATEDIFF(LAST_DAY(f.Fecha), mi.FechaHoraInicioMovimiento)),
        IF(EXTRACT(YEAR_MONTH FROM f.Fecha) = EXTRACT(YEAR_MONTH FROM mi.FechaHoraFinMovimiento),
        DAY(mi.FechaHoraFinMovimiento),
        IF(EXTRACT(YEAR_MONTH FROM f.Fecha) = EXTRACT(YEAR_MONTH FROM NOW()),
        DAY(NOW()),
        DAY(LAST_DAY(f.Fecha))))),
        IF (
        -- Pay off end date
 EXTRACT(YEAR_MONTH FROM f.Fecha) = EXTRACT(YEAR_MONTH FROM mi.FechaHoraFinAmortizacion),
        IF (
        -- mi.FechaHoraInicioMovimiento year and month are the same as f.Fecha's
 EXTRACT(YEAR_MONTH FROM f.Fecha) = EXTRACT(YEAR_MONTH FROM mi.FechaHoraInicioMovimiento),
        IF(DATE(mi.FechaHoraInicioMovimiento) >= DATE(mi.FechaHoraFinAmortizacion),
        0,
        IF(DATE(mi.FechaHoraFinMovimiento) <= DATE(mi.FechaHoraFinAmortizacion),
        DATEDIFF(mi.FechaHoraFinMovimiento, mi.FechaHoraInicioMovimiento),
        DATEDIFF(mi.FechaHoraFinAmortizacion, mi.FechaHoraInicioMovimiento))),
        IF (
        -- mi.FechaHoraInicioMovimiento year and month are sooner than f.Fecha's
 EXTRACT(YEAR_MONTH FROM mi.FechaHoraInicioMovimiento) < EXTRACT(YEAR_MONTH FROM f.Fecha),
        IF(mi.FechaHoraFinMovimiento IS NULL
        OR EXTRACT(YEAR_MONTH FROM mi.FechaHoraFinMovimiento) > EXTRACT(YEAR_MONTH FROM f.Fecha),
        DAY(mi.FechaHoraFinAmortizacion),
        IF(EXTRACT(YEAR_MONTH FROM mi.FechaHoraFinMovimiento) < EXTRACT(YEAR_MONTH FROM f.Fecha),
        0,
        IF(DATE(mi.FechaHoraFinMovimiento) >= DATE(mi.FechaHoraFinAmortizacion),
        DAY(mi.FechaHoraFinAmortizacion),
        DAY(mi.FechaHoraFinMovimiento)))),
        -- mi.FechaHoraInicioMovimiento year and month are later than f.Fecha's
 0 ) ),
        -- Dates out of pay off period
 0 ) ) ) ) AS DiasEnRegistroAmortizables
    FROM
        (
        SELECT
            DISTINCT(STR_TO_DATE(CONCAT(SUBSTRING(f.fecha, 1, 8), 15), '%Y-%m-%d')) AS Fecha
        FROM
            intranet.fechas AS f
        WHERE
            f.fecha <= NOW() ) AS f
    LEFT JOIN (
        -- Cost of each movements
        SELECT
            *,
            IF(mi.EnAmortizacionAhora = 1
                AND mi.EsUltimoMovimiento = 1
                AND mi.ComputaComoUso = 0,
                TIMESTAMPDIFF(SECOND, mi.FechaHoraInicioMovimiento, mi.FechaHoraFinAmortizacion) / (3600 * 24),
                IF(mi.FechaHoraFinMovimiento <= mi.FechaHoraFinAmortizacion
                    OR (mi.EnAmortizacionAhora = 1
                        AND mi.EsUltimoMovimiento = 1),
                    mi.DiasEnMovimiento,
                    IF(mi.FechaHoraInicioMovimiento <= mi.FechaHoraFinAmortizacion,
                    TIMESTAMPDIFF(SECOND, mi.FechaHoraInicioMovimiento, mi.FechaHoraFinAmortizacion) / (3600 * 24),
                    0))) AS DiasEnMovimientoAmortizables
        FROM
            (
            -- Days in each movement
            SELECT
                'Herramienta inventariable' AS Capitulo,
                mi.idProducto AS IdProducto,
                i.cod_producto AS CodProducto,
                p.id_tipo_producto AS CodTipoProducto,
                i.coste_neto AS CosteUnitario,
                MIN(mi.fh_mov) OVER(PARTITION BY mi.idProducto) AS FechaHoraCompra,
                MAX(mi.fh_mov) OVER(PARTITION BY mi.idProducto) AS FechaHoraInicioUltimoMovimiento,
                MIN(mi.id_mov_idProducto) OVER(PARTITION BY mi.idProducto) AS NumeroPrimerMovimiento,
                MAX(mi.id_mov_idProducto) OVER(PARTITION BY mi.idProducto) AS NumeroUltimoMovimiento,
                ca.dias_amortizacion AS DiasAmortizacionConfiguracion,
                ca.porcentaje_residual AS PorcentajeResidualConfiguracion,
                1 - ca.porcentaje_residual AS PorcentajeAmortizableConfiguracion,
                (1 - ca.porcentaje_residual) * i.coste_neto AS CosteTotalAmortizable,
                ca.porcentaje_residual * i.coste_neto AS CosteTotalResidual,
                ((1 - ca.porcentaje_residual) * i.coste_neto) / ca.dias_amortizacion AS CosteAmortizacionDiario,
                MIN(mi.fh_mov) OVER(PARTITION BY mi.idProducto) + INTERVAL ca.dias_amortizacion DAY AS FechaHoraFinAmortizacion,
                NOW() AS Ahora,
                IF(MIN(mi.fh_mov) OVER(PARTITION BY mi.idProducto) + INTERVAL ca.dias_amortizacion DAY > NOW(),
                1,
                0) AS EnAmortizacionAhora,
                mi.id_mov_idProducto AS NumeroMovimiento,
                mi.fh_mov AS FechaHoraInicioMovimiento,
                mi.fh_mov_fin AS FechaHoraFinMovimiento,
                mi.id_asunto_orig AS CodAsuntoOrigen,
                cod_empleado_orig AS CodEmpleadoOrigen,
                mi.id_asunto_dest AS CodAsuntoDestino,
                cod_empleado_dest AS CodEmpleadoDest,
                IFNULL(a.id_asunto_analitico_equiv, a.id_asunto) AS CodAsunto,
                IF(mi.id_mov_idProducto = MIN(mi.id_mov_idProducto) OVER(PARTITION BY mi.idProducto),
                1,
                0) AS EsPrimerMovimiento,
                IF(mi.id_mov_idProducto = MAX(mi.id_mov_idProducto) OVER(PARTITION BY mi.idProducto),
                1,
                0) AS EsUltimoMovimiento,
                he.id_estado AS CodEstadoFinal,
                e.estado AS EstadoFinal,
                IF(e.estado_grupo = 'Ok',
                'Usado',
                e.estado_grupo) AS EstadoGrupoFinal,
                e.computa_como_disponible AS ComputaComoUso,
                TIMESTAMPDIFF(SECOND, mi.fh_mov, IFNULL(mi.fh_mov_fin, NOW())) / (3600 * 24) AS DiasEnMovimiento
            FROM
                intranet.mov_inventario AS mi
            LEFT JOIN intranet.configuracion_analitica AS ca ON
                ca.id <= mi.id_mov_idProducto
            LEFT JOIN intranet.inventario AS i ON
                i.idProducto = mi.idProducto
            LEFT JOIN intranet.productos AS p ON
                i.cod_producto = p.cod_producto
            LEFT JOIN intranet.asuntos AS a ON
                mi.id_asunto_dest = a.id_asunto
            LEFT JOIN (
                SELECT
                    id_producto,
                    id_estado
                FROM
                    intranet.historico_estados AS he
                WHERE
                    he.fh_cambio_estado_fin IS NULL ) AS he ON
                mi.idProducto = he.id_producto
                AND mi.fh_mov_fin IS NULL
            LEFT JOIN intranet.estados AS e ON
                e.id_estado = he.id_estado
            WHERE
                p.id_tipo_producto = 1
            ORDER BY
                mi.idProducto ASC,
                mi.fh_mov ASC ) AS mi ) AS mi ON
        EXTRACT(YEAR_MONTH FROM mi.FechaHoraInicioMovimiento) <= EXTRACT(YEAR_MONTH FROM f.fecha)
        AND EXTRACT(YEAR_MONTH FROM f.fecha) <= EXTRACT(YEAR_MONTH FROM IF(mi.EsUltimoMovimiento = 0, mi.FechaHoraFinMovimiento, IF(mi.ComputaComoUso = 0, mi.FechaHoraInicioMovimiento, IF(mi.EnAmortizacionAhora = 0, IF(mi.FechaHoraInicioMovimiento <= mi.FechaHoraFinAmortizacion, mi.FechaHoraFinAmortizacion, mi.FechaHoraInicioMovimiento), NOW()))))
    WHERE
        mi.Capitulo IS NOT NULL
    ORDER BY
        mi.IdProducto,
        mi.NumeroMovimiento,
        f.Fecha ) AS mi
LEFT JOIN intranet.asuntos AS a ON
    a.id_asunto = mi.CodAsunto
WHERE
    a.id_empresa = 1
    AND mi.Fecha >= '2017-01-01'
ORDER BY
    mi.IdProducto,
    mi.NumeroMovimiento,
    mi.Fecha ;