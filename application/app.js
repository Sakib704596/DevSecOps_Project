const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;
const testKey = "AKIAZQ3XJ8FGH2K9P1M4";

// Root endpoint — just proves the app is alive
app.get('/', (req, res) => {
  res.json({ message: 'Cloud-Native DevSecOps Platform — sample app running' });
});

// Health endpoint — this is what Kubernetes will later use for liveness/readiness probes
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`App listening on port ${PORT}`);
  });
}

module.exports = app;

