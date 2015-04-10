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

describe 'ctrlproj#utils#parse_file'
  it 'returns a list one of whose items contains "autoload/ctrlproj"'
    let paths = ctrlproj#utils#parse_file('t/fixtures/path_config')
    Expect ctrlproj#utils#contains_regex(paths, 'autoload/ctrlproj') == 1
    Expect ctrlproj#utils#contains_regex(paths, 't/fixtures') == 0
  end
end

describe 'ctrlproj#utils#convert_path_wildcard'
  it 'returns "\\(.*\\)src/main/java/\\(\\([^/]\\+/\\)*\\)\\([^/]\\+\\).java"'
    let path = 'src/main/java/**/*.java'
    let result = '\(.*\)src/main/java/\(\([^/]\+/\)*\)\([^/]\+\).java'
    Expect ctrlproj#utils#convert_wildcard_to_regex(path) == result
end

describe 'ctrlproj#utils#switch_by_templates'
  it 'can switch in java project'
    let dict = {'src/main/java/**/*.java': 'src/test/java/**/*Test.java'}
    let main = 'path/to/sub/proj/src/main/java/foo/package/Bar.java'
    let test = 'path/to/sub/proj/src/test/java/foo/package/BarTest.java'
    Expect ctrlproj#utils#switch_by_template(main, dict) == test
    Expect ctrlproj#utils#switch_by_template(test, dict) == main
  end
  it 'can switch in scala project'
    let dict = {'src/main/scala/**/*.scala': 'src/test/scala/**/*Test.scala'}
    let main = 'path/to/sub/proj/src/main/scala/foo/package/Bar.scala'
    let test = 'path/to/sub/proj/src/test/scala/foo/package/BarTest.scala'
    Expect ctrlproj#utils#switch_by_template(main, dict) == test
    Expect ctrlproj#utils#switch_by_template(test, dict) == main
  end
  it 'can switch in ruby-on-rails project'
    let dict = {
      \ 'app/admin/*.rb': 'spec/features/admin/*_spec.rb',
      \ 'app/controllers/*_controller.rb': 'spec/controllers/*_controller_spec.rb',
      \ 'app/decorators/*_decorator.rb': 'spec/decorators/*_decorator_spec.rb',
      \ 'app/helpers/*_helper.rb': 'spec/helpers/*_helper_spec.rb',
      \ 'app/mailers/*_mailers.rb': 'spec/mailers/*_mailer_spec.rb',
      \ 'app/models/*.rb': 'spec/models/*_spec.rb',
      \ 'app/workers/*.rb': 'spec/workers/*_spec.rb'
      \ }
    let admin = 'path/to/sub/proj/app/admin/foo.rb'
    let admin_spec = 'path/to/sub/proj/spec/features/admin/foo_spec.rb'
    Expect ctrlproj#utils#switch_by_template(admin, dict) == admin_spec
    Expect ctrlproj#utils#switch_by_template(admin_spec, dict) == admin
    let con = 'path/to/sub/proj/app/controllers/foo_controller.rb'
    let con_spec = 'path/to/sub/proj/spec/controllers/foo_controller_spec.rb'
    Expect ctrlproj#utils#switch_by_template(con, dict) == con_spec
    Expect ctrlproj#utils#switch_by_template(con_spec, dict) == con
    let dec = 'path/to/sub/proj/app/decorators/foo_decorator.rb'
    let dec_spec = 'path/to/sub/proj/spec/decorators/foo_decorator_spec.rb'
    Expect ctrlproj#utils#switch_by_template(dec, dict) == dec_spec
    Expect ctrlproj#utils#switch_by_template(dec_spec, dict) == dec
  end
end

describe 'ctrlproj#utils#switch_by_regexp'
  it 'can switch in a project in Java and Scala'
    let cands = [
      \ 'path/to/sub/proj/src/main/java/foo/package/Ba.java',
      \ 'path/to/sub/proj/src/main/java/foo/package/Bar.java',
      \ 'path/to/sub/proj/src/test/scala/foo/package/BarTest.scala',
      \ 'path/to/sub/proj/src/main/java/foo/package/Foo.java',
      \ 'path/to/sub/proj/src/test/scala/foo/package/FooTest.scala',
      \ 'path/to/sub/proj/src/main/scala/foo/package/FooBar.scala'
      \ ]
    let main = 'path/to/sub/proj/src/main/java/foo/package/Bar.java'
    let test = 'path/to/sub/proj/src/test/scala/foo/package/BarTest.scala'
    Expect ctrlproj#utils#switch_by_regexp(main, cands) == [test]
    Expect ctrlproj#utils#switch_by_regexp(test, cands) == [main]
  end
end
