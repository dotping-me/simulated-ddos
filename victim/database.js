const { DatabaseSync } = require("node:sqlite");

const db = new DatabaseSync("store.db");
db.exec(`
    CREATE TABLE IF NOT EXISTS items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL
    )
`);

const count = db.prepare("SELECT COUNT(*) AS count FROM items").get();
if (count.count === 0) {
    const insert = db.prepare(`
        INSERT INTO items (name, description, price)
        VALUES (?, ?, ?)
    `);

    const items = [
        ["Book", "A hardcover programming book", 250],
        ["Notebook", "A simple ruled notebook", 80],
        ["Laptop", "A lightweight development laptop", 45000],
        ["Keyboard", "Mechanical USB keyboard", 1500],
        ["Mouse", "Wireless computer mouse", 900],
        ["Monitor", "24-inch Full HD monitor", 7000],
        ["USB Cable", "USB-C charging cable", 300],
        ["Headphones", "Over-ear wireless headphones", 3500],
        ["Backpack", "Laptop-compatible backpack", 2200],
        ["Pen", "Blue ballpoint pen", 50]
    ];

    for (const item of items) {
        insert.run(...item);
    }
}

module.exports = db;