import { Suspense, useRef, useState, useEffect } from 'react';
import { TransformControls } from '@react-three/drei';
import { useNuiEvent, fetchNui } from '../hooks/useNuiEvent';
import { Mesh, MathUtils } from 'three';

export const Transform = () => {
  const mesh = useRef<Mesh>(null!);
  const [currentEntity, setCurrentEntity] = useState<number>();
  const [editorMode, setEditorMode] = useState<"translate" | "rotate">("translate");

  const handleObjectDataUpdate = async () => {
    
    const entity = {
      handle: currentEntity,
      position: {
        x: mesh.current.position.x,
        y: -mesh.current.position.z,
        z: mesh.current.position.y - 0.5,
      },
      rotation: {
        x: MathUtils.radToDeg(mesh.current.rotation.x),
        y: MathUtils.radToDeg(-mesh.current.rotation.z),
        z: MathUtils.radToDeg(mesh.current.rotation.y),
      },
    };

    const response :any = await fetchNui("UpdateEntity", entity);
    
    if (response?.status !== "ok") {
      mesh.current.position.set(
        response.position.x,
        response.position.z + 0.5,
        -response.position.y
      );
  
      mesh.current.rotation.order = "YZX";
  
      mesh.current.rotation.set(
        MathUtils.degToRad(response.rotation.x),
        MathUtils.degToRad(response.rotation.z),
        MathUtils.degToRad(response.rotation.y)
      );
    }
  };

  useNuiEvent("SetupGizmo", (entity: any) => {
    setCurrentEntity(entity.handle);
    if (!entity.handle) {
      return;
    }

    mesh.current.position.set(
      entity.position.x,
      entity.position.z + 0.5,
      -entity.position.y
    );

    mesh.current.rotation.order = "YZX";

    mesh.current.rotation.set(
      MathUtils.degToRad(entity.rotation.x),
      MathUtils.degToRad(entity.rotation.z),
      MathUtils.degToRad(entity.rotation.y)
    );

    if (entity.gizmoMode) {
      setEditorMode(entity.gizmoMode);
    }

  });

  useNuiEvent('SetGizmoMode', (editMode: any) => {
    setEditorMode(editMode);
  });

  return (
    <>
      <Suspense fallback={<p>Loading...</p>}>
        {currentEntity != null && (
          <TransformControls
            size={0.5}
            object={mesh}
            mode={editorMode}
            onObjectChange={handleObjectDataUpdate}
          />
        )}
        <mesh ref={mesh} />
      </Suspense>
    </>
  );
};
