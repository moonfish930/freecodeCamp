import http from 'http';
import fs from 'fs';
import { WebSocketServer } from 'ws';
import path from 'path'
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PORT = 3001;

const server = http.createServer((req, res) => {
  fs.readFile(path.join(__dirname, 'public', 'index.html'), (err, data) => {
    if (err) {
      res.writeHead(500, { 'Content-Type': 'text/plain' });
      res.end('Internal Server Error');
      return;
    }
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(data);
  });
});

const wss = new WebSocketServer({ server });

wss.on('connection', (socket, req) => {
  const username = new URL(req.url, 'http://localhost').searchParams.get('username') || 'Anonymous';

  // Broadcast system message: user joined
  const joinMessage = JSON.stringify({ type: 'system', text: `${username} joined` });
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(joinMessage);
    }
  });

  socket.on('message', (data) => {
    try {
      const { username: msgUsername, text } = JSON.parse(data);
      const chatMessage = JSON.stringify({ type: 'chat', username: msgUsername, text });
      wss.clients.forEach((client) => {
        if (client.readyState === WebSocket.OPEN) {
          client.send(chatMessage);
        }
      });
    } catch (err) {
      // Ignore invalid JSON
    }
  });

  socket.on('close', () => {
    const leaveMessage = JSON.stringify({ type: 'system', text: `${username} left` });
    wss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(leaveMessage);
      }
    });
  });
});

server.listen(PORT, () => {
  console.log('Chat server running at http://localhost:3001');
});