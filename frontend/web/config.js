// Runtime configuration for Flutter web app
// 
// ⚠️ IMPORTANT: This file configures the API endpoint
// 
// DEFAULT SETUP (localhost):
//   - Works when accessing from the same machine running Docker
//   - Use this for local development and when sharing the project
//   - API_BASE_URL: "http://localhost:3000/api"
//
// NETWORK ACCESS (for other devices):
//   - To access from mobile or another computer on the same network
//   - Replace "localhost" with your machine's IP address
//   - Example: "http://192.168.1.100:3000/api"
//   - Use scripts/set-network-ip.ps1 or scripts/set-network-ip.js
//   - Don't forget to setup firewall (see scripts/setup-firewall.ps1)
//
// 📖 For detailed instructions, see: frontend/NETWORK_SETUP.md
//
window.ENV_CONFIG = {
  API_BASE_URL: "http://localhost:3000/api",
  SOCKET_URL: "http://localhost:3000",
  ENVIRONMENT: "development",
};
