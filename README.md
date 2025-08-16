# SUI Magical Garden 

## SUI Magical Garden is a Move-based smart contract for the Sui blockchain that allows users to create, nurture, and manage magical plants with elemental properties. Each plant has unique characteristics, growth stages, and special abilities that make collecting and caring for them an engaging experience.
## El Jardín Mágico SUI es un contrato inteligente basado en Move para la blockchain de Sui que permite a los usuarios crear, cuidar y gestionar plantas mágicas con propiedades elementales. Cada planta tiene características únicas, etapas de crecimiento y habilidades especiales que hacen que coleccionarlas y cuidarlas sea una experiencia atractiva.

### Características principales ✨

🌿 Crear y gestionar plantas mágicas

🌈 Plantas con 6 tipos de magia elemental

🌱 5 etapas de crecimiento realistas

💧 Sistema de riego con cooldown

📜 Mensajes secretos para plantas raras

🔄 Transferencia de plantas entre usuarios

📡 Metadatos para Move Registry

### Pre-requisitos 📋

Instalar Sui CLI

Crear una wallet: sui client new-address ed25519

Obtener tokens de testnet: Sui Faucet

Estructura del proyecto 📂

sui_magical_garden/
├── README.md             # Documentación
├── sources/
│   └── sui_magical_garden.move      # Código principal
└── Move.toml             # Configuración

### Instalación y ejecución 🚀

Clonar repositorio:

bash
git clone https://github.com/danielas-tochi/sui_magical_garden.git

cd sui_magical_garden

### Compilar el proyecto:

bash
sui move build

### Ejecutar pruebas:

bash
sui move test

### Comandos para probar desde terminal 🧪

Crear una planta:

bash

sui client call --function create_plant_entry \
--module garden \
--package <PACKAGE_ID> \
--args "Mi Planta" 0 true \  # Nombre, tipo (0=Fuego), rareza


Regar una planta:

bash

sui client call --function water_plant_entry \
--module garden \
--package <PACKAGE_ID> \
--args <PLANT_ID> $(date +%s)000 \  # Timestamp actual


Revelar secreto:

bash

sui client call --function reveal_secret_entry \
--module garden \
--package <PACKAGE_ID> \
--args <PLANT_ID> \


Transferir planta:

bash

sui client call --function transfer_plant_entry \
--module garden \
--package <PACKAGE_ID> \
--args <PLANT_ID> <RECIPIENT_ADDRESS> \


Ver metadatos del módulo:

bash

sui client object <METADATA_OBJECT_ID>

### Pruebas antes de mainnet ✅

Pruebas unitarias:

bash

sui move test

### Pruebas en testnet:

bash
### Configurar wallet y red
### Desplegar en testnet

sui client publish 

# Crear planta de prueba

sui client call --function create_plant_entry \
--module garden \
--package <PACKAGE_ID> \
--args "Planta Test" 1 false \


# Verificar objeto creado

sui client object <PLANT_ID>

### Pruebas de simulación:

bash

# Simular creación de planta
sui client call --function create_plant_entry \
--module garden \
--package <PACKAGE_ID> \
--args "Simulación" 2 true \
--gas-budget 10000000 \
--dry-run

### Verificar eventos:

bash
Después de varias interacciones
sui client events --query "MoveModule:garden"
Pruebas de carga:

bash
### Script para crear múltiples plantas
for i in {1..5}; do
  sui client call --function create_plant_entry \
  --module garden \
  --package <PACKAGE_ID> \
  --args "Planta $i" $((RANDOM % 6)) $((RANDOM % 2)) \
  

**English:**
- Built with Move language for Sui blockchain
- Inspired by digital pet and farming game mechanics

**Español:**
- Construido con el lenguaje Move para la blockchain de Sui
- Inspirado en mecánicas de mascotas digitales y juegos de cultivo

---

*Made with ❤️ for the Sui ecosystem / Hecho con ❤️ para el ecosistema Sui*
