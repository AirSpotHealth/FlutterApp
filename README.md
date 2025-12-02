# AirSpot Health

A Flutter mobile application for monitoring CO2 levels using AirSpot devices.

## Features

- Real-time CO2 monitoring via Bluetooth
- Device management and settings
- Data visualization and charts
- Factory testing capabilities
- Map integration for data handoff
- iOS and Android support

## Quick Start

1. **Prerequisites**

   - Flutter SDK (3.6.1+)
   - Android Studio / Xcode
   - Valid API keys (contact team for access)

2. **Setup**

   ```bash
   # Quick setup (recommended)
   ./scripts/setup.sh

   # Or manual setup
   cp env.example .env
   cp android/key.properties.example android/key.properties
   # Edit with your values
   nano .env
   nano android/key.properties
   ```

3. **Run**
   ```bash
   # VS Code: Press F5 and select "AirSpot Health (Debug with Env)"
   # Command line:
   flutter run --dart-define-from-file=.env
   ```

## Development

See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) for detailed development setup and build instructions.

## Project Structure

```
├── lib/                    # Flutter source code
├── android/               # Android-specific files
├── ios/                   # iOS-specific files
├── scripts/               # Build and utility scripts
├── docs/                  # Documentation
├── env.example           # Environment variables template
└── .vscode/              # VS Code configuration
```

## Environment Variables

The app requires several environment variables for API keys and configuration. See `env.example` for the complete list.

## Security

This project uses environment variables for sensitive configuration. Never commit:

- `.env` files
- `android/key.properties`
- `android/upload-keystore.jks`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Set up your development environment using the guide in `docs/DEVELOPMENT.md`
4. Make your changes
5. Test thoroughly
6. Submit a pull request

## License

[Add your license information here]
