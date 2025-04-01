import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";
import fs from "fs";
import dotenv from "dotenv";
import process from "process";

// This function loads environment variables from project root .env files
function loadProjectEnv(mode) {
  // First, load Vite's own environment variables (they take precedence)
  const viteEnv = loadEnv(mode, process.cwd(), "");

  // Try to load from project root .env files based on mode
  let projectEnv = {};
  const rootEnvFile = `../.env.${mode.toLowerCase()}`;
  const defaultEnvFile = "../.env";

  try {
    // Try mode-specific env file first
    if (fs.existsSync(rootEnvFile)) {
      projectEnv = {
        ...projectEnv,
        ...dotenv.parse(fs.readFileSync(rootEnvFile)),
      };
    }
    // Fall back to default .env if it exists
    else if (fs.existsSync(defaultEnvFile)) {
      projectEnv = {
        ...projectEnv,
        ...dotenv.parse(fs.readFileSync(defaultEnvFile)),
      };
    }
  } catch (error) {
    console.warn("Error loading project environment variables:", error);
  }

  // Combine them, with Vite env taking precedence
  return { ...projectEnv, ...viteEnv };
}

export default defineConfig(({ command, mode }) => {
  // Load combined environment variables
  const env = loadProjectEnv(mode);

  // Get port settings from environment
  const devServerPort = parseInt(env.VITE_PORT || "5173");
  const backendPort =
    env.BACKEND_INTERNAL_PORT || (mode === "production" ? "8080" : "8090");
  const hostPort = env.HOST_PORT_FRONTEND || backendPort;

  // Build the backend URL
  const backendHost = env.BACKEND_HOST || "localhost";
  // Build the backend URL for local development proxying
  const backendUrl =
    mode === "production"
      ? `http://${backendHost}:${backendPort}` // In production, use internal port
      : `http://localhost:${hostPort}`; // In development, use host port

  return {
    plugins: [react()],
    root: ".",
    build: {
      outDir: "dist",
    },
    server: {
      port: devServerPort,
      proxy: {
        "/api": {
          target: backendUrl, // <- main Environment Variable for Dev or Prod PORT variation
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/api/, ""),
          secure: false,
          ws: true,
          configure: (proxy, _options) => {
            proxy.on("error", (err, _req, _res) => {
              console.log("proxy error", err);
            });
            proxy.on("proxyReq", (proxyReq, req, _res) => {
              console.log(
                "Sending Request to the Target:",
                req.method,
                req.url
              );
            });
            proxy.on("proxyRes", (proxyRes, req, _res) => {
              console.log(
                "Received Response from the Target:",
                proxyRes.statusCode,
                req.url
              );
            });
          },
        },
      },
    },
    define: {
      // Expose some env variables to the frontend code
      "import.meta.env.BACKEND_URL": JSON.stringify(backendUrl),
      "import.meta.env.APP_MODE": JSON.stringify(mode),
    },
  };
});
