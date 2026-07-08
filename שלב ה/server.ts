import "dotenv/config";
import express from "express";
import { createServer as createViteServer } from "vite";
import path from "path";
import cors from "cors";
import { fileURLToPath } from "url";
import { Pool, PoolClient } from "pg";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = Number(process.env.PORT || 3000);

app.use(cors());
app.use(express.json());

const pool = new Pool(
  process.env.DATABASE_URL
    ? { connectionString: process.env.DATABASE_URL }
    : {
        host: process.env.DB_HOST || "localhost",
        port: Number(process.env.DB_PORT || 5432),
        database: process.env.DB_NAME || "tripdb",
        user: process.env.DB_USER || "postgres",
        password: process.env.DB_PASSWORD || "postgres",
      }
);

type EntityKey =
  | "routes"
  | "sites"
  | "guides"
  | "users"
  | "tours"
  | "bookings"
  | "routeSites"
  | "paymentLog"
  | "tourPriceHistory";

type ColumnInfo = { name: string; dataType: string; udtName: string };
type DbSchema = Record<string, Record<string, ColumnInfo>>;

type EntityRuntime = {
  key: EntityKey;
  table: string;
  id?: string;
  fields: Record<string, string>;
};

type EntityDefinition = {
  key: EntityKey;
  tableCandidates: string[];
  idCandidates?: string[];
  fields: Record<string, string[]>;
};

const definitions: EntityDefinition[] = [
  {
    key: "routes",
    tableCandidates: [process.env.DB_TABLE_ROUTES || "", "route", "routes", "tour", "tours"],
    idCandidates: ["route_id", "t_name", "tour_id", "id"],
    fields: {
      name: ["route_name", "t_name", "name", "title", "tour_name"],
      difficulty: ["difficulty_level", "difficulty", "level"],
      duration: ["estimated_duration", "duration", "duration_days"],
      distance: ["distance", "distance_km", "length"],
      area: ["area", "region"],
      route_type: ["route_type", "type"],
      max_participants: ["max_participants", "capacity"],
      price: ["price", "tour_price"],
      description: ["description", "details"],
    },
  },
  {
    key: "sites",
    tableCandidates: [process.env.DB_TABLE_SITES || "", "site", "sites", "station", "stations"],
    idCandidates: ["site_id", "station_id", "s_id", "id", "s_name"],
    fields: {
      name: ["site_name", "station_name", "s_name", "name", "title"],
      city: ["city", "s_city"],
      country: ["country"],
      address: ["address", "location", "s_location"],
      category: ["category", "site_type", "type"],
      description: ["description", "details"],
    },
  },
  {
    key: "guides",
    tableCandidates: [process.env.DB_TABLE_GUIDES || "", "guide", "guides"],
    idCandidates: ["guide_id", "g_id", "id"],
    fields: {
      full_name: ["full_name", "guide_name", "name"],
      first_name: ["g_first_name", "first_name"],
      last_name: ["g_last_name", "last_name"],
      phone: ["phone", "phone_number", "g_phone"],
      email: ["email", "g_email"],
      languages: ["languages", "language"],
      experience_years: ["experience_years", "years_experience", "experience"],
      school: ["school"],
    },
  },
  {
    key: "users",
    tableCandidates: [process.env.DB_TABLE_USERS || "", "users", "user", "traveler", "travelers", "customer", "customers"],
    idCandidates: ["user_id", "traveler_id", "c_id", "id"],
    fields: {
      full_name: ["full_name", "user_name", "traveler_name", "name"],
      first_name: ["c_first_name", "first_name"],
      last_name: ["c_last_name", "last_name"],
      email: ["email", "c_email"],
      phone: ["phone", "phone_number", "c_phone"],
    },
  },
  {
    key: "tours",
    tableCandidates: [process.env.DB_TABLE_TOURS || "", "guidedtour", "guided_tours", "tourinstance", "tour_instances"],
    idCandidates: ["tour_id", "guided_tour_id", "t_i_id", "id"],
    fields: {
      route_id: ["route_id", "t_name", "tour_name"],
      guide_id: ["guide_id", "g_id"],
      start_date: ["start_date", "tour_date", "t_date", "date"],
      start_time: ["start_time"],
      end_time: ["end_time"],
      max_participants: ["max_participants", "capacity"],
      price: ["price", "tour_price"],
      status: ["status"],
    },
  },
  {
    key: "bookings",
    tableCandidates: [process.env.DB_TABLE_BOOKINGS || "", "booking", "bookings"],
    idCandidates: ["booking_id", "b_id", "id"],
    fields: {
      tour_id: ["tour_id", "guided_tour_id", "t_i_id"],
      user_id: ["user_id", "traveler_id", "c_id"],
      booking_date: ["booking_date", "b_date", "created_at", "date"],
      participants: ["participants", "num_participants", "number_of_participants", "amount_pepole"],
      payment_status: ["payment_status", "b_status", "status"],
      total_price: ["total_price", "price"],
    },
  },
  {
    key: "routeSites",
    tableCandidates: [process.env.DB_TABLE_ROUTE_SITES || "", "routesite", "route_site", "route_sites", "tourstation", "tour_station"],
    fields: {
      route_id: ["route_id", "t_name", "tour_name"],
      site_id: ["site_id", "station_id", "s_name", "station_name"],
      order_index: ["visit_order", "order_index", "site_order", "route_order", "position", "station_order"],
      visit_duration: ["visit_duration", "duration"],
    },
  },
  {
    key: "paymentLog",
    tableCandidates: ["payment_log", "payments_log"],
    idCandidates: ["payment_id", "id"],
    fields: {
      customer_id: ["c_id", "customer_id", "user_id"],
      booking_id: ["b_id", "booking_id"],
      amount: ["amount", "total", "total_price"],
      paid_at: ["paid_at", "created_at"],
      note: ["note", "description"],
    },
  },
  {
    key: "tourPriceHistory",
    tableCandidates: ["tour_price_history", "price_history"],
    idCandidates: ["history_id", "id"],
    fields: {
      tour_name: ["t_name", "tour_name", "route_name"],
      old_price: ["old_price"],
      new_price: ["new_price"],
      changed_at: ["changed_at", "created_at"],
    },
  },
];

