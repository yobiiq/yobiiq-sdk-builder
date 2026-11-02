# Contributing to YOBIIQ SDK Builder

Thank you for your interest in contributing to the YOBIIQ SDK Builder project!

## How to Contribute

### Reporting Issues

- Use the GitHub issue tracker
- Provide detailed information about the problem
- Include Docker version, OS, and error messages
- Describe steps to reproduce

### Submitting Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Make your changes
4. Test that the Docker image builds successfully
5. Commit your changes (`git commit -m 'Add some feature'`)
6. Push to the branch (`git push origin feature/your-feature`)
7. Open a Pull Request

### Testing Changes

Before submitting a PR, please:

1. Build and verify the image locally:
   ```bash
   ./scripts/build-local.sh
   ```

2. Test building a sample application

## Code Style

- Use clear, descriptive comments
- Follow existing formatting conventions
- Keep Dockerfile layers organized and optimized

## Pull Request Guidelines

- Provide a clear description of the changes
- Reference any related issues
- Ensure CI checks pass
- Keep PRs focused on a single feature or fix

## Questions?

Feel free to open an issue for questions or discussions.
