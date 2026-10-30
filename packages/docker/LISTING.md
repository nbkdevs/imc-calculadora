# Docker Hub listing: iamnazzal/imc-calculadora

| Field | Value |
|---|---|
| Registry | Docker Hub |
| Name | `iamnazzal/imc-calculadora` (checked free via hub.docker.com v2 API on 2026-10-30) |
| Version | 1.0.0 (+ latest) |
| Licence | MIT |
| Homepage | https://imccalculadora.app/ |
| Repository | https://github.com/nbkdevs/imc-calculadora (directory `packages/docker`) |
| Planned URL | https://hub.docker.com/r/iamnazzal/imc-calculadora |
| OCI labels | image.url and image.documentation = https://imccalculadora.app/ |
| Anchor used | [Calculadora IMC](https://imccalculadora.app/) (README Links section; paste the README as the Hub overview) |

**Short description (≤100 chars):** BMI (IMC) API + bilingual calculator page with WHO classes and healthy-weight range

**Publish (not run, needs the owner's OK):** `cd packages && docker build -f docker/Dockerfile -t iamnazzal/imc-calculadora:1.0.0 -t iamnazzal/imc-calculadora:latest . && docker push --all-tags iamnazzal/imc-calculadora` (or a daemonless go-containerregistry push, as for Turbo Luxury).

**Dry-run (30 Oct 2026, PKT):** `node --test` pass. The box has no Docker daemon, so the image was built daemonless with go-containerregistry (not pushed): base `node:22-alpine` + one app layer, same config as the Dockerfile (USER node, WORKDIR /app, port 8080, HEALTHCHECK, OCI labels). amd64 and arm64 built. A real `docker build` was not run.

Daemonless build result (30 Oct 2026, 18:33 PKT): amd64 `sha256:55e53ee1e9af237c8d8dad16e757145f2c39892372001f7f70be65b1eb8edd42`, arm64 `sha256:d20915a90b3f6dbd42e7edb594a364f5f3a439c28f41100630e635a2d29bfb58` (about 61 MB tar each, box-only at /tmp/ocib/imc-out/). Smoke test of the app layer with node: `/api/imc?peso=70,5&altura=1,68` → 25.0 Sobrepeso, `/` → 200, `/healthz` → ok. Not pushed.