let schemaCache: DbSchema | null = null;
let runtimeCache: Partial<Record<EntityKey, EntityRuntime>> | null = null;

function qi(identifier: string) {
  return `"${identifier.replace(/"/g, '""')}"`;
}

function cleanCandidates(values: string[]) {
  return values.map((v) => v.trim()).filter(Boolean);
}

function schemaColumn(schema: DbSchema, table: string, column?: string) {
  if (!column) return undefined;
  return schema[table.toLowerCase()]?.[column.toLowerCase()];
}

async function loadSchema(): Promise<DbSchema> {
  if (schemaCache) return schemaCache;
  const result = await pool.query(
    `SELECT table_name, column_name, data_type, udt_name
     FROM information_schema.columns
     WHERE table_schema = current_schema()`
  );
  const schema: DbSchema = {};
  for (const row of result.rows) {
    const tableName = String(row.table_name).toLowerCase();
    const columnName = String(row.column_name).toLowerCase();
    if (!schema[tableName]) schema[tableName] = {};
    schema[tableName][columnName] = {
      name: String(row.column_name),
      dataType: String(row.data_type),
      udtName: String(row.udt_name),
    };
  }
  schemaCache = schema;
  return schema;
}

async function getRuntime() {
  if (runtimeCache) return runtimeCache;
  const schema = await loadSchema();
  const runtime: Partial<Record<EntityKey, EntityRuntime>> = {};

  for (const def of definitions) {
    const table = cleanCandidates(def.tableCandidates).find((candidate) => schema[candidate.toLowerCase()]);
    if (!table) continue;

    const columns = schema[table.toLowerCase()];
    const id = cleanCandidates(def.idCandidates || []).find((candidate) => columns[candidate.toLowerCase()]);
    const fields: Record<string, string> = {};

    for (const [logicalName, candidates] of Object.entries(def.fields)) {
      const column = cleanCandidates(candidates).find((candidate) => columns[candidate.toLowerCase()]);
      if (column) fields[logicalName] = column;
    }

    runtime[def.key] = { key: def.key, table, id, fields };
  }

  runtimeCache = runtime;
  return runtime;
}

async function entity(key: EntityKey) {
  const runtime = await getRuntime();
  const cfg = runtime[key];
  if (!cfg) {
    throw new Error(`Missing table for ${key}. Check table names in .env or database schema.`);
  }
  return cfg;
}

function field(cfg: EntityRuntime, logical: string) {
  return cfg.fields[logical];
}

function selectField(cfg: EntityRuntime, logical: string, fallback = "NULL") {
  const column = field(cfg, logical);
  return column ? `t.${qi(column)} AS ${qi(logical)}` : `${fallback} AS ${qi(logical)}`;
}

