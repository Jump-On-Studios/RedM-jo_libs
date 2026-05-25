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
        pins: 1,
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
        difficulty: "debug",
        count: 4,
        keys: "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split(""),
        targetStart: { min: 100, max: 300 },
        targetSize: { min: 50, max: 60 },
        duration: { min: 2000, max: 30000000 },
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
