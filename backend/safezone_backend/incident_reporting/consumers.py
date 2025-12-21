import json
from channels.generic.websocket import AsyncWebsocketConsumer


class IncidentConsumer(AsyncWebsocketConsumer):
    """WebSocket consumer for real-time incident updates."""

    async def connect(self):
        """Handle WebSocket connection."""
        # Join the incidents group
        self.group_name = 'incidents'
        
        await self.channel_layer.group_add(
            self.group_name,
            self.channel_name
        )
        
        await self.accept()

    async def disconnect(self, close_code):
        """Handle WebSocket disconnection."""
        # Leave the incidents group
        await self.channel_layer.group_discard(
            self.group_name,
            self.channel_name
        )

    async def receive(self, text_data):
        """Handle messages from WebSocket (currently not used)."""
        pass

    async def incident_update(self, event):
        """Handle incident update events from the channel layer."""
        # Send the incident data to the WebSocket
        await self.send(text_data=json.dumps({
            'type': 'incident_update',
            'incident': event['incident']
        }))