async function selectPaymentStatusExpression(cfg: EntityRuntime) {
  const schema = await loadSchema();
  const column = field(cfg, "payment_status");
  if (!column) return "'Pending' AS payment_status";
  const info = schemaColumn(schema, cfg.table, column);
  if (info?.udtName === "bool" || info?.dataType === "boolean") {
    return `CASE WHEN t.${qi(column)} IS TRUE THEN 'Paid' ELSE 'Unpaid' END AS payment_status`;
  }
  return `t.${qi(column)} AS payment_status`;
}

function selectId(cfg: EntityRuntime) {
  if (!cfg.id) throw new Error(`Missing ID column for ${cfg.key}.`);
  return `t.${qi(cfg.id)} AS id`;
}

async function labelExpression(cfg: EntityRuntime, alias = "t") {
  const fullName = field(cfg, "full_name");
  const firstName = field(cfg, "first_name");
  const lastName = field(cfg, "last_name");
  const name = field(cfg, "name");
  if (fullName) return `${alias}.${qi(fullName)}`;
  if (firstName || lastName) {
    return `TRIM(CONCAT_WS(' ', ${firstName ? `${alias}.${qi(firstName)}` : "NULL"}, ${lastName ? `${alias}.${qi(lastName)}` : "NULL"}))`;
  }
  if (name) return `${alias}.${qi(name)}`;
  if (cfg.id) return `${alias}.${qi(cfg.id)}::text`;
  return "NULL";
}

async function normalizeValue(cfg: EntityRuntime, logical: string, column: string, value: unknown) {
  if (value === "") return null;
  if (value === undefined) return undefined;
  const schema = await loadSchema();
  const info = schemaColumn(schema, cfg.table, column);
  if (info?.udtName === "bool" || info?.dataType === "boolean") {
    if (typeof value === "boolean") return value;
    const normalized = String(value).toLowerCase().trim();
    if (["paid", "true", "yes", "1", "שולם"].includes(normalized)) return true;
    if (["unpaid", "pending", "false", "no", "0", "לא שולם"].includes(normalized)) return false;
  }
  return value;
}

async function writableEntries(cfg: EntityRuntime, body: Record<string, unknown>, excludeId = true) {
  const entries: Array<[string, unknown]> = [];
  for (const [logical, column] of Object.entries(cfg.fields)) {
    if (excludeId && logical === "id") continue;
    if (Object.prototype.hasOwnProperty.call(body, logical)) {
      entries.push([column, await normalizeValue(cfg, logical, column, body[logical])]);
    }
  }
  return entries.filter(([, value]) => value !== undefined);
}

async function listBasic(key: EntityKey, logicalFields: string[]) {
  const cfg = await entity(key);
  const selects = [selectId(cfg), ...logicalFields.map((name) => selectField(cfg, name))];
  const result = await pool.query(`SELECT ${selects.join(", ")} FROM ${qi(cfg.table)} t ORDER BY 1 DESC LIMIT 500`);
  return result.rows;
}

async function getBasic(key: EntityKey, logicalFields: string[], id: string) {
  const cfg = await entity(key);
  if (!cfg.id) throw new Error(`Missing ID column for ${key}.`);
  const selects = [selectId(cfg), ...logicalFields.map((name) => selectField(cfg, name))];
  const result = await pool.query(`SELECT ${selects.join(", ")} FROM ${qi(cfg.table)} t WHERE t.${qi(cfg.id)} = $1`, [id]);
  return result.rows[0] || null;
}


function isNumericColumn(info: ColumnInfo | undefined) {
  if (!info) return false;
  return ["int2", "int4", "int8", "serial", "bigserial", "numeric"].includes(info.udtName) ||
    ["smallint", "integer", "bigint", "numeric"].includes(info.dataType);
}

async function insertBasic(key: EntityKey, body: Record<string, unknown>) {
  const cfg = await entity(key);
  if (!cfg.id) throw new Error(`Missing ID column for ${key}.`);

  const entries = await writableEntries(cfg, body);
  if (entries.length === 0) throw new Error("No matching columns were sent.");

  const schema = await loadSchema();
  const idInfo = schemaColumn(schema, cfg.table, cfg.id);

  const columns = entries.map(([column]) => qi(column));
  const values = entries.map(([, value]) => value);
  const params = values.map((_, idx) => `$${idx + 1}`);

  // In the project DB some id columns are NOT NULL but not SERIAL.
  // The UI hides IDs, so the server creates the next numeric ID automatically.
  if (isNumericColumn(idInfo)) {
    columns.unshift(qi(cfg.id));
    params.unshift(`(SELECT COALESCE(MAX(${qi(cfg.id)}), 0) + 1 FROM ${qi(cfg.table)})`);
  }

  const result = await pool.query(
    `INSERT INTO ${qi(cfg.table)} (${columns.join(", ")}) VALUES (${params.join(", ")}) RETURNING ${qi(cfg.id)} AS id`,
    values
  );

  return result.rows[0];
}

