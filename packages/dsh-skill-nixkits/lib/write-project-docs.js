import { skillPlugin } from "./shared.js";

const plugin = skillPlugin("write-project-docs");

export const name = plugin.name;
export const inject = plugin.inject;
export function apply(ctx) {
  return plugin.apply(ctx);
}
