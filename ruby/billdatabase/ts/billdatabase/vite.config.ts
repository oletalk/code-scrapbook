import { defineConfig } from "vite";
import path from "path";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  base: 'spa',
  resolve: {
    alias: {
      crypto: "empty-module",
    },
  },
  build: {
    outDir: path.join(__dirname, "../../public/spa"),
    emptyOutDir: true
  },
  define: {
    global: "globalThis",
  },
});