async function updateBasic(key: EntityKey, id: string, body: Record<string, unknown>) {
  const cfg = await entity(key);
  if (!cfg.id) throw new Error(`Missing ID column for ${key}.`);
  const entries = await writableEntries(cfg, body);
  if (entries.length === 0) throw new Error("No matching columns were sent.");
  const values = entries.map(([, value]) => value);
  const sets = entries.map(([column], idx) => `${qi(column)} = $${idx + 1}`);
  await pool.query(`UPDATE ${qi(cfg.table)} SET ${sets.join(", ")} WHERE ${qi(cfg.id)} = $${values.length + 1}`, [...values, id]);
  return { success: true };
}

async function deleteBasic(key: EntityKey, id: string) {
  const cfg = await entity(key);
  if (!cfg.id) throw new Error(`Missing ID column for ${key}.`);
  await pool.query(`DELETE FROM ${qi(cfg.table)} WHERE ${qi(cfg.id)} = $1`, [id]);
  return { success: true };
}

function asyncHandler(fn: (req: express.Request, res: express.Response) => Promise<unknown>) {
  return (req: express.Request, res: express.Response) => {
    fn(req, res)
      .then((data) => {
        if (!res.headersSent) res.json(data);
      })
      .catch((err) => {
        console.error(err);
        if (!res.headersSent) res.status(500).json({ error: err.message || "Server error" });
      });
  };
}

app.get("/api/health", asyncHandler(async () => {
  await pool.query("SELECT 1");
  return { ok: true };
}));

app.get("/api/schema/status", asyncHandler(async () => {
  const runtime = await getRuntime();
  return Object.fromEntries(Object.entries(runtime).map(([key, value]) => [key, { table: value?.table, id: value?.id, fields: value?.fields }]));
}));

app.get("/api/routes", asyncHandler(async () => listBasic("routes", ["name", "difficulty", "duration", "distance", "area", "route_type", "max_participants", "price", "description"])));
app.get("/api/routes/:id", asyncHandler(async (req) => getBasic("routes", ["name", "difficulty", "duration", "distance", "area", "route_type", "max_participants", "price", "description"], req.params.id)));
app.post("/api/routes", asyncHandler(async (req) => insertBasic("routes", req.body)));
app.put("/api/routes/:id", asyncHandler(async (req) => updateBasic("routes", req.params.id, req.body)));
app.delete("/api/routes/:id", asyncHandler(async (req) => deleteBasic("routes", req.params.id)));

app.get("/api/sites", asyncHandler(async () => listBasic("sites", ["name", "city", "country", "address", "category", "description"])));
app.get("/api/sites/:id", asyncHandler(async (req) => getBasic("sites", ["name", "city", "country", "address", "category", "description"], req.params.id)));
app.post("/api/sites", asyncHandler(async (req) => insertBasic("sites", req.body)));
app.put("/api/sites/:id", asyncHandler(async (req) => updateBasic("sites", req.params.id, req.body)));
app.delete("/api/sites/:id", asyncHandler(async (req) => deleteBasic("sites", req.params.id)));

app.get("/api/guides", asyncHandler(async () => listBasic("guides", ["full_name", "first_name", "last_name", "phone", "email", "languages", "experience_years", "school"])));
app.get("/api/guides/:id", asyncHandler(async (req) => getBasic("guides", ["full_name", "first_name", "last_name", "phone", "email", "languages", "experience_years", "school"], req.params.id)));
app.post("/api/guides", asyncHandler(async (req) => insertBasic("guides", req.body)));
app.put("/api/guides/:id", asyncHandler(async (req) => updateBasic("guides", req.params.id, req.body)));
app.delete("/api/guides/:id", asyncHandler(async (req) => deleteBasic("guides", req.params.id)));

app.get("/api/users", asyncHandler(async () => listBasic("users", ["full_name", "first_name", "last_name", "email", "phone"])));
app.get("/api/users/:id", asyncHandler(async (req) => getBasic("users", ["full_name", "first_name", "last_name", "email", "phone"], req.params.id)));
app.post("/api/users", asyncHandler(async (req) => insertBasic("users", req.body)));
app.put("/api/users/:id", asyncHandler(async (req) => updateBasic("users", req.params.id, req.body)));
app.delete("/api/users/:id", asyncHandler(async (req) => deleteBasic("users", req.params.id)));

