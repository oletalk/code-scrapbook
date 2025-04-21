/**
 * Utility class for this project's test suite.
 */
export class CaptureUtils<T> {
  private captured: Map<string,T>

  public constructor() {
    this.captured = new Map<string,T>()
  }

  /**
   * Return the value you associated with this (string) key
   * @param key the key you associated with the value
   * @returns the value you associated with this key (or empty string if none)
   */
  public getCaptured(key : string) : T|undefined{
    const ret = this.captured.get(key)
    if (typeof ret === 'undefined') {
      return undefined
    } else {
      return ret
    }
  }

  /**
   * Capture an object from your test run and associate it with a key for future recall
   * @param key your chosen (string) key
   * @param value the captured value you want to store
   */
  public capture(key : string, value : T|undefined) {
    if (typeof value !== 'undefined') {
      this.captured.set(key, value)
    } else {
      console.error('utils: capture called for undefined value')
    }
  }
}