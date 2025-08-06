// Will return whether the current environment is in a regular browser
// and not CEF
export const isEnvBrowser = (): boolean => !window.invokeNative;

export const noop = () => {};

export const zRot = (t: number,e: number) => {
    return t > 0 && t < 90 ? e : (t > -180 && t < -90) || t > 0 ? -e : e
}