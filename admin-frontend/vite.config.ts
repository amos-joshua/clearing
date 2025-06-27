import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  return {
    plugins: [react()],
    optimizeDeps: {
      //exclude: ['lucide-react'],
    },
    server: {
      host: true, 
    },
    define: {
      __APP_ENV__: JSON.stringify(mode),
    },
  };
});
