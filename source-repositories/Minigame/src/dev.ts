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
        timeLimit: 30,
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
