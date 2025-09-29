import express from "express";
import fetch from "node-fetch";

const app = express();
const backendUrl = process.env.BACKEND_URL || "http://localhost:3001/api";

app.get("/", async (_req, res) => {
  try {
    const response = await fetch(backendUrl);
    const data = await response.json();
    res.send(`<h1>Frontend</h1><p>Backend says: ${data.message}</p>`);
  } catch (e) {
    res.status(502).send("Backend unavailable");
  }
});

app.listen(3000, () => console.log("Frontend running on :3000"));
