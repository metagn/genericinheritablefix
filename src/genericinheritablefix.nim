import macros

proc transformTypeDef(def: NimNode): NimNode {.compileTime.} =
  result = def
  if (NimMajor, NimMinor) >= (1, 9):
    if result[0].kind != nnkPragmaExpr:
      result[0] = newTree(nnkPragmaExpr, result[0], newNimNode(nnkPragma))
    elif result[0][1].kind == nnkEmpty:
      result[0][1] = newNimNode(nnkPragma, result[0][1])
    result[0][1].add(ident"inheritable")
  else:
    var objectNode = result[^1]
    while objectNode.kind in {nnkVarTy, nnkRefTy, nnkPtrTy, nnkDistinctTy}:
      objectNode = objectNode[0]
    if objectNode.kind == nnkObjectTy:
      if objectNode[0].kind == nnkEmpty:
        objectNode[0] = newNimNode(nnkPragma, objectNode[0])
      objectNode[0].add(ident"inheritable")
    else:
      hint("got non-object type for generic inheritable", objectNode)

proc transform(node: NimNode): NimNode {.compileTime.} =
  case node.kind
  of nnkTypeDef:
    result = transformTypeDef(node)
  of nnkTypeSection, nnkStmtList:
    result = newNimNode(node.kind, node)
    for a in node:
      if a.kind in {nnkTypeDef, nnkTypeSection, nnkStmtList}:
        result.add(transform(a))
      else:
        result.add(a)
  else:
    error("cannot apply genericInheritable to node kind " & $node.kind, node)

macro genericInheritable*(node: untyped): untyped =
  result = transform(node)
