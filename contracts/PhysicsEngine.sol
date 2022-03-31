pragma solidity ^0.5.0;

// A physics engine in sol for fun

contract PhysicsEngine {
    // The number of objects in the simulation
    struct vector2D {
        uint256 x;
        uint256 y;
    }

    enum objectType {
        circle,
        rectangle,
        line
    }

    struct Object {
        uint256 id;
        vector2D pos;
        vector2D vel;
        vector2D acc;
        int256 mass;
        bool isStatic;
        objectType objectType;
        uint256 radius;
        vector2D size;
    }

    mapping(uint256 => Object) public objects;

    event ObjectCreated(
        uint256 id,
        vector2D pos,
        vector2D vel,
        vector2D acc,
        int256 mass,
        bool isStatic,
        objectType objectType,
        uint256 radius,
        vector2D size
    );
    event ObjectUpdated(
        uint256 id,
        vector2D pos,
        vector2D vel,
        vector2D acc,
        int256 mass,
        bool isStatic,
        objectType objectType,
        uint256 radius,
        vector2D size
    );

    function createObject(
        vector2D pos,
        vector2D vel,
        vector2D acc,
        int256 mass,
        bool isStatic,
        objectType objectType,
        uint256 radius,
        vector2D size
    ) public returns (uint256) {
        uint256 id = objects.length;
        Object object = Object({
            id: id,
            pos: pos,
            vel: vel,
            acc: acc,
            mass: mass,
            isStatic: isStatic,
            objectType: objectType,
            radius: radius,
            size: size
        });
        objects[id] = object;
        emit ObjectCreated(
            id,
            pos,
            vel,
            acc,
            mass,
            isStatic,
            objectType,
            radius,
            size
        );
        return id;
    }
    world = {
        gravity: vector2D({
            x: 0,
            y: -9.81
        }),
        friction: 0.5
    }

    function applyGravity(uint256 id) public {
        Object object = objects[id];
        if (!object.isStatic) {
            object.acc = vector2D({
                x: object.acc.x + world.gravity.x,
                y: object.acc.y + world.gravity.y
            });
        }
    }

    function updateObject(uint256 id, uint256 delta) public {
        Object object = objects[id];
        if (object.isStatic) {
            return;
        }
        object.vel = vector2D({
            x: object.vel.x + object.acc.x * delta,
            y: object.vel.y + object.acc.y * delta
        });
        object.pos = vector2D({
            x: object.pos.x + object.vel.x * delta,
            y: object.pos.y + object.vel.y * delta
        });
        emit ObjectUpdated(
            id,
            object.pos,
            object.vel,
            object.acc,
            object.mass,
            object.isStatic,
            object.objectType,
            object.radius,
            object.size
        );
    }

    
    function tick() public {
        for (uint256 i = 0; i < objects.length; i++) {
            applyGravity(i);
            updateObject(i);
        }
    }

    constructor() public {
        createObject(
            vector2D({
                x: 0,
                y: 0
            }),
            vector2D({
                x: 0,
                y: 0
            }),
            vector2D({
                x: 0,
                y: 0
            }),
            1,
            true,
            objectType.circle,
            1,
            vector2D({
                x: 1,
                y: 1
            })
        );
        //game loop
        while (true) {
            tick();
            sleep(1000 / 60);
        }
    }
}
