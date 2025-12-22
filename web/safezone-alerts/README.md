# SafeZone Website

## Project info

This is the marketing/portfolio website for the SafeZone project, built with React, TypeScript, Vite, and shadcn-ui.

**Repository**: https://github.com/asare-21/safezone

## How can I edit this code?

There are several ways of editing this website.

**Use your preferred IDE**

If you want to work locally using your own IDE, you can clone this repo and push changes.

The only requirement is having Node.js & npm installed - [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating)

Follow these steps:

```sh
# Step 1: Clone the repository
git clone https://github.com/asare-21/safezone.git

# Step 2: Navigate to the web directory
cd safezone/web/safezone-alerts

# Step 3: Install the necessary dependencies
npm install

# Step 4: Start the development server with auto-reloading and an instant preview
npm run dev
```

**Edit a file directly in GitHub**

- Navigate to the desired file(s).
- Click the "Edit" button (pencil icon) at the top right of the file view.
- Make your changes and commit the changes.

**Use GitHub Codespaces**

- Navigate to the main page of the repository.
- Click on the "Code" button (green button) near the top right.
- Select the "Codespaces" tab.
- Click on "New codespace" to launch a new Codespace environment.
- Edit files directly within the Codespace and commit and push your changes once you're done.

## What technologies are used for this project?

This website is built with:

- Vite
- TypeScript
- React
- shadcn-ui
- Tailwind CSS
- Framer Motion (animations)

## How can I deploy this project?

You can deploy this website using various hosting platforms:

- **Vercel**: Connect your GitHub repository and deploy automatically
- **Netlify**: Similar to Vercel, supports automatic deployments
- **GitHub Pages**: Free hosting for static sites
- **Custom hosting**: Build with `npm run build` and deploy the `dist` folder

## Building for production

```bash
npm run build
```

The production-ready files will be in the `dist` directory.

## Project Structure

- `src/components/` - React components including sections and UI elements
- `src/pages/` - Page components
- `src/lib/` - Utility functions including API client with authentication
- `public/` - Static assets

## API Integration & Authentication

This application includes built-in support for making authenticated API requests to the SafeZone backend.

### Quick Start

1. Copy the example environment file:
   ```bash
   cp .env.example .env.local
   ```

2. Configure your API and Auth0 settings in `.env.local`

3. Use the provided API client utilities:
   ```typescript
   import { apiGet, apiPost } from '@/lib/api-client';
   
   // Make authenticated API requests
   const response = await apiGet('/api/endpoint', accessToken);
   ```

### Features

- ✅ Automatic inclusion of credentials in requests (`credentials: 'include'`)
- ✅ Bearer token authentication support
- ✅ CORS-compliant request handling
- ✅ TypeScript support with proper types
- ✅ Helper functions for GET, POST, PUT, PATCH, DELETE

For detailed authentication setup and usage, see [AUTH_SETUP.md](./AUTH_SETUP.md).
