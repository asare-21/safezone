/**
 * Authenticated fetch utility for making API requests with credentials
 * Automatically includes authentication headers and handles CORS with credentials
 */

import { API_CONFIG } from './api-config';

interface FetchOptions extends RequestInit {
  accessToken?: string;
}

/**
 * Custom fetch wrapper that includes credentials and authentication headers
 * This ensures all API requests include proper authentication
 */
export async function authenticatedFetch(
  url: string,
  options: FetchOptions = {}
): Promise<Response> {
  const { accessToken, headers = {}, ...restOptions } = options;

  // Build full URL if relative path provided
  const fullUrl = url.startsWith('http') ? url : `${API_CONFIG.baseUrl}${url}`;

  // Prepare headers with authentication
  const fetchHeaders: HeadersInit = {
    ...headers,
  };

  // Only set Content-Type if not already set and if we have a body
  // This allows requests like file uploads to set their own Content-Type
  if (!fetchHeaders['Content-Type'] && restOptions.body) {
    // Only set to JSON if body is a string (assumed to be JSON.stringify'd)
    if (typeof restOptions.body === 'string') {
      fetchHeaders['Content-Type'] = 'application/json';
    }
  }

  // Add Authorization header if access token is provided
  if (accessToken) {
    fetchHeaders['Authorization'] = `Bearer ${accessToken}`;
  }

  // Make request with credentials included
  // credentials: 'include' ensures cookies are sent with cross-origin requests
  const response = await fetch(fullUrl, {
    ...restOptions,
    headers: fetchHeaders,
    credentials: 'include', // Important: includes credentials in CORS requests
  });

  return response;
}

/**
 * Helper function to make GET requests
 */
export async function apiGet(
  url: string,
  accessToken?: string
): Promise<Response> {
  return authenticatedFetch(url, {
    method: 'GET',
    accessToken,
  });
}

/**
 * Helper function to make POST requests
 */
export async function apiPost(
  url: string,
  data: unknown,
  accessToken?: string
): Promise<Response> {
  return authenticatedFetch(url, {
    method: 'POST',
    body: JSON.stringify(data),
    accessToken,
  });
}

/**
 * Helper function to make PUT requests
 */
export async function apiPut(
  url: string,
  data: unknown,
  accessToken?: string
): Promise<Response> {
  return authenticatedFetch(url, {
    method: 'PUT',
    body: JSON.stringify(data),
    accessToken,
  });
}

/**
 * Helper function to make PATCH requests
 */
export async function apiPatch(
  url: string,
  data: unknown,
  accessToken?: string
): Promise<Response> {
  return authenticatedFetch(url, {
    method: 'PATCH',
    body: JSON.stringify(data),
    accessToken,
  });
}

/**
 * Helper function to make DELETE requests
 */
export async function apiDelete(
  url: string,
  accessToken?: string
): Promise<Response> {
  return authenticatedFetch(url, {
    method: 'DELETE',
    accessToken,
  });
}
