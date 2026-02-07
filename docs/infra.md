## DNS

Domain: domsamphier.com

Registrar:
- Vercel

DNS provider:
- Cloudflare

Hosting:
- Fly.io

Notes:
- Root domain cannot be served by Fly while using Vercel DNS due to enforced ALIAS records.
- Nameservers in Vercel point to Cloudflare.
- Cloudflare sends A + AAAA records directly to Fly.
