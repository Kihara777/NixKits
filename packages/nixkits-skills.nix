{
  lib,
  runCommand,
}:

# Deployment-bundled skill directory for dsh's skill-filesystem provider
# (bundledSkillDir, rank 600).  Layout: $out/<skill-name>/SKILL.md (+
# dictionary.md / templates.md companions), exactly what the provider scans.
runCommand "nixkits-skills" { } ''
  mkdir -p "$out"
  cp -r ${../skills}/* "$out/"
''