app.get("/api/tours", asyncHandler(async () => {
  const rt = await getRuntime();
  const tours = await entity("tours");
  const routes = rt.routes;
  const guides = rt.guides;
  const routeId = field(tours, "route_id");
  const guideId = field(tours, "guide_id");
  const selects = [
    selectId(tours),
    selectField(tours, "route_id"),
    selectField(tours, "guide_id"),
    selectField(tours, "start_date"),
    selectField(tours, "start_time"),
    selectField(tours, "end_time"),
    selectField(tours, "max_participants"),
    selectField(tours, "price", "0"),
    selectField(tours, "status", "'Open'"),
  ];
  const joins: string[] = [];
  if (routes && routeId && routes.id && field(routes, "name")) {
    joins.push(`LEFT JOIN ${qi(routes.table)} r ON t.${qi(routeId)}::text = r.${qi(routes.id)}::text`);
    selects.push(`r.${qi(field(routes, "name"))} AS route_name`);
  } else selects.push("NULL AS route_name");
  if (guides && guideId && guides.id) {
    joins.push(`LEFT JOIN ${qi(guides.table)} g ON t.${qi(guideId)}::text = g.${qi(guides.id)}::text`);
    selects.push(`${await labelExpression(guides, "g")} AS guide_name`);
  } else selects.push("NULL AS guide_name");
  const result = await pool.query(`SELECT ${selects.join(", ")} FROM ${qi(tours.table)} t ${joins.join(" ")} ORDER BY 1 DESC LIMIT 500`);
  return result.rows;
}));
app.get("/api/tours/:id", asyncHandler(async (req) => getBasic("tours", ["route_id", "guide_id", "start_date", "start_time", "end_time", "max_participants", "price", "status"], req.params.id)));
app.post("/api/tours", asyncHandler(async (req) => insertBasic("tours", req.body)));
app.put("/api/tours/:id", asyncHandler(async (req) => updateBasic("tours", req.params.id, req.body)));
app.delete("/api/tours/:id", asyncHandler(async (req) => deleteBasic("tours", req.params.id)));

app.get("/api/bookings", asyncHandler(async () => {
  const rt = await getRuntime();
  const bookings = await entity("bookings");
  const users = rt.users;
  const tours = rt.tours;
  const routes = rt.routes;
  const userId = field(bookings, "user_id");
  const tourId = field(bookings, "tour_id");
  const selects = [
    selectId(bookings),
    selectField(bookings, "tour_id"),
    selectField(bookings, "user_id"),
    selectField(bookings, "booking_date"),
    selectField(bookings, "participants", "1"),
    await selectPaymentStatusExpression(bookings),
    selectField(bookings, "total_price", "0"),
  ];
  const joins: string[] = [];
  if (users && userId && users.id) {
    joins.push(`LEFT JOIN ${qi(users.table)} u ON t.${qi(userId)}::text = u.${qi(users.id)}::text`);
    selects.push(`${await labelExpression(users, "u")} AS user_name`);
  } else selects.push("NULL AS user_name");
  if (tours && tourId && tours.id) {
    joins.push(`LEFT JOIN ${qi(tours.table)} gt ON t.${qi(tourId)}::text = gt.${qi(tours.id)}::text`);
    if (field(tours, "start_date")) selects.push(`gt.${qi(field(tours, "start_date"))} AS tour_date`); else selects.push("NULL AS tour_date");
    const tourRouteId = field(tours, "route_id");
    if (routes && tourRouteId && routes.id && field(routes, "name")) {
      joins.push(`LEFT JOIN ${qi(routes.table)} r ON gt.${qi(tourRouteId)}::text = r.${qi(routes.id)}::text`);
      selects.push(`r.${qi(field(routes, "name"))} AS route_name`);
    } else if (tourRouteId) {
      selects.push(`gt.${qi(tourRouteId)}::text AS route_name`);
    } else selects.push("NULL AS route_name");
  } else {
    selects.push("NULL AS tour_date", "NULL AS route_name");
  }
  const result = await pool.query(`SELECT ${selects.join(", ")} FROM ${qi(bookings.table)} t ${joins.join(" ")} ORDER BY 1 DESC LIMIT 500`);
  return result.rows;
}));
app.get("/api/bookings/:id", asyncHandler(async (req) => getBasic("bookings", ["tour_id", "user_id", "booking_date", "participants", "payment_status", "total_price"], req.params.id)));
app.post("/api/bookings", asyncHandler(async (req) => insertBasic("bookings", req.body)));
app.put("/api/bookings/:id", asyncHandler(async (req) => updateBasic("bookings", req.params.id, req.body)));
app.delete("/api/bookings/:id", asyncHandler(async (req) => deleteBasic("bookings", req.params.id)));

