import { skillPlugin } from "./shared.js";

const plugin = skillPlugin("recover-nixos-config");

export const name = plugin.name;
export const inject = plugin.inject;
export function apply(ctx) {
  return plugin.apply(ctx);
}
