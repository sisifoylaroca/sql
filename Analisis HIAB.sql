SELECT
    shipmentNumber,
    shipmentDate,
    arrivalDate,
    referenceId,
    qty,
    supplierId
FROM
    digi_sc_hub.dbo.GIT gt;


SELECT
    referenceId,
    supplierId,
    family,
    stock,
    needDate,
    outfeed,
    qty,
    id
FROM
    digi_sc_hub.dbo.consigNeeds cn;

SELECT
    referenceId,
    description_1,
    description_2,
    supplierId,
    minStock,
    maxStock
FROM
    digi_sc_hub.dbo.reference;

SELECT
    referenceId,
    description,
    supplierId,
    stock81,
    stock51,
    supplierName,
    stockCost,
    abs51,
    orderQty,
    orderLine,
    orderNum,
    [date]
FROM
    digi_sc_hub.dbo.consigStock;

-- Tabla STOCK
SELECT
    COUNT(*)
FROM
    stock s ;

SELECT
    stockDate,
    stock,
    WIP,
    referenceId,
    supplierId
FROM
    digi_sc_hub.dbo.stock s;

-- SUPPLIERS
SELECT
    supplierId,
    supplierName,
    supplierEmail
FROM
    digi_sc_hub.dbo.suppliers;