app.get("/api/route-sites", asyncHandler(async () => {
  const rt = await getRuntime();
  const rs = await entity("routeSites");
  const routes = rt.routes;
  const sites = rt.sites;
  const routeId = field(rs, "route_id");
  const siteId = field(rs, "site_id");
  if (!routeId || !siteId) throw new Error("ROUTESITE/TOURSTATION table must contain route/tour and site/station columns.");
  const selects = [`t.${qi(routeId)} AS route_id`, `t.${qi(siteId)} AS site_id`, selectField(rs, "order_index", "0"), selectField(rs, "visit_duration", "NULL")];
  const joins: string[] = [];
  if (routes && routes.id && field(routes, "name")) {
    joins.push(`LEFT JOIN ${qi(routes.table)} r ON t.${qi(routeId)}::text = r.${qi(routes.id)}::text`);
    selects.push(`r.${qi(field(routes, "name"))} AS route_name`);
  } else selects.push(`t.${qi(routeId)}::text AS route_name`);
  if (sites && sites.id && field(sites, "name")) {
    joins.push(`LEFT JOIN ${qi(sites.table)} s ON t.${qi(siteId)}::text = s.${qi(sites.id)}::text`);
    selects.push(`s.${qi(field(sites, "name"))} AS site_name`);
  } else selects.push(`t.${qi(siteId)}::text AS site_name`);
  const result = await pool.query(`SELECT ${selects.join(", ")} FROM ${qi(rs.table)} t ${joins.join(" ")} ORDER BY route_name NULLS LAST, order_index NULLS LAST LIMIT 500`);
  return result.rows;
}));
app.post("/api/route-sites", asyncHandler(async (req) => {
  const cfg = await entity("routeSites");
  const entries = await writableEntries(cfg, req.body, false);
  if (entries.length === 0) throw new Error("No matching columns were sent.");
  const values = entries.map(([, value]) => value);
  const params = values.map((_, idx) => `$${idx + 1}`);
  await pool.query(`INSERT INTO ${qi(cfg.table)} (${entries.map(([col]) => qi(col)).join(", ")}) VALUES (${params.join(", ")})`, values);
  return { success: true };
}));
app.put("/api/route-sites/:routeId/:siteId", asyncHandler(async (req) => {
  const cfg = await entity("routeSites");
  const routeId = field(cfg, "route_id");
  const siteId = field(cfg, "site_id");
  if (!routeId || !siteId) throw new Error("Missing route/site columns.");

  const entries = await writableEntries(cfg, req.body, false);
  if (entries.length === 0) throw new Error("No matching columns were sent.");

  const values = entries.map(([, value]) => value);
  const sets = entries.map(([column], idx) => `${qi(column)} = $${idx + 1}`);

  const result = await pool.query(
    `UPDATE ${qi(cfg.table)}
     SET ${sets.join(", ")}
     WHERE ${qi(routeId)}::text = $${values.length + 1}
       AND ${qi(siteId)}::text = $${values.length + 2}`,
    [...values, req.params.routeId, req.params.siteId]
  );

  if (result.rowCount === 0) {
    throw new Error("No Route-Site record was updated. The selected route/site key was not found.");
  }

  return { success: true, updated: result.rowCount };
}));

app.delete("/api/route-sites/:routeId/:siteId", asyncHandler(async (req) => {
  const cfg = await entity("routeSites");
  const routeId = field(cfg, "route_id");
  const siteId = field(cfg, "site_id");
  if (!routeId || !siteId) throw new Error("Missing route/site columns.");

  const result = await pool.query(
    `DELETE FROM ${qi(cfg.table)}
     WHERE ${qi(routeId)}::text = $1
       AND ${qi(siteId)}::text = $2`,
    [req.params.routeId, req.params.siteId]
  );

  if (result.rowCount === 0) {
    throw new Error("No Route-Site record was deleted. The selected route/site key was not found.");
  }

  return { success: true, deleted: result.rowCount };
}));

