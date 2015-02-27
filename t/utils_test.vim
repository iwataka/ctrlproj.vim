describe 'ctrlproj#utils#contains'
  it 'returns 1'
    let list = ['a', 'b', 'c', 'd', 'e']
    Expect ctrlproj#utils#contains(list, 'a') == 1
    Expect ctrlproj#utils#contains(list, 'b') == 1
    Expect ctrlproj#utils#contains(list, 'c') == 1
    Expect ctrlproj#utils#contains(list, 'd') == 1
    Expect ctrlproj#utils#contains(list, 'e') == 1
  end

  it 'returns 0'
    let list = ['a', 'b', 'c', 'd', 'e']
    Expect ctrlproj#utils#contains(list, 'f') == 0
    Expect ctrlproj#utils#contains(list, 'g') == 0
    Expect ctrlproj#utils#contains(list, 'h') == 0
  end
end

describe 'ctrlproj#utils#partition'
  it 'returns "foo" and "bar"'
    let str = "foo***bar"
    Expect ctrlproj#utils#partition(str, '***') == ['foo', 'bar']
  end

  it 'returns "foobar" and ""'
    let str = "foobar***"
    Expect ctrlproj#utils#partition(str, '***') == ['foobar', '']
  end
end

describe 'ctrlproj#utils#add_dirs'
  it 'returns ["autoload/ctrlproj"]'
    let result = []
    let file = "autoload/ctrlproj/utils.vim"
    let dir = fnamemodify(file, ':h')
    let paths = [file, dir]
    cal ctrlproj#utils#add_dirs(result, paths)
    Expect result == ['autoload/ctrlproj']
  end

  it 'returns ["t/fixtures"]'
    let result = []
    let file = "t/fixtures/path_config"
    let dir = fnamemodify(file, ':h')
    let paths = [file, dir]
    cal ctrlproj#utils#add_dirs(result, paths)
  end
end

describe 'ctrlproj#utils#read_paths'
  it 'returns a list one of whose items contains "autoload/ctrlproj"'
    let paths = ctrlproj#utils#parse_file('t/fixtures/path_config')
    Expect ctrlproj#utils#contains_regex(paths, 'autoload/ctrlproj') == 1
    Expect ctrlproj#utils#contains_regex(paths, 't/fixtures') == 0
  end
end
