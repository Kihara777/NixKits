#!/usr/bin/env python3
"""apply-overlay —— 把一层预设从它的父预设派生出来。

    apply-overlay.py <父的 preset.patch.yml> <本层 overlay.yml> > 生成物

## 为什么是「父 + 差异」而不是存成品

同一段内容有两个来源，就一定会漂。2026-11-09 那天，掌灯的一份 916 行拷贝让
「改上游」变成了「改一份没人用的代码」——判据全绿、三个 commit、换代、重启，
掌灯跑的还是旧的。这里只认「父 + 差异」，成品是构建产物。

## 为什么走 Node 树而不是 dict（2026-11-09 实测的教训）

父文件里有 `!!js/function` 这类 cordis 扩展标签。`yaml.safe_load` 直接拒绝；
就算加个构造器把它当字符串收下，`safe_dump` 回去它就**变成字符串**了——
cordis 读到的将不再是函数，而是一段文本。**那是语义损坏，而且不会报错。**

所以：`yaml.compose()` 拿 Node 树（tag 原样保留），在树上改，再 `yaml.serialize()`
输出。代价是代码比 dict 版笨一倍，换来的是「构建期就能验、不会静默破坏」。

## 差异长什么样

```yaml
meta:                        # 顶层预设元数据（config 里的那几个字段）
  id: fuli                   # 同时改写节点 id：preset-<父> → preset-fuli
  name: '狐莉模式'
  description: '一句话'
  order: 11
set:                         # 按 id 改任意字段（点号路径）
  persona:
    config.text: |
      ...
insert:                      # 往预设的 config.plugins 里插条目
  - after: tool-skill        # 省略则追加到末尾
    entry:
      id: maintenance-skills
      name: '@kihara777/dsh-nixos-shell/maintenance-skills'
delete:
  - some-upstream-thing
```

## 已知射程

- **不保留父文件的注释**。注释是给人的，生成物是给 loader 的；要留说明写进
  `meta.comment`，它会被放到生成物头部。
- 只认 `id` 定位。没有 id 的节点无法 set/delete——那是父的结构问题，不在这里兜底。
- 输出由 PyYAML 序列化，缩进与父不同。**语义等价，字节不等。**
"""
from __future__ import annotations

import sys

import yaml

MAP = "tag:yaml.org,2002:map"
SEQ = "tag:yaml.org,2002:seq"
STR = "tag:yaml.org,2002:str"


def scalar(text):
    return yaml.ScalarNode(STR, str(text))


def from_python(obj):
    """overlay 里的纯数据 → Node。"""
    if isinstance(obj, dict):
        return yaml.MappingNode(MAP, [(scalar(k), from_python(v)) for k, v in obj.items()])
    if isinstance(obj, list):
        return yaml.SequenceNode(SEQ, [from_python(v) for v in obj])
    return scalar(obj)


def items(node):
    """MappingNode 的键值对。**带诊断**：如果某一项不是二元组，说明有节点被
    错误地换成了子树（或反过来），而这种坏结构只会在下游 unpack 时才炸，
    报的是一个看不出位置的 ValueError（2026-11-09 构建里撞过）。"""
    if not isinstance(node, yaml.MappingNode):
        return []
    for idx, kv in enumerate(node.value):
        if not (isinstance(kv, tuple) and len(kv) == 2):
            raise SystemExit(
                f"[apply-overlay] 内部错误：MappingNode 第 {idx} 项不是二元组"
                f"（{type(kv).__name__}）——有节点被换成了子树却没清干净"
            )
    return node.value


def get(node, key):
    for k, v in items(node):
        if isinstance(k, yaml.ScalarNode) and k.value == key:
            return v
    return None


def tag_for(value):
    """**按值的类型选 tag**。order 写成 '11'（字符串）会让下游读成字符串——
    2026-11-09 实测过一次：节点数对得上、语义比较才抓出来。"""
    if isinstance(value, bool):
        return "tag:yaml.org,2002:bool", ("true" if value else "false")
    if isinstance(value, int):
        return "tag:yaml.org,2002:int", str(value)
    return STR, str(value)


def set_scalar(node, key, value):
    """在 mapping 节点里设一个标量键；不存在就追加在末尾。"""
    tag, text = tag_for(value)
    for k, v in items(node):
        if isinstance(k, yaml.ScalarNode) and k.value == key:
            v.tag = tag
            v.value = text
            return True
    node.value.append((scalar(key), yaml.ScalarNode(tag, text)))
    return True


