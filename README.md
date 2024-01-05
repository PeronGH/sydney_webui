# sydney_webui

Web UI for Sydney (Bing Chat).

## Getting Started

1. Deploy [backend](https://github.com/juzeon/SydneyQt/tree/v2/webapi).

2. `flutter run -d chrome`.

## Deploy to Cloudflare Pages

```bash
peanut -b production --web-renderer canvaskit --extra-args "--dart-define-from-file=config.json" && git push origin production:production
```
