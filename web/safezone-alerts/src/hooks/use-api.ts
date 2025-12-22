/**
 * Example React hooks demonstrating how to use the authenticated API client
 * with React Query for data fetching
 */

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiGet, apiPost, apiPut, apiDelete } from '@/lib/api-client';

/**
 * Example: Fetch incidents from the API
 * 
 * Usage:
 * ```tsx
 * function IncidentsList() {
 *   const accessToken = 'your-auth0-token'; // Get from Auth0 hook
 *   const { data, isLoading, error } = useIncidents(accessToken);
 *   
 *   if (isLoading) return <div>Loading...</div>;
 *   if (error) return <div>Error: {error.message}</div>;
 *   
 *   return (
 *     <ul>
 *       {data?.map(incident => (
 *         <li key={incident.id}>{incident.title}</li>
 *       ))}
 *     </ul>
 *   );
 * }
 * ```
 */
export function useIncidents(accessToken?: string) {
  return useQuery({
    queryKey: ['incidents', accessToken],
    queryFn: async () => {
      const response = await apiGet('/api/incidents/', accessToken);
      
      if (!response.ok) {
        throw new Error(`Failed to fetch incidents: ${response.statusText}`);
      }
      
      return response.json();
    },
    enabled: !!accessToken, // Only run query if we have a token
  });
}

/**
 * Example: Create a new incident
 * 
 * Usage:
 * ```tsx
 * function CreateIncidentForm() {
 *   const accessToken = 'your-auth0-token';
 *   const createIncident = useCreateIncident(accessToken);
 *   
 *   const handleSubmit = (data) => {
 *     createIncident.mutate(data, {
 *       onSuccess: () => {
 *         console.log('Incident created successfully!');
 *       },
 *       onError: (error) => {
 *         console.error('Failed to create incident:', error);
 *       }
 *     });
 *   };
 *   
 *   return <form onSubmit={handleSubmit}>...</form>;
 * }
 * ```
 */
export function useCreateIncident(accessToken?: string) {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (incidentData: Record<string, unknown>) => {
      const response = await apiPost('/api/incidents/', incidentData, accessToken);
      
      if (!response.ok) {
        throw new Error(`Failed to create incident: ${response.statusText}`);
      }
      
      return response.json();
    },
    onSuccess: () => {
      // Invalidate incidents query to refetch the list
      queryClient.invalidateQueries({ queryKey: ['incidents'] });
    },
  });
}

/**
 * Example: Update an existing incident
 */
export function useUpdateIncident(accessToken?: string) {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async ({ 
      id, 
      data 
    }: { 
      id: string | number; 
      data: Record<string, unknown> 
    }) => {
      const response = await apiPut(`/api/incidents/${id}/`, data, accessToken);
      
      if (!response.ok) {
        throw new Error(`Failed to update incident: ${response.statusText}`);
      }
      
      return response.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['incidents'] });
    },
  });
}

/**
 * Example: Delete an incident
 */
export function useDeleteIncident(accessToken?: string) {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (id: string | number) => {
      const response = await apiDelete(`/api/incidents/${id}/`, accessToken);
      
      if (!response.ok) {
        throw new Error(`Failed to delete incident: ${response.statusText}`);
      }
      
      return response.ok;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['incidents'] });
    },
  });
}

/**
 * Example: Fetch user alerts
 */
export function useAlerts(accessToken?: string) {
  return useQuery({
    queryKey: ['alerts', accessToken],
    queryFn: async () => {
      const response = await apiGet('/api/alerts/', accessToken);
      
      if (!response.ok) {
        throw new Error(`Failed to fetch alerts: ${response.statusText}`);
      }
      
      return response.json();
    },
    enabled: !!accessToken,
  });
}

/**
 * Example: Fetch safety guides
 */
export function useGuides(accessToken?: string) {
  return useQuery({
    queryKey: ['guides', accessToken],
    queryFn: async () => {
      const response = await apiGet('/api/guides/', accessToken);
      
      if (!response.ok) {
        throw new Error(`Failed to fetch guides: ${response.statusText}`);
      }
      
      return response.json();
    },
    enabled: !!accessToken,
  });
}
