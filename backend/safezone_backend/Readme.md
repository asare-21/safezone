# SafeZone Backend

Django REST API backend for the SafeZone application.

## Quick Start

1. Create virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run migrations:
   ```bash
   python manage.py migrate
   ```

4. Start development server:
   ```bash
   python manage.py runserver
   ```

## Heroku Deployment

### Prerequisites
- [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) installed
- Heroku account

### Deploy to Heroku

1. Create a Heroku app:
   ```bash
   heroku create your-app-name
   ```

2. Add PostgreSQL addon:
   ```bash
   heroku addons:create heroku-postgresql:essential-0
   ```

3. Set required environment variables:
   ```bash
   heroku config:set DJANGO_SECRET_KEY='your-secure-secret-key'
   heroku config:set DJANGO_DEBUG=False
   heroku config:set DJANGO_ALLOWED_HOSTS=your-app-name.herokuapp.com
   heroku config:set FIELD_ENCRYPTION_KEY='your-fernet-key'
   ```

   Generate a Fernet key with:
   ```bash
   python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
   ```

4. Deploy:
   ```bash
   git subtree push --prefix backend/safezone_backend heroku main
   ```

   Or if deploying from the repository root:
   ```bash
   git push heroku main
   ```

### Environment Variables

See `.env.example` for all available configuration options.

Key variables for Heroku:
- `DJANGO_SECRET_KEY` - Django secret key (required)
- `DJANGO_DEBUG` - Set to `False` for production
- `DJANGO_ALLOWED_HOSTS` - Your Heroku app domain
- `DATABASE_URL` - Automatically set by Heroku Postgres
- `FIELD_ENCRYPTION_KEY` - Fernet encryption key for sensitive data

## Running Tests

```bash
python manage.py test
```
