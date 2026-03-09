const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello World!\n');
});

server.listen(8000, () => {
  console.log('Server running on port 8000');
  console.log('Press Ctrl+C to exit');
});

// 保持进程运行
process.stdin.resume();