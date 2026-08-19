import { skillPlugin } from "./shared.js";

const plugin = skillPlugin("nixos-modern-cli");

export const name = plugin.name;
export const inject = plugin.inject;
export function apply(ctx) {
  return plugin.apply(ctx);
}
