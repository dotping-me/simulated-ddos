const http = require("node:http");
const PORT = process.env.PORT || 9000;

const fs = require("node:fs");
const path = require("node:path");
const { URL } = require("node:url");
const db = require("./database");

let reqCount = 0; // Just visual feedback
const INSTANCE = process.env.INSTANCE || "victim";

const server = http.createServer((req, res) => {
    const clientIP = req.headers["x-forwarded-for"]?.split(",")[0].trim() || req.socket.remoteAddress;
    reqCount++;

    const url = new URL(req.url, `http://${req.headers.host}`);
    console.log(`[${INSTANCE}] ${reqCount.toString().padStart(6, "0")} | ${req.method} ${req.url} ← ${clientIP}`);

    // API Route
    if (url.pathname === "/api/items") {
        const search = url.searchParams.get("search") || "";
        const maxPrice = url.searchParams.get("maxprice");

        let query = `
            SELECT id, name, description, price
            FROM items
            WHERE 1 = 1
        `;

        const params = [];
        if (search) {
            query += `
                AND (
                    name LIKE ?
                    OR description LIKE ?
                )
            `;

            const pattern = `%${search}%`;
            params.push(pattern, pattern);
        }

        if (maxPrice) {
            query += ` AND price <= ?`;
            params.push(Number(maxPrice));
        }

        query += ` ORDER BY price ASC`;
        const items = db.prepare(query).all(...params);
        res.writeHead(200, { "Content-Type": "application/json" });
        return res.end(JSON.stringify(items));
    }

    // Serve webpage
    if (url.pathname === "/" || url.pathname === "/index.html") {
        const file = fs.readFileSync(path.join(__dirname, "index.html"));
        res.writeHead(200, { "Content-Type": "text/html" });

        return res.end(file);
    }

    res.writeHead(404, { "Content-Type": "text/plain" });
    res.end("Not Found\n");
});

server.listen(PORT, "0.0.0.0", () => {
    console.log(`Victim listening on 0.0.0.0:${PORT}`);
});