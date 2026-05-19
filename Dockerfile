# ================================
# Stage 1: Builder
# ================================
FROM python:3.11-alpine AS builder

WORKDIR /app

# Instalar dependencias del sistema necesarias
RUN apk add --no-cache gcc musl-dev

# Copiar solo requirements primero (optimiza cache)
COPY requirements.txt .

# Instalar dependencias Python
RUN pip install --no-cache-dir --user -r requirements.txt

# ================================
# Stage 2: Production
# ================================
FROM python:3.11-alpine AS production

# Crear usuario no root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copiar dependencias instaladas desde builder
COPY --from=builder /root/.local /home/appuser/.local

# Copiar código fuente
COPY . .

# Asignar permisos
RUN chown -R appuser:appgroup /app

# Cambiar a usuario no root
USER appuser

# Asegurar que los scripts de pip estén en el PATH
ENV PATH=/home/appuser/.local/bin:$PATH

# Puerto del Frontend Flask
EXPOSE 5000

# Comando de inicio
CMD ["python", "app.py"]