app.get("/api/lookups", asyncHandler(async () => {
  const rt = await getRuntime();
  const result: Record<string, Array<{ id: number | string; label: string }>> = {};

  async function lookup(key: EntityKey, name: string) {
    const cfg = rt[key];
    if (!cfg || !cfg.id) {
      result[name] = [];
      return;
    }
    const rows = await pool.query(`SELECT ${qi(cfg.id)} AS id, ${await labelExpression(cfg)} AS label FROM ${qi(cfg.table)} t ORDER BY 2 LIMIT 1000`);
    result[name] = rows.rows.map((row) => ({ id: row.id, label: row.label || String(row.id) }));
  }

  await lookup("routes", "routes");
  await lookup("sites", "sites");
  await lookup("guides", "guides");
  await lookup("users", "users");

  const tours = rt.tours;
  if (tours && tours.id) {
    const parts = [`'#' || t.${qi(tours.id)}::text`];
    if (field(tours, "start_date")) parts.push(`COALESCE(t.${qi(field(tours, "start_date"))}::text, '')`);
    if (field(tours, "route_id")) parts.push(`COALESCE(t.${qi(field(tours, "route_id"))}::text, '')`);
    const rows = await pool.query(`SELECT ${qi(tours.id)} AS id, CONCAT_WS(' | ', ${parts.join(", ")}) AS label FROM ${qi(tours.table)} t ORDER BY 1 DESC LIMIT 1000`);
    result.tours = rows.rows;
  } else result.tours = [];

  return result;
}));

app.get("/api/dashboard/stats", asyncHandler(async () => {
  const rt = await getRuntime();
  async function count(key: EntityKey) {
    const cfg = rt[key];
    if (!cfg) return 0;
    const rows = await pool.query(`SELECT COUNT(*)::int AS count FROM ${qi(cfg.table)}`);
    return rows.rows[0]?.count || 0;
  }

  let revenue = 0;
  const bookings = rt.bookings;
  const tours = rt.tours;
  if (bookings && field(bookings, "total_price")) {
    const revenueRows = await pool.query(`SELECT COALESCE(SUM(${qi(field(bookings, "total_price"))}), 0)::numeric AS revenue FROM ${qi(bookings.table)}`);
    revenue = Number(revenueRows.rows[0]?.revenue || 0);
  } else if (bookings && tours && field(bookings, "tour_id") && tours.id && field(tours, "price")) {
    const participants = field(bookings, "participants");
    const revenueRows = await pool.query(`
      SELECT COALESCE(SUM(COALESCE(gt.${qi(field(tours, "price"))}, 0) * COALESCE(${participants ? `b.${qi(participants)}` : "1"}, 1)), 0)::numeric AS revenue
      FROM ${qi(bookings.table)} b
      JOIN ${qi(tours.table)} gt ON b.${qi(field(bookings, "tour_id"))}::text = gt.${qi(tours.id)}::text
    `);
    revenue = Number(revenueRows.rows[0]?.revenue || 0);
  }

  return {
    routes: await count("routes"),
    sites: await count("sites"),
    guides: await count("guides"),
    travelers: await count("users"),
    tours: await count("tours"),
    bookings: await count("bookings"),
    revenue,
  };
}));

app.get("/api/advanced/busiest-day", asyncHandler(async () => {
  const tours = await entity("tours");
  const dateColumn = field(tours, "start_date");
  if (!dateColumn) throw new Error("Tours table does not contain a start_date/tour_date/t_date/date column.");
  const rows = await pool.query(`
    SELECT TRIM(TO_CHAR(t.${qi(dateColumn)}::date, 'Day')) AS day_of_week, COUNT(*)::int AS tours_count
    FROM ${qi(tours.table)} t
    GROUP BY TRIM(TO_CHAR(t.${qi(dateColumn)}::date, 'Day'))
    ORDER BY tours_count DESC
    LIMIT 1
  `);
  return rows.rows;
}));

app.get("/api/advanced/guide-load", asyncHandler(async () => {
  const rt = await getRuntime();
  const tours = await entity("tours");
  const guides = rt.guides;
  const guideId = field(tours, "guide_id");
  if (!guides || !guideId || !guides.id) throw new Error("Cannot join tours with guides. Check guide_id/g_id columns.");
  const rows = await pool.query(`
    SELECT ${await labelExpression(guides, "g")} AS guide_name, COUNT(*)::int AS tours_count
    FROM ${qi(tours.table)} t
    JOIN ${qi(guides.table)} g ON t.${qi(guideId)}::text = g.${qi(guides.id)}::text
    GROUP BY ${await labelExpression(guides, "g")}
    ORDER BY tours_count DESC, guide_name
    LIMIT 20
  `);
  return rows.rows;
}));

const routineSlots = {
  functions: [process.env.DB_FUNCTION_1 || "fn_available_places", process.env.DB_FUNCTION_2 || "fn_customer_unpaid_bookings"],
  procedures: [process.env.DB_PROCEDURE_1 || "pr_create_booking", process.env.DB_PROCEDURE_2 || "pr_pay_customer_bookings"],
};

