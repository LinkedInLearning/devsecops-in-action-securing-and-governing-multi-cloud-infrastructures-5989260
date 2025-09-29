import express from "express";
import fetch from "node-fetch";

const app = express();

app.get("/", async (req, res) => {
  const response = await fetch("http://localhost:3001/api");
  const data = await response.json();
  res.send(`<h1>Frontend</h1><p>Backend says: ${data.message}</p>`);
});

app.listen(3000, () => console.log("Frontend running on http://localhost:3000"));
