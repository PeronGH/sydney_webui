# sydney_webui

Web UI for Sydney (Bing Chat).

## Getting Started

1. Deploy [backend](https://github.com/juzeon/SydneyQt/tree/v2/webapi).

2. `flutter run -d chrome`.

## Deploy to Serverless Platforms

The following build command can be used

```bash
if cd flutter; then git pull && cd .. ; else git clone https://github.com/flutter/flutter.git; fi && ls && flutter/bin/flutter doctor && flutter/bin/flutter clean && flutter/bin/flutter config --enable-web && flutter/bin/flutter build web --release --web-renderer canvaskit
```
