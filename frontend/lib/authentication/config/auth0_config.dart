/// Auth0 configuration
class Auth0Config {
  const Auth0Config._();

  /// Auth0 domain from environment or default
  /// Set this in your .env file or update with your Auth0 tenant domain
  static const String domain = String.fromEnvironment(
    'AUTH0_DOMAIN',
    defaultValue: 'your-tenant.auth0.com',
  );

  /// Auth0 client ID from environment or default
  /// Set this in your .env file or update with your Auth0 client ID
  static const String clientId = String.fromEnvironment(
    'AUTH0_CLIENT_ID',
    defaultValue: 'your-client-id',
  );

  /// Auth0 audience (API identifier)
  /// Set this in your .env file or update with your API identifier
  static const String audience = String.fromEnvironment(
    'AUTH0_AUDIENCE',
    defaultValue: 'https://your-api-identifier',
  );

  /// Auth0 scopes requested during authentication
  static const List<String> scopes = [
    'openid',
    'profile',
    'email',
    'offline_access', // For refresh tokens
  ];
}
