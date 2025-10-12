const express = require("express");
const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: false }));

const environment = process.env.ENVIRONMENT || "unknown";

app.get("/api", (req, res) => {
  res.json({
    message: `Hello from backend!`,
    environment: environment,
  });
});

app.post("/api", (req, res) => {
  const userInput = req.body?.input || "";
  res.type("text").send(userInput);
});

app.listen(80, () => console.log(`Backend (${environment}) running on http://localhost`));

