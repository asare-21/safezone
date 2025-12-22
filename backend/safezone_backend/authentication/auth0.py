"""
Auth0 JWT authentication backend for Django REST Framework.
"""
import jwt
import requests
from django.conf import settings
from rest_framework import authentication, exceptions
from functools import lru_cache
import logging

logger = logging.getLogger(__name__)


@lru_cache(maxsize=1)
def get_jwks():
    """
    Fetch and cache the JWKS (JSON Web Key Set) from Auth0.
    Cached to avoid repeated requests.
    """
    if not settings.AUTH0_DOMAIN:
        logger.debug("AUTH0_DOMAIN not configured, skipping JWKS fetch")
        return None
    
    jwks_url = f'https://{settings.AUTH0_DOMAIN}/.well-known/jwks.json'
    try:
        response = requests.get(jwks_url, timeout=5)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        logger.error(f"Failed to fetch JWKS: {e}")
        raise exceptions.AuthenticationFailed('Unable to fetch Auth0 public keys')


def get_public_key(token):
    """
    Extract the public key from JWKS based on the token's kid (key ID).
    """
    jwks = get_jwks()
    
    if jwks is None:
        raise exceptions.AuthenticationFailed('Auth0 not configured')
    
    # Decode token header without verification to get kid
    try:
        unverified_header = jwt.get_unverified_header(token)
    except jwt.DecodeError:
        raise exceptions.AuthenticationFailed('Invalid token header')
    
    # Find the matching key
    rsa_key = {}
    for key in jwks.get('keys', []):
        if key['kid'] == unverified_header['kid']:
            rsa_key = {
                'kty': key['kty'],
                'kid': key['kid'],
                'use': key['use'],
                'n': key['n'],
                'e': key['e']
            }
            break
    
    if not rsa_key:
        raise exceptions.AuthenticationFailed('Unable to find appropriate key')
    
    return jwt.algorithms.RSAAlgorithm.from_jwk(rsa_key)


class Auth0Authentication(authentication.BaseAuthentication):
    """
    Custom authentication class for Auth0 JWT tokens.
    """
    
    def authenticate(self, request):
        """
        Authenticate the request using Auth0 JWT token.
        Returns a tuple of (user, token) if authentication succeeds,
        or None if no authentication was attempted.
        """
        # If Auth0 is not configured, skip authentication
        if not settings.AUTH0_DOMAIN or not settings.AUTH0_AUDIENCE:
            logger.debug("Auth0 not configured, skipping authentication")
            return None
        
        # Extract token from Authorization header
        auth_header = request.META.get('HTTP_AUTHORIZATION', '')
        
        if not auth_header:
            return None
        
        parts = auth_header.split()
        
        if parts[0].lower() != 'bearer':
            return None
        
        if len(parts) == 1:
            raise exceptions.AuthenticationFailed('Invalid token header. No credentials provided.')
        elif len(parts) > 2:
            raise exceptions.AuthenticationFailed('Invalid token header. Token string should not contain spaces.')
        
        token = parts[1]
        
        # Verify and decode the token
        try:
            public_key = get_public_key(token)
            
            payload = jwt.decode(
                token,
                public_key,
                algorithms=['RS256'],
                audience=settings.AUTH0_AUDIENCE,
                issuer=f'https://{settings.AUTH0_DOMAIN}/'
            )
            
        except jwt.ExpiredSignatureError:
            raise exceptions.AuthenticationFailed('Token has expired')
        except jwt.InvalidAudienceError:
            raise exceptions.AuthenticationFailed('Invalid token audience')
        except jwt.InvalidIssuerError:
            raise exceptions.AuthenticationFailed('Invalid token issuer')
        except jwt.DecodeError:
            raise exceptions.AuthenticationFailed('Error decoding token')
        except Exception as e:
            logger.error(f"Token verification failed: {e}")
            raise exceptions.AuthenticationFailed('Token verification failed')
        
        # Create a user object with Auth0 sub (subject) as identifier
        user = Auth0User(payload)
        
        return (user, token)


class Auth0User:
    """
    Lightweight user object containing Auth0 token payload.
    """
    
    def __init__(self, payload):
        self.payload = payload
        self.sub = payload.get('sub')  # Auth0 user ID
        self.email = payload.get('email')
        self.is_authenticated = True
        self.is_anonymous = False
    
    @property
    def id(self):
        """Return the Auth0 subject as the user ID."""
        return self.sub
    
    def __str__(self):
        return f"Auth0User({self.sub})"