app.get("/api/advanced/routines", asyncHandler(async () => routineSlots));

function safeRoutineName(name: string) {
  if (!/^[a-zA-Z_][a-zA-Z0-9_]*$/.test(name)) throw new Error("Routine name is not valid.");
  return qi(name);
}

app.post("/api/advanced/function/:slot", asyncHandler(async (req) => {
  const slot = Number(req.params.slot);
  const name = routineSlots.functions[slot - 1];
  if (!name) throw new Error(`Set DB_FUNCTION_${slot} in .env first.`);

  const args = Array.isArray(req.body?.args) ? req.body.args : [];

  if (slot === 1 || name === "fn_available_places") {
    const tourInstanceId = Number(args[0]);
    if (!Number.isInteger(tourInstanceId)) {
      throw new Error("fn_available_places requires one number: tour id. Example: [1]");
    }

    const result = await pool.query(
      `SELECT ${safeRoutineName(name)}($1::integer) AS available_places`,
      [tourInstanceId]
    );

    return result.rows;
  }

  if (slot === 2 || name === "fn_customer_unpaid_bookings") {
    const customerId = Number(args[0]);
    if (!Number.isInteger(customerId)) {
      throw new Error("fn_customer_unpaid_bookings requires one number: traveler/customer id. Example: [1]");
    }

    return fetchCustomerUnpaidBookings(customerId);
  }

  const placeholders = args.map((_, i) => `$${i + 1}`).join(", ");
  const result = await pool.query(`SELECT * FROM ${safeRoutineName(name)}(${placeholders})`, args);
  return result.rows;
}));

app.post("/api/advanced/procedure/:slot", asyncHandler(async (req) => {
  const slot = Number(req.params.slot);
  const name = routineSlots.procedures[slot - 1];
  if (!name) throw new Error(`Set DB_PROCEDURE_${slot} in .env first.`);

  const args = Array.isArray(req.body?.args) ? req.body.args : [];

  if (slot === 1 || name === "pr_create_booking") {
    const tourInstanceId = Number(args[0]);
    const customerId = Number(args[1]);
    const peopleCount = Number(args[2]);

    if (!Number.isInteger(tourInstanceId) || !Number.isInteger(customerId) || !Number.isInteger(peopleCount)) {
      throw new Error("pr_create_booking requires three numbers: [tour_instance_id, customer_id, people_count]. Example: [1, 1, 2]");
    }

    await pool.query(
      `CALL ${safeRoutineName(name)}($1::integer, $2::integer, $3::integer)`,
      [tourInstanceId, customerId, peopleCount]
    );

    return { success: true, message: `${name} was executed successfully.` };
  }

  if (slot === 2 || name === "pr_pay_customer_bookings") {
    const customerId = Number(args[0]);

    if (!Number.isInteger(customerId)) {
      throw new Error("pr_pay_customer_bookings requires one number: customer id. Example: [1]");
    }

    await pool.query(
      `CALL ${safeRoutineName(name)}($1::integer)`,
      [customerId]
    );

    return { success: true, message: `${name} was executed successfully.` };
  }

  const placeholders = args.map((_, i) => `$${i + 1}`).join(", ");
  await pool.query(`CALL ${safeRoutineName(name)}(${placeholders})`, args);
  return { success: true, message: `${name} was executed successfully.` };
}));

async function fetchCustomerUnpaidBookings(customerId: number) {
  const result = await pool.query(
    "SELECT * FROM public.fn_customer_unpaid_bookings($1::integer)",
    [customerId]
  );

  return result.rows;
}

app.get("/api/logs/payment", asyncHandler(async () => {
  const runtime = await getRuntime();
  if (!runtime.paymentLog) return [];
  return listBasic("paymentLog", ["customer_id", "booking_id", "amount", "paid_at", "note"]);
}));

app.get("/api/logs/price-history", asyncHandler(async () => {
  const runtime = await getRuntime();
  if (!runtime.tourPriceHistory) return [];
  return listBasic("tourPriceHistory", ["tour_name", "old_price", "new_price", "changed_at"]);
}));

async function startServer() {
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({ server: { middlewareMode: true, hmr: false, watch: null }, appType: "spa" });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), "dist");
    app.use(express.static(distPath));
    app.get("*", (_req, res) => res.sendFile(path.join(distPath, "index.html")));
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`SmartRoute server running on http://localhost:${PORT}`);
    console.log(`Database: ${process.env.DB_HOST || "localhost"}:${process.env.DB_PORT || 5432}/${process.env.DB_NAME || "tripdb"}`);
  });
}

startServer();
