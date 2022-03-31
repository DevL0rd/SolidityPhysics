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

    function detectCircleCollision(uint256 id1, uint256 id2) public returns (bool) { //Detect, not resolve circle circle collision
        Object object1 = objects[id1];
        Object object2 = objects[id2];
        if (object1.objectType != objectType.circle || object2.objectType != objectType.circle) {
            return false;
        }
        vector2D pos1 = object1.pos;
        vector2D pos2 = object2.pos;
        uint256 radius1 = object1.radius;
        uint256 radius2 = object2.radius;
        vector2D distance = vector2D({
            x: pos1.x - pos2.x,
            y: pos1.y - pos2.y
        });
        uint256 distanceMagnitude = uint256(sqrt(distance.x * distance.x + distance.y * distance.y));
        if (distanceMagnitude < radius1 + radius2) {
            return true;
        }
        return false;
    }
    function resolveCircleCircleCollision(uint256 id1, uint256 id2) public {
        Object object1 = objects[id1];
        Object object2 = objects[id2];
        if (object1.objectType != objectType.circle || object2.objectType != objectType.circle) {
            return;
        }
        vector2D pos1 = object1.pos;
        vector2D pos2 = object2.pos;
        uint256 radius1 = object1.radius;
        uint256 radius2 = object2.radius;
        vector2D distance = vector2D({
            x: pos1.x - pos2.x,
            y: pos1.y - pos2.y
        });
        uint256 distanceMagnitude = uint256(sqrt(distance.x * distance.x + distance.y * distance.y));
        if (distanceMagnitude < radius1 + radius2) {
            vector2D normal = vector2D({
                x: distance.x / distanceMagnitude,
                y: distance.y / distanceMagnitude
            });
            vector2D relativeVelocity = vector2D({
                x: object1.vel.x - object2.vel.x,
                y: object1.vel.y - object2.vel.y
            });
            uint256 normalVelocity = uint256(relativeVelocity.x * normal.x + relativeVelocity.y * normal.y);
            if (normalVelocity > 0) {
                return;
            }
            uint256 restitution = 0.5;
            uint256 impulse = uint256(-(1 + restitution) * normalVelocity);
            impulse = impulse / uint256(1 / object1.mass + 1 / object2.mass);
            vector2D impulseVector = vector2D({
                x: normal.x * impulse,
                y: normal.y * impulse
            });
            object1.vel = vector2D({
                x: object1.vel.x - impulseVector.x / uint256(1 / object1.mass),
                y: object1.vel.y - impulseVector.y / uint256(1 / object1.mass)
            });
            object2.vel = vector2D({
                x: object2.vel.x + impulseVector.x / uint256(1 / object2.mass),
                y: object2.vel.y + impulseVector.y / uint256(1 / object2.mass)
            });
        }
    }
    function detectRectangleCollision(uint256 id1, uint256 id2) public returns (bool) { //Detect, not resolve rectangle rectangle collision
        Object object1 = objects[id1];
        Object object2 = objects[id2];
        if (object1.objectType != objectType.rectangle || object2.objectType != objectType.rectangle) {
            return false;
        }
        vector2D pos1 = object1.pos;
        vector2D pos2 = object2.pos;
        vector2D size1 = object1.size;
        vector2D size2 = object2.size;
        vector2D distance = vector2D({
            x: pos1.x - pos2.x,
            y: pos1.y - pos2.y
        });
        if (distance.x > size1.x / 2 + size2.x / 2 || distance.y > size1.y / 2 + size2.y / 2) {
            return false;
        }
        if (distance.x < -size1.x / 2 - size2.x / 2 || distance.y < -size1.y / 2 - size2.y / 2) {
            return false;
        }
        return true;
    }

    function resolveRectangleRectangleCollision(uint256 id1, uint256 id2) public {
        Object object1 = objects[id1];
        Object object2 = objects[id2];
        if (object1.objectType != objectType.rectangle || object2.objectType != objectType.rectangle) {
            return;
        }
        vector2D pos1 = object1.pos;
        vector2D pos2 = object2.pos;
        vector2D size1 = object1.size;
        vector2D size2 = object2.size;
        vector2D distance = vector2D({
            x: pos1.x - pos2.x,
            y: pos1.y - pos2.y
        });
        if (distance.x > size1.x / 2 + size2.x / 2 || distance.y > size1.y / 2 + size2.y / 2) {
            return;
        }
        if (distance.x < -size1.x / 2 - size2.x / 2 || distance.y < -size1.y / 2 - size2.y / 2) {
            return;
        }
        vector2D normal = vector2D({
            x: distance.x / (size1.x / 2 + size2.x / 2),
            y: distance.y / (size1.y / 2 + size2.y / 2)
        });
        vector2D relativeVelocity = vector2D({
            x: object1.vel.x - object2.vel.x,
            y: object1.vel.y - object2.vel.y
        });
        uint256 normalVelocity = uint256(relativeVelocity.x * normal.x + relativeVelocity.y * normal.y);
        if (normalVelocity > 0) {
            return;
        }
        uint256 restitution = 0.5;
        uint256 impulse = uint256(-(1 + restitution) * normalVelocity);
        impulse = impulse / uint256(1 / object1.mass + 1 / object2.mass);
        vector2D impulseVector = vector2D({
            x: normal.x * impulse,
            y: normal.y * impulse
        });
        object1.vel = vector2D({
            x: object1.vel.x - impulseVector.x / uint256(1 / object1.mass),
            y: object1.vel.y - impulseVector.y / uint256(1 / object1.mass)
        });
        object2.vel = vector2D({
            x: object2.vel.x + impulseVector.x / uint256(1 / object2.mass),
            y: object2.vel.y + impulseVector.y / uint256(1 / object2.mass)
        });
    }
    // function detectRectangleCollision(uint256 id1, uint256 id2) public returns (bool) {
    //     Object object1 = objects[id1];
    //     Object object2 = objects[id2];
    //     if (object1.objectType != objectType.rectangle || object2.objectType != objectType.rectangle) {
    //         return false;
    //     }
    //     vector2D pos1 = object1.pos;
    //     vector2D pos2 = object2.pos;
    //     vector2D vel1 = object1.vel;
    //     vector2D vel2 = object2.vel;
    //     vector2D acc1 = object1.acc;
    //     vector2D acc2 = object2.acc;
    //     uint256 radius1 = object1.radius;
    //     uint256 radius2 = object2.radius;
    //     vector2D size1 = object1.size;
    //     vector2D size2 = object2.size;
    //     vector2D delta = vector2D({
    //         x: pos2.x - pos1.x,
    //         y: pos2.y - pos1.y
    //     });
    //     uint256 distance = uint256(sqrt(delta.x * delta.x + delta.y * delta.y));
    //     if (distance > size1.x + size2.x) {
    //         return false;
    //     }
    //     vector2D normal = vector2D({
    //         x: delta.x / distance,
    //         y: delta.y / distance
    //     });
    //     vector2D tangent = vector2D({
    //         x: -normal.y,
    //         y: normal.x
    //     });
    //     vector2D relativeVelocity = vector2D({
    //         x: vel2.x - vel1.x,
    //         y: vel2.y - vel1.y
    //     });
    //     uint256 relativeVelocityNormal = uint256(relativeVelocity.x * normal.x + relativeVelocity.y * normal.y);
    //     if (relativeVelocityNormal > 0) {
    //         return false;
    //     }
    //     uint256 impulse = uint256(
    //         (1 + world.friction) *
    //         relativeVelocityNormal /
    //         (1 / object1.mass + 1 / object2.mass + normal.x * normal.x / object1.moment + normal.y * normal.y
    //             / object1.moment + tangent.x * tangent.x / object1.moment + tangent.y * tangent.y / object1.moment)
    //     );
    //     vector2D impulseVector = vector2D({
    //         x: impulse * normal.x,
    //         y: impulse * normal.y
    //     });
    //     object1.vel = vector2D({
    //         x: vel1.x - impulseVector.x / object1.mass,
    //         y: vel1.y - impulseVector.y / object1.mass
    //     });
    //     object2.vel = vector2D({
    //         x: vel2.x + impulseVector.x / object2.mass,
    //         y: vel2.y + impulseVector.y / object2.mass
    //     });
    //     return true;
    // }

    function resolveCollisions( uint256 id ) public {
        Object object = objects[id];
        if (object.isStatic) {
            return;
        }
        for (uint256 i = 0; i < objects.length; i++) {
            if (i == id) {
                continue;
            }
            Object other = objects[i];
            if (other.isStatic) {
                continue;
            }
            //Circle circle collisions
            if (object.objectType == objectType.circle && other.objectType == objectType.circle) {
                if (detectCircleCollision(id, i)) {
                    resolveCircleCircleCollision(id, i);
                }
            }
            //Rectangle rectangle collisions
            if (object.objectType == objectType.rectangle && other.objectType == objectType.rectangle) {
                if (detectRectangleCollision(id, i)) {
                    resolveRectangleRectangleCollision(id, i);
                }
            }
        }
    }

    function tick() public {
        for (uint256 i = 0; i < objects.length; i++) {
            applyGravity(i);
            updateObject(i);
            resolveCollisions(i);
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
