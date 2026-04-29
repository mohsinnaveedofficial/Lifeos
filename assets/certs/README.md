Place your server public certificate(s) in PEM format in this folder and include them in the final bundle.

Example filename: server_cert.pem

Do NOT commit private keys. Only the server public certificate in PEM format is required.

Usage:
- The application will attempt to load `assets/certs/server_cert.pem` at runtime.
- In CI, ensure you add the PEM to the repository or to the build pipeline securely.

