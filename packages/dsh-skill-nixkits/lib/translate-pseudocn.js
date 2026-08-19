import { skillPlugin } from "./shared.js";

const plugin = skillPlugin("translate-pseudocn");

export const name = plugin.name;
export const inject = plugin.inject;
export function apply(ctx) {
  return plugin.apply(ctx);
}
