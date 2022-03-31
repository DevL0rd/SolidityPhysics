pragma solidity ^0.5.0;

// A physics engine in sol for fun

contract PhysicsEngine {
    // The number of objects in the simulation
    struct vector2D {
        uint256 x;
        uint256 y;
    }

    struct Object {
        uint256 id;
        vector2D pos;
        vector2D vel;
        vector2D acc;
        int256 mass;
        bool isStatic;
    }

    mapping(uint256 => Object) public objects;

    event ObjectCreated(
        uint256 id,
        vector2D pos,
        vector2D vel,
        vector2D acc,
        int256 mass,
        bool isStatic
    );
    event ObjectUpdated(
        uint256 id,
        vector2D pos,
        vector2D vel,
        vector2D acc,
        int256 mass,
        bool isStatic
    );

    function createObject(
        vector2D pos,
        vector2D vel,
        vector2D acc,
        int256 mass,
        bool isStatic
    ) public {
        uint256 id = objects.length;
        objects[id] = Object(id, pos, vel, acc, mass, isStatic);
        emit ObjectCreated(id, pos, vel, acc, mass, isStatic);
        return objects[id];
    }

    function applyForces(uint256 id) public {
        Object obj = objects[id];
        if (obj.isStatic) {
            return;
        }
        obj.vel.x += obj.acc.x;
        obj.vel.y += obj.acc.y;
        obj.pos.x += obj.vel.x;
        obj.pos.y += obj.vel.y;
        emit ObjectUpdated(
            id,
            obj.pos,
            obj.vel,
            obj.acc,
            obj.mass,
            obj.isStatic
        );
    }

    function tick() public {
        for (uint256 i = 0; i < objects.length; i++) {
            applyForces(i);

            emit ObjectUpdated(
                obj.id,
                obj.pos,
                obj.vel,
                obj.acc,
                obj.mass,
                obj.isStatic
            );
        }
    }

    constructor() public {
        createObject(vector2D(0, 0), vector2D(0, 0), vector2D(0, 0), 1, false);
    }
}
