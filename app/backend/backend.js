const express = require("express");
const app = express();

app.get("/api", (req, res) => {
  res.json({ message: "Hello from backend!" });
});

app.listen(3001, () => console.log("Backend running on http://localhost:3001"));
