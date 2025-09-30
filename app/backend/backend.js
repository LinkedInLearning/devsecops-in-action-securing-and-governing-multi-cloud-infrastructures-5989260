const express = require("express");
const app = express();

const environment = process.env.ENVIRONMENT || "unknown";

app.get("/api", (req, res) => {
  res.json({
    message: `Hello from backend!`,
    environment: environment,
  });
});

app.listen(80, () => console.log(`Backend (${environment}) running on http://localhost`));
