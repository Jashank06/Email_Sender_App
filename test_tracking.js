const http = require('http');

const trackingId = '532dedc4-bdec-4843-a7df-2c54cb52dd82';
const url = `http://localhost:3000/track/open/${trackingId}`;

console.log(`Simulating tracking request to: ${url}`);

http.get(url, (res) => {
    console.log(`Status Code: ${res.statusCode}`);
    console.log(`Headers:`, res.headers);

    let data = '';
    res.on('data', (chunk) => {
        data += chunk;
    });

    res.on('end', () => {
        console.log('Request completed');
        console.log('Pixel received (base64 snippet):', Buffer.from(data).toString('base64').substring(0, 50));
    });
}).on('error', (err) => {
    console.error('Error:', err.message);
    console.log('Make sure the server is running with "npm run server"');
});
