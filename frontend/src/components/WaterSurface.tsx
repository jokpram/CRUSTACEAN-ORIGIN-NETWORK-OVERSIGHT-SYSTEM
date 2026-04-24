import { useRef, useMemo } from 'react';
import { Canvas, useFrame, useThree } from '@react-three/fiber';
import { MeshDistortMaterial, Float } from '@react-three/drei';
import * as THREE from 'three';

function AnimatedWater() {
    const meshRef = useRef<THREE.Mesh>(null);
    const { mouse } = useThree();

    useFrame((state) => {
        if (meshRef.current) {
            // Natural floating motion
            meshRef.current.rotation.x = Math.sin(state.clock.elapsedTime * 0.3) * 0.1;
            meshRef.current.rotation.y = Math.cos(state.clock.elapsedTime * 0.2) * 0.1;

            // Follow mouse subtly
            meshRef.current.position.x = THREE.MathUtils.lerp(meshRef.current.position.x, mouse.x * 0.5, 0.1);
            meshRef.current.position.y = THREE.MathUtils.lerp(meshRef.current.position.y, mouse.y * 0.5, 0.1);
        }
    });

    return (
        <Float speed={2} rotationIntensity={0.5} floatIntensity={0.5}>
            <mesh ref={meshRef} position={[0, 0, 0]}>
                <sphereGeometry args={[1.5, 64, 64]} />
                <MeshDistortMaterial
                    color="#0ea5e9"
                    speed={3}
                    distort={0.4}
                    radius={1}
                    metalness={0.8}
                    roughness={0.1}
                    emissive="#0369a1"
                    emissiveIntensity={0.5}
                />
            </mesh>
        </Float>
    );
}

function InteractiveLight() {
    const lightRef = useRef<THREE.PointLight>(null);
    const { mouse } = useThree();

    useFrame(() => {
        if (lightRef.current) {
            lightRef.current.position.x = mouse.x * 5;
            lightRef.current.position.y = mouse.y * 5;
        }
    });

    return <pointLight ref={lightRef} intensity={2} color="#38bdf8" />;
}

function Waves() {
    const points = useMemo(() => {
        const p = [];
        for (let i = 0; i < 150; i++) {
            p.push(new THREE.Vector3((Math.random() - 0.5) * 12, (Math.random() - 0.5) * 12, (Math.random() - 0.5) * 12));
        }
        return p;
    }, []);

    const groupRef = useRef<THREE.Group>(null);
    const { mouse } = useThree();

    useFrame(() => {
        if (groupRef.current) {
            groupRef.current.rotation.x = mouse.y * 0.1;
            groupRef.current.rotation.y = mouse.x * 0.1;
        }
    });

    return (
        <group ref={groupRef}>
            {points.map((pos, i) => (
                <mesh key={i} position={pos}>
                    <sphereGeometry args={[0.015, 8, 8]} />
                    <meshBasicMaterial color="#7dd3fc" transparent opacity={0.2} />
                </mesh>
            ))}
        </group>
    );
}

export default function WaterSurface() {
    return (
        <div className="fixed inset-0 z-[-1] pointer-events-none opacity-50 transition-opacity duration-1000">
            <Canvas camera={{ position: [0, 0, 5], fov: 75 }} dpr={[1, 2]}>
                <ambientLight intensity={0.4} />
                <InteractiveLight />
                <spotLight position={[-10, 10, 10]} angle={0.15} penumbra={1} intensity={1.5} />

                <AnimatedWater />
                <Waves />

                <fog attach="fog" args={['#0c4a6e', 5, 20]} />
            </Canvas>
        </div>
    );
}
