// Shapes exchanged with the Lua side (jo_libs/modules/input/client.lua).
// The Lua module sends `{ event: "newInput", data: { rows } }` and expects
// `{ action, result, priceIds }` back, so these types mirror that contract.
/** Entry types that contribute a value to the result sent back to Lua. */
export const RESULT_TYPES = ['text', 'textarea', 'number', 'date', 'select', 'price'];
/** Entry types rendered as a clickable button. `action` is the legacy name. */
export const BUTTON_TYPES = ['button', 'action'];
/** Result types that can receive the initial keyboard focus. */
export const FOCUSABLE_TYPES = ['text', 'textarea', 'number', 'select'];
/** Zones of the panel a row can be sent to. `content` is the only one scrolling. */
export const ROW_POSITIONS = ['header', 'content', 'footer'];
export const DEFAULT_ROW_POSITION = 'content';
export function isResultType(type) {
    return RESULT_TYPES.includes(type);
}
export function isResultEntry(entry) {
    return isResultType(entry.type);
}
export function isButtonType(type) {
    return BUTTON_TYPES.includes(type);
}
export function isFocusableType(type) {
    return FOCUSABLE_TYPES.includes(type);
}
/** Falls back to `content` for a missing or unknown position. */
export function toRowPosition(value) {
    return ROW_POSITIONS.includes(value)
        ? value
        : DEFAULT_ROW_POSITION;
}
