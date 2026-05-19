# Frontend - Aplicación Web con Flask
## Innovatech Chile — Evaluación Parcial N°2

![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.11-3776AB?style=flat&logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-2.3-000000?style=flat&logo=flask&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI/CD-2088FF?style=flat&logo=github-actions&logoColor=white)

---

## Descripción

Frontend desarrollado en Python con Flask. Proporciona una interfaz web completa para la gestión de usuarios, comunicándose con el Backend API mediante peticiones HTTP REST. Desplegado en AWS EC2 en subred pública mediante contenedores Docker con pipeline CI/CD automatizado a través de GitHub Actions.

---

## Arquitectura

```
Internet → EC2 Frontend (Flask) → EC2 Backend (Node.js) → EC2 Data (MySQL)
           Puerto 80/5000              Puerto 3000              Puerto 3306
           Subred pública              Subred privada           Subred privada
```

Este servicio opera en la **subred pública** de AWS y es el único punto de acceso desde internet hacia el sistema.

---

## Tecnologías utilizadas

| Tecnología | Versión | Uso |
|---|---|---|
| Python | 3.11 | Runtime |
| Flask | ^2.3.3 | Framework web |
| Flask-CORS | ^4.0.0 | Middleware CORS |
| requests | ^2.31.0 | Peticiones HTTP al Backend |
| python-dotenv | ^1.0.0 | Variables de entorno |
| Jinja2 | ^3.1.2 | Motor de plantillas HTML |
| Docker | latest | Contenedorización |
| GitHub Actions | — | CI/CD pipeline |

---

## Funcionalidades

### Páginas disponibles

| Ruta | Descripción |
|---|---|
| `/` | Lista todos los usuarios |
| `/crear` | Formulario para crear usuario |
| `/editar/<id>` | Formulario para editar usuario |
| `/eliminar/<id>` | Eliminar usuario |

---

## Estructura del proyecto

```
Front_Eval2/
├── app.py                         # Aplicación principal Flask
├── requirements.txt               # Dependencias Python
├── Dockerfile                     # Imagen Docker multi-stage
├── docker-compose.yml             # Stack de servicios
├── .env.example                   # Ejemplo de variables de entorno
├── .env                           # Variables de entorno (no incluir en git)
├── templates/                     # Plantillas HTML
│   ├── base.html                  # Plantilla base
│   ├── index.html                 # Página principal
│   ├── crear_usuario.html         # Formulario crear usuario
│   ├── editar_usuario.html        # Formulario editar usuario
│   ├── 404.html                   # Página error 404
│   └── 500.html                   # Página error 500
├── .github/
│   └── workflows/
│       └── deploy.yml             # Pipeline CI/CD GitHub Actions
└── README.md                      # Este archivo
```

---

## Contenedorización

### Dockerfile (Multi-stage build)

El Dockerfile implementa un **multi-stage build** para optimizar el tamaño de la imagen:

- **Stage 1 (builder):** Instala dependencias Python con pip
- **Stage 2 (production):** Copia solo lo necesario, ejecuta con usuario no root

Beneficios:
- Imagen final más liviana sin herramientas de compilación
- Usuario no root (`appuser`) para mayor seguridad
- Capas optimizadas para mejor uso de caché

### docker-compose.yml

Define el stack con:
- Servicio `frontend` mapeando puerto 80 → 5000
- Variables de entorno para conexión con Backend
- Red interna `innovatech-network`

---

## Persistencia de datos

El Frontend no maneja persistencia propia ya que es una capa de presentación. La persistencia de datos se gestiona en la capa **Data (MySQL)** mediante volúmenes Docker definidos en el Backend y Data.

---

## Pipeline CI/CD

El pipeline de GitHub Actions se activa automáticamente con cada `push` a la rama `deploy`:

```
push a rama deploy
        ↓
1. BUILD  → Construye la imagen Docker
        ↓
2. PUSH   → Publica en Docker Hub (patatan7/frontend-innovatech:latest)
        ↓
3. DEPLOY → Conecta por SSH a EC2 Frontend → despliega contenedor
```

### GitHub Secrets requeridos

| Secret | Descripción |
|---|---|
| `DOCKERHUB_USERNAME` | Usuario de Docker Hub |
| `DOCKERHUB_TOKEN` | Token de acceso Docker Hub |
| `EC2_HOST` | IP pública del Frontend (Elastic IP) |
| `EC2_USER` | Usuario SSH (ec2-user) |
| `EC2_SSH_KEY` | Llave privada SSH (.pem) |
| `BACKEND_URL` | URL del Backend API |
| `SECRET_KEY` | Clave secreta Flask para sesiones |

---

## Configuración local

### Prerrequisitos

- Python 3.11+
- Docker Desktop
- Backend API corriendo

### Instalación

```bash
# Clonar el repositorio
git clone https://github.com/TU_USUARIO/Front_Eval2
cd Front_Eval2

# Crear entorno virtual
python -m venv venv

# Activar entorno virtual
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt

# Copiar variables de entorno
cp .env.example .env
# Editar .env con tu configuración
```

### Variables de entorno

```env
PORT=5000
DEBUG=False
BACKEND_URL=http://localhost:3000
SECRET_KEY=clave_secreta_segura
```

### Ejecución local

```bash
# Desarrollo
python app.py

# Con Docker
docker-compose up -d
```

---

## Despliegue en AWS EC2

### Requisitos previos en la instancia

```bash
sudo yum update -y
sudo yum install -y docker git
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user
```

### Despliegue manual

```bash
docker pull patatan7/frontend-innovatech:latest
docker run -d \
  --name frontend-innovatech \
  --restart always \
  -p 80:5000 \
  -e PORT=5000 \
  -e DEBUG=False \
  -e BACKEND_URL=http://<IP_PRIVADA_BACKEND>:3000 \
  -e SECRET_KEY=<SECRET_KEY> \
  patatan7/frontend-innovatech:latest
```

### Acceso

Una vez desplegado, la aplicación es accesible desde:
```
http://<IP_PUBLICA_FRONTEND>
```

---

## Principios DevOps aplicados

- **Contenedorización:** Docker con multi-stage build y usuario no root
- **CI/CD:** Pipeline automatizado con GitHub Actions
- **Control de versiones:** Git con rama `deploy` como trigger
- **Infraestructura segura:** Subred pública con Security Groups restrictivos
- **Mínimo privilegio:** Solo el Frontend expuesto a internet
- **Jump Host:** El Frontend actúa como bastión para acceso al Backend privado
