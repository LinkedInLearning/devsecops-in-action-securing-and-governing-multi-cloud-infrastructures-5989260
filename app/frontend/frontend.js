import express from "express";
import fetch from "node-fetch";

const app = express();
app.use(express.urlencoded({ extended: false }));
app.use(express.json());

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
      <br>
      <form method="POST" action="/submit">
        <label>Say something to backend:</label><br/>
        <input name="userinput" /><br/>
        <button type="submit">Send</button>
      </form>
    `);
  } catch (e) {
    res.status(502).send(`Backend unavailable from frontend: ${environment}`);
  }
});

app.post("/submit", async (req, res) => {
  const userinput = req.body.userinput || "";
  try {
    const response = await fetch(backendUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ input: userinput })
    });
    const text = await response.text();
    res.send(`<h2>Result from backend: </h2>${text}`);
  } catch (e) {
    res.status(502).send(`Backend unavailable from frontend: ${environment}`);
  }
});

app.listen(80, () => console.log(`Frontend (${environment}) running on :80`));
