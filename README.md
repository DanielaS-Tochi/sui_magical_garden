🌿 Magical Garden en Sui - Proyecto Backend
Un jardín mágico donde las plantas cobran vida con propiedades únicas basadas en elementos naturales. Cada planta evoluciona a través de diferentes etapas y revela mensajes secretos al florecer.

Características principales ✨
🌈 Plantas con 6 tipos de magia elemental

🌱 5 etapas de crecimiento realistas

💧 Sistema de riego con cooldown

📜 Mensajes secretos para plantas raras

🔄 Transferencia de plantas entre usuarios

📡 Metadatos para Move Registry

Pre-requisitos 📋
Instalar Sui CLI

Crear una wallet: sui client new-address ed25519

Obtener tokens de testnet: Sui Faucet

Estructura del proyecto 📂
text
sui_magical_garden/
├── sources/
│   └── garden.move      # Código principal
└── Move.toml             # Configuración
Instalación y ejecución 🚀
Clonar repositorio:

bash
git clone https://github.com/tu-usuario/sui_magical_garden.git
cd sui_magical_garden
Compilar el proyecto:

bash
sui move build
Ejecutar pruebas:

bash
sui move test
Comandos para probar desde terminal 🧪
Crear una planta:

bash
sui client call --function create_plant_entry \
--module garden \
--package <PACKAGE_ID> \
--args "Mi Planta" 0 true \  # Nombre, tipo (0=Fuego), rareza
--gas-budget 10000000
Regar una planta:

bash
sui client call --function water_plant_entry \
--module garden \
--package <PACKAGE_ID> \
--args <PLANT_ID> $(date +%s)000 \  # Timestamp actual
--gas-budget 10000000
Revelar secreto:

bash
sui client call --function reveal_secret_entry \
--module garden \
--package <PACKAGE_ID> \
--args <PLANT_ID> \
--gas-budget 10000000
Transferir planta:

bash
sui client call --function transfer_plant_entry \
--module garden \
--package <PACKAGE_ID> \
--args <PLANT_ID> <RECIPIENT_ADDRESS> \
--gas-budget 10000000
Ver metadatos del módulo:

bash
sui client object <METADATA_OBJECT_ID>
Pruebas antes de mainnet ✅
Pruebas unitarias:

bash
sui move test
Pruebas en testnet:

bash
# Desplegar en testnet
sui client publish --gas-budget 100000000

# Crear planta de prueba
sui client call --function create_plant_entry \
--module garden \
--package <PACKAGE_ID> \
--args "Planta Test" 1 false \
--gas-budget 10000000

# Verificar objeto creado
sui client object <PLANT_ID>
Pruebas de simulación:

bash
# Simular creación de planta
sui client call --function create_plant_entry \
--module garden \
--package <PACKAGE_ID> \
--args "Simulación" 2 true \
--gas-budget 10000000 \
--dry-run
Verificar eventos:

bash
# Después de varias interacciones
sui client events --query "MoveModule:garden"
Pruebas de carga:

bash
# Script para crear múltiples plantas
for i in {1..5}; do
  sui client call --function create_plant_entry \
  --module garden \
  --package <PACKAGE_ID> \
  --args "Planta $i" $((RANDOM % 6)) $((RANDOM % 2)) \
  --gas-budget 10000000
done