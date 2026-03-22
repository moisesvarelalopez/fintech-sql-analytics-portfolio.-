# Base de Datos de Práctica para SQL ANSI (Banca)

Este repositorio contiene un entorno de práctica listo para usar, diseñado específicamente para aprender y practicar código SQL ANSI, orientado a analítica de datos en el sector bancario (o Fintech). 

## Estructura de la Base de Datos

Se ha diseñado un esquema relacional realista utilizando datos públicos (basado en el Bank Marketing Dataset de UCI). La base de datos, llamada `bank_practice`, contiene 3 tablas principales. Esta estructura está pensada para forzarte a practicar `JOIN`s:

### 1. `customers` (Clientes)
Contiene la información demográfica.
- `customer_id` (INT, PK)
- `age` (INT): Edad del cliente.
- `job` (VARCHAR): Tipo de trabajo.
- `marital_status` (VARCHAR): Estado civil.
- `education` (VARCHAR): Nivel educativo.
- `has_credit_default` (BOOLEAN): ¿Tiene un préstamo en mora (default)?

### 2. `accounts` (Cuentas e Historial Financiero)
Productos financieros vinculados al cliente.
- `account_id` (INT, PK)
- `customer_id` (INT, FK)
- `balance` (NUMERIC): Saldo bancario anual promedio.
- `has_housing_loan` (BOOLEAN): ¿Tiene préstamo hipotecario?
- `has_personal_loan` (BOOLEAN): ¿Tiene préstamo personal?

### 3. `campaigns` (Campañas de Marketing / Interacciones)
Historial de contactos realizados por el banco hacia el cliente.
- `campaign_id` (INT, PK)
- `customer_id` (INT, FK)
- `contact_type` (VARCHAR): Tipo de comunicación (celular, teléfono).
- `duration_seconds` (INT): Duración del último contacto en segundos.
- `subscribed_term_deposit` (BOOLEAN): ¿El cliente terminó suscribiéndose a un depósito a plazo fijo? (El objetivo de la campaña).
- *(Y otras columnas con detalles como día, mes, contactos en esta campaña, etc.)*

## Cómo Iniciar

El entorno utiliza contenedores de **Docker**. Gracias a esto, no necesitas instalar PostgreSQL localmente de forma compleja.

Para iniciar la base de datos (y descargar automáticamente el CSV desde GitHub para poblarla), ejecuta en esta carpeta:

```bash
docker-compose up -d --build
```

El script en Python de inicialización se descargará un dataset de la web, lo limpiará, normalizará en las tres tablas y lo insertará utilizando `sqlalchemy`. ¡Este proceso dura menos de un minuto!

## Conexión a la Base de Datos

Puedes conectarte a tu base de datos en PostgreSQL utilizando DBeaver, pgAdmin, VSCode SQLTools o DataGrip usando las siguientes credenciales:

- **Host:** `localhost`
- **Puerto:** `5433`
- **Usuario:** `postgres`
- **Contraseña:** `password123`
- **Base de Datos:** `bank_practice`

## Ejercicios Sugeridos (Para practicar ANSI SQL)

1. **GROUP BY Básico:** ¿Cuál es el saldo promedio (`balance`) de los clientes separado por su tipo de trabajo (`job`)?
2. **JOIN:** Encuentra todos los `customers` solteros (`marital_status = 'single'`) que se suscribieron a un depósito a plazo fijo (`subscribed_term_deposit = true`).
3. **Agregación Múltiple:** ¿Muestra el saldo total acumulado de todas las personas que tienen un préstamo hipotecario (`has_housing_loan`) dividido por su nivel educativo (`education`).
