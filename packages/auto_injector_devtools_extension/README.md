# auto_injector_devtools_extension

## Run

```bash
flutter run -d chrome --dart-define=use_simulated_environment=true
```

### Launch Example (VSCode)

```json
    {
        "name": "auto_injector_devtools_extension",
        "request": "launch",
        "type": "dart",
        "args": [
            "--dart-define=use_simulated_environment=true"
        ]
    }
```

## Build

```bash
flutter pub get &&
dart run devtools_extensions build_and_copy \
    --source=. \
    --dest=../../extension/devtools
```