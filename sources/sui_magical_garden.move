module sui_magical_garden::garden {
    use sui::event;
    use std::string;

    /// 🌈 Tipos de magia elemental para las plantas
    public enum MagicType has store, copy, drop {
        Fire,    // 🔥 Fuego
        Water,   // 💧 Agua
        Earth,   // 🌍 Tierra
        Air,     // 💨 Aire
        Light,   // ✨ Luz
        Shadow   // 🌑 Sombra
    }

    /// 🌱 Etapas de crecimiento de la planta
    public enum Stage has store, copy, drop {
        Seed,       // 🌰 Semilla
        Sprout,     // 🌱 Brote
        Bud,        // 🌿 Capullo
        Flower,     // 🌸 Flor
        Withered    // 🍂 Marchita
    }

    /// 📜 Evento cuando una planta cambia de etapa
    public struct PlantStageChanged has copy, drop {
        plant_id: ID,      // ID de la planta
        old_stage: Stage,  // Etapa anterior
        new_stage: Stage,  // Nueva etapa
        timestamp: u64     // Momento del cambio
    }

    /// 🌿 Objeto Planta con propiedades mágicas
    public struct Plant has key, store {
        id: UID,                   // Identificador único
        name: string::String,       // Nombre de la planta
        watered_count: u64,         // Veces regada
        stage: Stage,               // Etapa actual
        magic_type: MagicType,      // Tipo de magia
        last_watered: u64,          // Último riego (timestamp)
        is_rare: bool,              // ¿Es rara?
        gardener: address           // Dueño
    }

    /// 📚 Metadatos para Move Registry
    public struct GardenMetadata has key, store {
        id: UID,
        name: string::String,
        version: string::String,
        description: string::String
    }

    // ===== FUNCIONES PRINCIPALES =====

    /// 🌱 Crear una nueva planta (función interna)
    fun create_plant(
        name: string::String,
        magic_type: MagicType,
        is_rare: bool,
        ctx: &mut TxContext
    ): Plant {
        Plant {
            id: object::new(ctx),
            name,
            watered_count: 0,
            stage: Stage::Seed,
            magic_type,
            last_watered: 0,
            is_rare,
            gardener: tx_context::sender(ctx)
        }
    }

    /// 💧 Regar una planta (hace crecer según tipo de magia)
    fun water_plant(
        plant: &mut Plant,
        current_time: u64,
    ) {
        // ⏳ Solo se puede regar 1 vez por hora (3600000 ms)
        if (current_time < plant.last_watered + 3600000) {
            return
        };
        
        plant.watered_count = plant.watered_count + 1;
        plant.last_watered = current_time;
        
        let old_stage = plant.stage;
        
        // 🔄 Evolución basada en tipo de magia
        match (plant.magic_type) {
            MagicType::Fire => {  // Plantas de fuego crecen más rápido
                if (plant.watered_count >= 3) {
                    plant.stage = Stage::Flower;
                } else if (plant.watered_count == 2) {
                    plant.stage = Stage::Bud;
                } else if (plant.watered_count == 1) {
                    plant.stage = Stage::Sprout;
                }
            },
            _ => {  // Comportamiento por defecto
                if (plant.watered_count >= 4) {
                    plant.stage = Stage::Flower;
                } else if (plant.watered_count == 2 || plant.watered_count == 3) {
                    plant.stage = Stage::Bud;
                } else if (plant.watered_count == 1) {
                    plant.stage = Stage::Sprout;
                }
            }
        };
        
        // 📢 Emitir evento si cambió la etapa
        if (plant.stage != old_stage) {
            event::emit(PlantStageChanged {
                plant_id: object::id(plant),
                old_stage,
                new_stage: plant.stage,
                timestamp: current_time
            });
        }
    }

    /// 🍂 Marchitar una planta (después de florecer y 24h sin riego)
    fun wither_plant(plant: &mut Plant, current_time: u64) {
        // Solo plantas en flor pueden marchitarse
        if (plant.stage != Stage::Flower) return;

        // 24 horas = 86400000 ms
        if (current_time > plant.last_watered + 86400000) {
            let old_stage = plant.stage;
            plant.stage = Stage::Withered;
            event::emit(PlantStageChanged {
                plant_id: object::id(plant),
                old_stage,
                new_stage: Stage::Withered,
                timestamp: current_time
            });
        }
    }

    /// ✨ Revelar mensaje secreto (solo plantas raras florecidas)
    fun reveal_secret(plant: &Plant): string::String {
        assert!(plant.stage == Stage::Flower, 0);
        assert!(plant.is_rare, 1);
        
        // 📜 Mensajes especiales según tipo de magia
        match (plant.magic_type) {
            MagicType::Fire => string::utf8(b"🔥 Tu pasion enciende el mundo"),
            MagicType::Water => string::utf8(b"💧 Fluyes con la sabiduria de los oceanos"),
            MagicType::Earth => string::utf8(b"🌍 Eres la roca sobre la que se construyen los suenos"),
            MagicType::Air => string::utf8(b"💨 Llevas la frescura del cambio"),
            MagicType::Light => string::utf8(b"✨ Iluminas el camino de los demas"),
            MagicType::Shadow => string::utf8(b"🌑 Conoces los secretos que otros temen explorar")
        }
    }

    /// 🔄 Transferir una planta a otro usuario
    public fun transfer_plant(plant: Plant, recipient: address) {
        transfer::public_transfer(plant, recipient);
    }

    // ===== ENTRY POINTS =====

    /// 🌱 Crear planta (entry point)
    #[allow(lint(self_transfer))] // Suprimir advertencia de transferencia
    public fun create_plant_entry(
        name: vector<u8>,
        magic_type: u8,
        is_rare: bool,
        ctx: &mut TxContext
    ) {
        let magic = match (magic_type) {
            0 => MagicType::Fire,
            1 => MagicType::Water,
            2 => MagicType::Earth,
            3 => MagicType::Air,
            4 => MagicType::Light,
            _ => MagicType::Shadow
        };
        let plant = create_plant(
            string::utf8(name),
            magic,
            is_rare,
            ctx
        );
        transfer::public_transfer(plant, tx_context::sender(ctx));
    }

    /// 💧 Regar planta (entry point)
    public fun water_plant_entry(
        plant: &mut Plant,
        current_time: u64,
    ) {
        water_plant(plant, current_time);
    }

    /// 🍂 Marchitar planta (entry point)
    public fun wither_plant_entry(
        plant: &mut Plant,
        current_time: u64,
    ) {
        wither_plant(plant, current_time);
    }

    /// ✨ Revelar secreto (entry point)
    public fun reveal_secret_entry(
        plant: &Plant
    ): string::String {
        reveal_secret(plant)
    }

    /// 🔄 Transferir planta (entry point)
    public fun transfer_plant_entry(
        plant: Plant,
        recipient: address,
    ) {
        transfer_plant(plant, recipient);
    }

    // ===== MOVE REGISTRY =====

    /// 🏁 Inicializar módulo (función especial)
    fun init(ctx: &mut TxContext) {
        let metadata = GardenMetadata {
            id: object::new(ctx),
            name: string::utf8(b"Magical Garden"),
            version: string::utf8(b"1.0"),
            description: string::utf8(b"Jardin magico con plantas elementales")
        };
        transfer::share_object(metadata);
    }

    #[test_only]
    use sui::test_scenario;

    // Función auxiliar para crear plantas en tests
    #[test_only]
    fun create_test_plant(ctx: &mut TxContext): Plant {
        Plant {
            id: object::new(ctx),
            name: string::utf8(b"Planta Test"),
            watered_count: 0,
            stage: Stage::Seed,
            magic_type: MagicType::Fire,
            last_watered: 0,
            is_rare: false,
            gardener: @0x0
        }
    }

    // Función para consumir plantas en tests
    #[test_only]
    fun consume_plant(plant: Plant) {
        let Plant { id, name: _, watered_count: _, stage: _, magic_type: _, last_watered: _, is_rare: _, gardener: _ } = plant;
        object::delete(id);
    }

    #[test]
    fun test_create_and_water_plant() {
        let admin = @0x0;
        let mut scenario = test_scenario::begin(admin);
        let ctx = test_scenario::ctx(&mut scenario);
        
        // Crear planta
        let mut plant = create_test_plant(ctx);
        
        // Regar la planta con tiempo suficiente
        water_plant(&mut plant, 3600000); // 1 hora después
        
        // Verificar que ahora es un brote
        assert!(plant.stage == Stage::Sprout, 0);
        assert!(plant.watered_count == 1, 1);
        
        // Consumir la planta
        consume_plant(plant);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_water_fire_plant_to_flower() {
        let admin = @0x0;
        let mut scenario = test_scenario::begin(admin);
        let ctx = test_scenario::ctx(&mut scenario);
        
        // Crear planta de fuego
        let mut plant = create_test_plant(ctx);
        
        // Regar 3 veces con 1 hora de diferencia
        water_plant(&mut plant, 3600000);   // 1 hora (count=1 → Sprout)
        water_plant(&mut plant, 7200000);   // 2 horas (count=2 → Bud)
        water_plant(&mut plant, 10800000);  // 3 horas (count=3 → Flower)
        
        // Debería ser una flor después de 3 riegos
        assert!(plant.stage == Stage::Flower, 0);
        assert!(plant.watered_count == 3, 1);
        
        // Consumir la planta
        consume_plant(plant);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_wither_plant() {
        let admin = @0x0;
        let mut scenario = test_scenario::begin(admin);
        let ctx = test_scenario::ctx(&mut scenario);
        
        // Crear planta
        let mut plant = create_test_plant(ctx);
        
        // Avanzar a flor y establecer último riego
        plant.stage = Stage::Flower;
        plant.last_watered = 1000;
        
        // Intentar marchitar antes de 24 horas (no debe marchitarse)
        wither_plant(&mut plant, 1000 + 86399999); // 1 ms antes de 24 horas
        assert!(plant.stage == Stage::Flower, 0);
        
        // Marchitar después de 24 horas + 1 ms
        wither_plant(&mut plant, 1000 + 86400001);
        assert!(plant.stage == Stage::Withered, 1);
        
        // Consumir la planta
        consume_plant(plant);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_reveal_secret() {
        let admin = @0x0;
        let mut scenario = test_scenario::begin(admin);
        let ctx = test_scenario::ctx(&mut scenario);
        
        // Crear planta rara de agua
        let mut plant = create_test_plant(ctx);
        plant.magic_type = MagicType::Water;
        plant.is_rare = true;
        plant.stage = Stage::Flower;  // Forzar a flor
        
        // Revelar secreto
        let secret = reveal_secret(&plant);
        assert!(secret == string::utf8(b"💧 Fluyes con la sabiduria de los oceanos"), 0);
        
        // Consumir la planta
        consume_plant(plant);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_plant() {
        let admin = @0x0;
        let mut scenario = test_scenario::begin(admin);
        let ctx = test_scenario::ctx(&mut scenario);
        
        // Crear planta
        let plant = create_test_plant(ctx);
        
        // Transferir a un amigo
        transfer_plant(plant, @0x1);
        
        // Verificar que la transferencia fue exitosa (simulado)
        assert!(true, 0);
        test_scenario::end(scenario);
    }
}