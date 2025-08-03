const express = require('express');
const app = express();
app.use(express.json());

app.get('/orgs/:owner/teams/:team_slug/memberships/:user', (req, res) => {
  console.log(`Mock intercepted: GET /orgs/${req.params.owner}/teams/${req.params.team_slug}/memberships/${req.params.user}`);
  console.log('Request headers:', JSON.stringify(req.headers));

  // Simulate different responses based on user, team_slug, or owner
  if (req.params.user === 'test-user' && req.params.team_slug === 'test-team' && req.params.owner === 'test-owner') {
    res.status(200).json({ state: 'active', role: 'member' });
  } else {
    res.status(404).json({ message: 'Not Found' });
  }
});

app.listen(3000, () => {
  console.log('Mock server listening on http://127.0.0.1:3000...');
});
