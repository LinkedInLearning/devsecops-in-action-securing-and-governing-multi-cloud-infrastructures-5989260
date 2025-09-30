import express from "express";
import fetch from "node-fetch";

const app = express();
const backendUrl = process.env.BACKEND_URL || "http://localhost/api";
const environment = process.env.ENVIRONMENT || "unknown";

app.get("/", async (_req, res) => {
  try {
    const response = await fetch(backendUrl);
    const data = await response.json();
    res.send(`
      <h1>Frontend (${environment})</h1>
      <p>Backend says: ${data.message}</p>
      <p>Backend environment: ${data.environment}</p>
    `);
  } catch (e) {
    res.status(502).send(`Backend unavailable from frontend ${environment}`);
  }
});

app.listen(80, () => console.log(`Frontend (${environment}) running on :80`));
