// Type definition for window.postMessage
interface MessageData {
  type: string;
  data: unknown;
}

// Using window.postMessage as a SendNUIMessage function
export const SendNUIMessage = (message: MessageData): void =>
  window.postMessage(message, "*");

export function showLockpickMock(): void {
  SendNUIMessage({
    type: "jo_minigame:show",
    data: {
      game: "lockpick",
      config: {
        difficulty: "debug",
        pins: 3,
        pinHealth: 100,
        pinDamage: 20,
        pinDamageInterval: 150,
        solvePadding: 4,
        maxDistFromSolve: 45,
        cylRotSpeed: 3,
      },
    },
  });
}

export function showQteMock(): void {
  SendNUIMessage({
    type: "jo_minigame:show",
    data: {
      game: "qte",
      config: {
        roundCount: 4,
        allowedKeys: "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split(""),
        rotationCount: 2,
        targetStartAngle: { min: 100, max: 300 },
        targetArcSize: { min: 50, max: 60 },
        rotationDuration: { min: 500, max: 1000 },
        introDelay: 300,
        successDelay: 450,
        failureDelay: 550,
        roundDelay: 100,
      },
    },
  });
}

export function hideMinigameMock(): void {
  SendNUIMessage({
    type: "jo_minigame:hide",
    data: {},
  });
}