def set_at(node, dotted, value):
    """按 `a.b.c` 往下走，缺的层就地建 mapping。

    值可以是**标量或子树**（dict / list）。子树走 `from_python` 整块替换——
    因为有些字段本身就是一整段结构（掌灯层的 `persona.config` 里是 160 行身份文本，
    `skill-filesystem.config` 里是一整段 JS），拆成标量逐字塞反而更容易写错。
    """
    keys = dotted.split(".")
    cursor = node
    for key in keys[:-1]:
        nxt = get(cursor, key)
        if not isinstance(nxt, yaml.MappingNode):
            nxt = yaml.MappingNode(MAP, [])
            for k, v in list(items(cursor)):
                if isinstance(k, yaml.ScalarNode) and k.value == key:
                    v.tag, v.value = MAP, []
                    nxt = v
                    break
            else:
                cursor.value.append((scalar(key), nxt))
        cursor = nxt

    last = keys[-1]
    if isinstance(value, dict):
        # **递归合并，不整块替换。** 整块替换会用 `from_python` 造一棵全新的子树，
        # 里面每个标量都变成 `!!str`——而父里可能有 `!!js`（2026-11-09 实测：
        # `skill-filesystem.config.customSkillDirs` 就是），于是「代码」被降级成
        # 「文本」，内容对、语义错，且不报错。合并只碰真的变了的键。
        target = None
        for k, v in items(cursor):
            if isinstance(k, yaml.ScalarNode) and k.value == last and isinstance(v, yaml.MappingNode):
                target = v
                break
        if target is None:
            cursor.value.append((scalar(last), from_python(value)))
            return
        for sub_key, sub_value in value.items():
            set_at(target, sub_key, sub_value)
        return
    if isinstance(value, list):
        fresh = from_python(value)
        for k, v in items(cursor):
            if isinstance(k, yaml.ScalarNode) and k.value == last:
                v.tag, v.value = fresh.tag, fresh.value
                return
        cursor.value.append((scalar(last), fresh))
        return

    # **标量也要看目标原来的 tag**（2026-11-09 实测）：父里 `customSkillDirs` 是
    # `!!js` ——内容是 JS 源码，语义是「当程序求值」。整段替换内容、把 tag 写成
    # `!!str`，看起来只差一个字，实际是把「代码」降级成「文本」：loader 读到的
    # 不再是函数而是一串字符，**而且不会报错**。
    for k, v in items(cursor):
        if isinstance(k, yaml.ScalarNode) and k.value == last and isinstance(v, yaml.ScalarNode):
            if v.tag != STR:
                v.value = str(value)
                return
            break
    set_scalar(cursor, last, value)


def walk_nodes(node):
    yield node
    if isinstance(node, yaml.MappingNode):
        for _, v in node.value:
            yield from walk_nodes(v)
    elif isinstance(node, yaml.SequenceNode):
        for item in node.value:
            yield from walk_nodes(item)


def find_by_id(root, node_id):
    for node in walk_nodes(root):
        if isinstance(node, yaml.MappingNode):
            ident = get(node, "id")
            if isinstance(ident, yaml.ScalarNode) and ident.value == node_id:
                return node
    return None


