// Type definition for window.postMessage
interface MessageData {
  type: string;
  data: unknown;
}

// Using window.postMessage as a SendNUIMessage function
const SendNUIMessage = (message: MessageData): void =>
  window.postMessage(message, "*");
