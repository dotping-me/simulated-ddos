const http = require("http");
const PORT = process.env.PORT || 9000;

const server = http.createServer((req, res) => {
    console.log(`${req.method} ${req.url}`);
    if (req.url === "/") {
        res.writeHead(200, {
            "Content-Type": "application/json"
        });

        return res.end(JSON.stringify({
            status: "DDoS sim"
        }));
    }

    res.writeHead(404, {
        "Content-Type": "text/plain"
    });

    res.end("Not Found\n");
});

server.listen(PORT, "0.0.0.0", () => {
    console.log(`Victim listening on 0.0.0.0:${PORT}`);
});