def main() -> int:
    if len(sys.argv) != 3:
        print("用法：apply-overlay.py <parent.patch.yml> <overlay.yml>", file=sys.stderr)
        return 2
    parent_path, overlay_path = sys.argv[1], sys.argv[2]

    with open(parent_path, encoding="utf8") as fh:
        # **compose 保留 tag**：`!!js/...` 原样留在 Node 上，serialize 时还原。
        doc = yaml.compose(fh)
    if not isinstance(doc, yaml.MappingNode) and not isinstance(doc, yaml.SequenceNode):
        print("父文件不是 YAML 文档", file=sys.stderr)
        return 2

    with open(overlay_path, encoding="utf8") as fh:
        ov = yaml.safe_load(fh) or {}
    meta = ov.get("meta") or {}
    if not meta.get("id"):
        print("overlay 缺 meta.id：没有它无法定位父的预设节点", file=sys.stderr)
        return 2

    # ── 1. 预设节点：靠 `preset-*` 前缀找，不靠知道父叫什么 ─────────────
    preset = None
    for node in walk_nodes(doc):
        if isinstance(node, yaml.MappingNode):
            ident = get(node, "id")
            if isinstance(ident, yaml.ScalarNode) and str(ident.value).startswith("preset-"):
                preset = node
                break
    if preset is None:
        print("父文件里找不到 `id: preset-*` 的节点", file=sys.stderr)
        return 2

    ident = get(preset, "id")
    ident.value = "preset-" + meta["id"]
    # `meta.id` 是预设标识（目录名、节点 id 的后半）；`meta.agentId` 是 config.id。
    # 两者不同：`preset-fuli-mode` 节点的 `config.id` 是 `fuli`。
    agent_id = meta.get("agentId", meta["id"])
    config = get(preset, "config")
    if not isinstance(config, yaml.MappingNode):
        print("预设节点没有 config mapping", file=sys.stderr)
        return 2
    if meta.get("id"):
        set_scalar(config, "id", agent_id)
    for key in ("name", "description", "order"):
        if key in meta:
            set_scalar(config, key, meta[key])

    # ── 2. set：按 id 改字段 ─────────────────────────────────────────
    for node_id, fields in (ov.get("set") or {}).items():
        target = find_by_id(doc, node_id)
        if target is None:
            print(f"set: 父文件里没有 id={node_id}", file=sys.stderr)
            return 1
        for dotted, value in fields.items():
            set_at(target, dotted, value)

    # ── 2b. rename：改节点自己的 id ──────────────────────────────────
    #
    # **必须排在 set 之后**：set 是按 id 定位的，先把 id 改了，后面的 set 就找不到了。
    # 掌灯那层有两个节点要换 id（nixos-gate → lampkeeper-gate、
    # nixos-shell → lampkeeper-shell），而且换完 name 也要跟着换——
    # 所以顺序是「先 set name，再 rename id」。
    for old_id, new_id in (ov.get("rename") or {}).items():
        node = find_by_id(doc, old_id)
        if node is None:
            print(f"rename: 父文件里没有 id={old_id}", file=sys.stderr)
            return 1
        if find_by_id(doc, new_id) is not None:
            print(f"rename: 目标 id={new_id} 已经存在", file=sys.stderr)
            return 1
        ident = get(node, "id")
        if not isinstance(ident, yaml.ScalarNode):
            print(f"rename: id={old_id} 的节点没有可改的 id 标量", file=sys.stderr)
            return 1
        ident.value = new_id

    # ── 3. delete ────────────────────────────────────────────────────
    for node_id in ov.get("delete") or []:
        hit = False
        for node in walk_nodes(doc):
            if not isinstance(node, yaml.MappingNode):
                continue
            for _, v in list(node.value):
                if isinstance(v, yaml.SequenceNode):
                    for item in list(v.value):
                        if isinstance(item, yaml.MappingNode):
                            iid = get(item, "id")
                            if isinstance(iid, yaml.ScalarNode) and iid.value == node_id:
                                v.value.remove(item)
                                hit = True
        if not hit:
            print(f"delete: 父文件里没有 id={node_id}", file=sys.stderr)
            return 1

    # ── 4. insert：进 config.plugins ────────────────────────────────
    plugins = get(config, "plugins")
    if not isinstance(plugins, yaml.SequenceNode):
        plugins = yaml.SequenceNode(SEQ, [])
        config.value.append((scalar("plugins"), plugins))
    for spec in ov.get("insert") or []:
        entry = spec.get("entry")
        if not isinstance(entry, dict) or not entry.get("id"):
            print("insert 的 entry 必须是带 id 的对象", file=sys.stderr)
            return 2
        if find_by_id(doc, entry["id"]) is not None:
            print(f"insert: id={entry['id']} 在父文件里已经存在", file=sys.stderr)
            return 1
        node = from_python(entry)
        after = spec.get("after")
        if after is None:
            plugins.value.append(node)
            continue
        idx = None
        for i, item in enumerate(plugins.value):
            if isinstance(item, yaml.MappingNode):
                iid = get(item, "id")
                if isinstance(iid, yaml.ScalarNode) and iid.value == after:
                    idx = i
                    break
        if idx is None:
            print(f"insert(after={after}): 父文件里没有那个锚点", file=sys.stderr)
            return 1
        plugins.value.insert(idx + 1, node)

    header = (
        "# ⚠️ 生成物，不要手改。\n"
        f"# 父：{parent_path.split('/presets/')[-1]}\n"
        f"# 差异：{overlay_path.split('/presets/')[-1]}\n"
        "# 改差异，然后重新构建。\n"
    )
    if meta.get("comment"):
        header += "".join(f"# {line}\n" for line in str(meta["comment"]).splitlines())
    sys.stdout.write(header)
    yaml.serialize(doc, sys.stdout, Dumper=yaml.Dumper, allow_unicode=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
