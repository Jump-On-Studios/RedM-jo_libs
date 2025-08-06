import { PerspectiveCamera } from '@react-three/drei'
import { useNuiEvent } from '../hooks/useNuiEvent'
import { zRot } from '../utils/misc'
import { useThree } from '@react-three/fiber'
import { MathUtils } from 'three'

export const Camera = () => {
    const { camera } = useThree()

    useNuiEvent('SetCameraPosition', ({ position, rotation }: any) => {
        camera.position.set( position.x, position.z, -position.y )
        camera.rotation.order = 'YZX'

        rotation && camera.rotation.set(
            MathUtils.degToRad(rotation.x),
            MathUtils.degToRad(zRot(rotation.x, rotation.z)),
            MathUtils.degToRad(rotation.y)
        )

        camera.updateProjectionMatrix()
    })

    return (
        <PerspectiveCamera position={[0,0,10]} makeDefault onUpdate={(self: any) => self.updateProjectionMatrix()} />
    )
}