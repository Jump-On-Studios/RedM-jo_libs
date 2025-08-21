import { Suspense, useRef, useState, useEffect } from 'react';
import { TransformControls } from '@react-three/drei';
import { useNuiEvent, fetchNui } from '../hooks/useNuiEvent';
import { Mesh, MathUtils } from 'three';

export const Transform = () => {
  const mesh = useRef<Mesh>(null!);
  const [currentEntity, setCurrentEntity] = useState<number>();
  const [editorMode, setEditorMode] = useState<"translate" | "rotate">("translate");
  const [allowTranslateX, setAllowTranslateX] = useState<boolean>(true);
  const [allowTranslateY, setAllowTranslateY] = useState<boolean>(true);
  const [allowTranslateZ, setAllowTranslateZ] = useState<boolean>(true);
  const [allowRotateX, setAllowRotateX] = useState<boolean>(true);
  const [allowRotateY, setAllowRotateY] = useState<boolean>(true);
  const [allowRotateZ, setAllowRotateZ] = useState<boolean>(true);
  const [rotationSnap, setRotationSnap] = useState<number>(5);
  const [rotationSnapEnabled, setRotationSnapEnabled] = useState<boolean>(false);


  const handleObjectDataUpdate = async () => {

    const entity = {
      handle: currentEntity,
      position: {
        x: mesh.current.position.x,
        y: -mesh.current.position.z,
        z: mesh.current.position.y,
      },
      rotation: {
        x: MathUtils.radToDeg(mesh.current.rotation.x),
        y: MathUtils.radToDeg(-mesh.current.rotation.z),
        z: MathUtils.radToDeg(mesh.current.rotation.y),
      },
    };

    const response: any = await fetchNui("UpdateEntity", entity);

    if (response?.status !== "ok") {
      mesh.current.position.set(
        response.position.x,
        response.position.z,
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
      entity.position.z,
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

    // Set axis control properties (default to true if not provided)
    setAllowTranslateX(entity.allowTranslateX ?? true);
    setAllowTranslateY(entity.allowTranslateY ?? true);
    setAllowTranslateZ(entity.allowTranslateZ ?? true);
    setAllowRotateX(entity.allowRotateX ?? true);
    setAllowRotateY(entity.allowRotateY ?? true);
    setAllowRotateZ(entity.allowRotateZ ?? true);
    setRotationSnap(entity.rotationSnap ?? 5);
  });

  useNuiEvent('SetGizmoMode', (editMode: any) => {
    setEditorMode(editMode);
  });

  useNuiEvent('EnableRotationSnap', (value: any) => {
    setRotationSnapEnabled(value ?? false);
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
            showX={editorMode === "translate" ? allowTranslateX : allowRotateX}
            showY={editorMode === "translate" ? allowTranslateZ : allowRotateZ}
            showZ={editorMode === "translate" ? allowTranslateY : allowRotateY}
            rotationSnap={rotationSnapEnabled ? rotationSnap : null}
          />
        )}
        <mesh ref={mesh} />
      </Suspense>
    </>
  );
};
