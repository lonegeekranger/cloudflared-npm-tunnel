# 🌐 cloudflared-npm-tunnel

Automatiza el levantamiento de un túnel seguro con **Cloudflare Tunnel** en segundos usando Docker, Alpine y el binario oficial de `cloudflared`. Este contenedor configura todo por ti: inicia sesión, crea el túnel, asigna el subdominio, y lo deja corriendo listo para usar con Nginx Proxy Manager (u otro servicio local).

---

## ✅ Requisitos previos

Antes de ejecutar este contenedor necesitas:

1. Una cuenta en [Cloudflare](https://dash.cloudflare.com/).
2. Un dominio registrado en Cloudflare.
3. Un volumen Docker creado para persistencia:
   ```bash
   docker volume create cloudflared-npm-data
   ```

---

## ⚙️ Variables de entorno

| Variable     | Descripción                                                                              | Obligatoria |
| ------------ | ---------------------------------------------------------------------------------------- | ----------- |
| `NPM_DOMAIN` | Dominio completo registrado en Cloudflare (ej. `tunnel.midominio.com`)                   | ✅          |
| `NPM_IP`     | IP interna del servicio a exponer (ej. `192.168.0.3`)                                    | ✅          |
| `NPM_PORT`   | Puerto del servicio (ej. `8080`)                                                         | ✅          |
| `WIPE`       | Si es `"true"`, limpia toda configuración previa (opcional, útil para resetear el túnel) | ❌          |

---

## 🐳 Ejemplo de uso (modo terminal)

```bash
docker run --rm -it   -e NPM_DOMAIN=tunnel.midominio.com   -e NPM_IP=192.168.0.3   -e NPM_PORT=8080   -v cloudflared-npm-data:/home/app/data   cloudflared-npm-tunnel
```

La primera vez te pedirá abrir una URL para autenticar el contenedor con tu cuenta de Cloudflare. Ese paso es necesario solo una vez.

---

## 🧠 ¿Qué hace internamente?

1. Verifica que las variables estén presentes.
2. Descarga `cloudflared` si no existe.
3. Realiza `tunnel login` si es la primera vez.
4. Crea un túnel llamado `npm` (o lo recrea si ya existe).
5. Configura `/home/app/data/config.yml` con el ID del túnel.
6. Asocia el túnel con el dominio indicado (`NPM_DOMAIN`).
7. Lanza el túnel apuntando al servicio que defines con IP y puerto.

---

## 📂 Estructura del volumen

Se espera que el volumen contenga:

- `.cloudflared/` → Certificados y credenciales.
- `config.yml` → Configuración del túnel.
- `.initialized` → Marca que ya se ejecutó la configuración inicial.
- `cloudflared` → Binario descargado.

Puedes montar ese volumen en cualquier host para reutilizar la configuración.

---

## 🛠️ Docker Compose (opcional)

Aquí tienes un ejemplo usando `docker-compose.yml`:

```yaml
version: "3.8"

services:
  cloudflared-npm:
    image: cloudflared-npm-tunnel
    container_name: cloudflared-npm
    environment:
      - NPM_DOMAIN=tunnel.midominio.com
      - NPM_IP=172.30.0.3
      - NPM_PORT=8080
    volumes:
      - cloudflared-npm-data:/home/app/data
    restart: unless-stopped
    tty: true
    stdin_open: true

volumes:
  cloudflared-npm-data:
```

---

## 🧹 Resetear configuración

Si necesitas eliminar todo y partir de cero:

```bash
docker run --rm -it   -e NPM_DOMAIN=...   -e NPM_IP=...   -e NPM_PORT=...   -e WIPE=true   -v cloudflared-npm-data:/home/app/data   cloudflared-npm-tunnel
```

---

## ❓ Preguntas frecuentes

### ¿Puedo usar HTTPS en lugar de HTTP?

Sí. Solo asegúrate de que el servicio local tenga soporte para HTTPS y modifica la última línea del script `run.sh` para usar `https://` en lugar de `http://`.

---

### ¿Funciona con múltiples túneles?

Este contenedor está diseñado para un único túnel llamado `npm`. Si necesitas múltiples túneles, puedes duplicar el contenedor con variables distintas y usar diferentes volúmenes y nombres de túneles.

---

### ¿Cómo persiste la autenticación con Cloudflare?

Una vez autenticado con `tunnel login`, el archivo `cert.pem` queda almacenado en el volumen Docker (`.cloudflared/`). Mientras no lo borres, no necesitarás volver a autenticarte.

---

## 🧪 Compatibilidad de arquitectura

Por defecto, el contenedor descarga el binario ARM64 de `cloudflared`. Si lo necesitas para otra arquitectura (como `amd64`), puedes:

1. Modificar el script `run.sh` para descargar el binario correspondiente.
2. O construir tu propia imagen con el binario deseado precargado.

---

## 🤝 Contribuciones

¡Pull requests y mejoras son bienvenidas! Puedes sugerir:

- Soporte multi-arquitectura (`amd64`, `arm64`, etc.).
- Validaciones más robustas.
- Uso de tokens en lugar de login interactivo.
- Soporte para múltiples túneles o balanceadores.

---

## 🔐 Seguridad

Este contenedor descarga binarios desde GitHub Releases. Para mayor control puedes construir tu propia imagen local con el binario firmado por Cloudflare.

---

## 👤 Autor

Proyecto creado por [tu nombre o usuario de GitHub].

---

## 🧾 Licencia

Este proyecto está licenciado bajo la [MIT License](LICENSE).
