import { Canvas } from '@react-three/fiber'
import { Camera } from './Camera'
import { Transform } from './Transform'

export const Gizmo = () => {
    return (
        <Canvas style={{zIndex:1}}>
            <Camera />
            <Transform />
        </Canvas>
    )
}