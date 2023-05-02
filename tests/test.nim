import genericinheritablefix

when (NimMajor, NimMinor) >= (1, 2): # type macro pragma
  block: # with other pragma
    type
      Foo[T] {.used, genericInheritable.} = object
      Bar[T] = object of Foo[T]

    let a = Foo[int]()
    let b = Bar[int]()
  block: # with no other pragma
    type
      Foo[T] {.genericInheritable.} = object
      Bar[T] = object of Foo[T]

    let a = Foo[int]()
    let b = Bar[int]()

block: # type section version
  genericInheritable:
    type Foo[T] {.used.} = object
  type Bar[T] = object of Foo[T]

  let a = Foo[int]()
  let b = Bar[int]()

block: # with no other pragma
  genericInheritable:
    type Foo[T] = object
  type Bar[T] = object of Foo[T]

  let a = Foo[int]()
  let b = Bar[int]()
