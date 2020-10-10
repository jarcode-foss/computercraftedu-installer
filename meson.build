# Note: all identifying application information is located in this build file
project(
  'computercraftedu',
  'c',
  version: run_command('git', 'describe', '--tags', '--always').stdout().strip(),
  default_options:['buildtype=release', 'strip=true', 'optimization=2'])
formatted_app_name = 'ComputerCraftEdu'
app_manufacturer   = 'Jarcode'
app_author         = 'Levi Webb'
app_year           = '2020'
app_email          = 'unknown'
app_desc           = 'Minecraft modified with ComputerCraftEdu'

cc = meson.get_compiler('c')
is_standalone = get_option('standalone')

# Check for some programs used by scripts
find_program('find')
find_program('basename')
iheaders = find_program('iheaders')
if host_machine.system() == 'windows'
  find_program('sed')
  find_program('awk')
  find_program('head')
  find_program('bash')
  find_program('wixl')
  find_program('wixl-heat')
endif

if get_option('buildtype').startswith('debug')
  add_project_arguments('-DAPP_DEBUG', language: 'c')
else
  # Hide symbols in non-debug builds
  add_project_arguments('-fvisibility=hidden', language: 'c')
endif

app_dependencies = [
  dependency('threads'),
  dependency('libuv')
]

app_link_args = []

# Closure hack
if cc.get_id() == 'clang'
  add_project_arguments('-fblocks', language: 'c')
  app_dependencies += cc.find_library('BlocksRuntime')
endif

conf_prefix = get_option('confprefix')
if conf_prefix == 'auto'
  if get_option('prefix') == '/usr' or get_option('prefix') == '/usr/'
    conf_prefix = ''
  else
    conf_prefix = get_option('prefix')
  endif
endif
if not conf_prefix.endswith('/') and conf_prefix != '' and not get_option('sysconfdir').startswith('/')
  conf_prefix = conf_prefix + '/'
endif

sys_config_dir = conf_prefix + get_option('sysconfdir') + '/' + meson.project_name()
app_version = meson.project_version()
if app_version == ''
  app_version = 'unknown'
endif

if host_machine.system() == 'linux' or host_machine.system() == 'bsd'
  add_project_arguments('-DAPP_UNIX', language: ['c'])
endif

if host_machine.system() == 'windows'
  add_project_arguments('-DAPP_WIN', language: ['c'])
  # Fixes some unresolved symbols in some mingw libraries
  app_dependencies += cc.find_library('ssp', static: true)
  # Avoid prompt showing up
  app_link_args += '-Wl,-subsystem,windows'
endif

# Note: the OSX install directives only exist for future platform support
if host_machine.system() == 'darwin'
  add_project_arguments('-DAPP_OSX', language: ['c'])
  error('OSX targets are not supported, see issue #86.')
  # sys_config_dir = '/Library/[]/'
endif

if is_standalone
  add_project_arguments('-DAPP_STANDALONE', language: ['c'])
endif

resource_dir = get_option('prefix') + '/' + get_option('datadir') + '/' + meson.project_name()
resource_dir_base = get_option('prefix') + '/' + get_option('datadir')

if host_machine.system() == 'windows'
  # Windows uses a single installation folder
  resource_dir      = './resources'
  resource_dir_base = '.'
  sys_config_dir    = '.'
elif is_standalone
  # For running directly in the build directory
  resource_dir      = '../resources'
  resource_dir_base = '.'
  sys_config_dir    = '../config'
endif

# Generator and target for lua objects.
# This has been written such that ninja can detect when sources need to be rebuilt.

luac_input_ext  = 'lua'
luac_output_ext = 'lua'

lua_sources = run_command(
  'find', 'src', '-type', 'f', '-name', '*.' + luac_input_ext, '-print'
).stdout().strip().split('\n')
lua_targets = []
foreach s: run_command(
  'basename', '-s.' + luac_input_ext, lua_sources
).stdout().strip().split('\n')
  lua_targets += s + '.' + luac_output_ext
endforeach


# Since we're manually locating lua(jit), we have to manually set the include argument.
lua_inc_path = '/usr/include/'
lua_lib_path = '/usr/lib'
if host_machine.system() == 'windows'
  lua_inc_path = meson.get_cross_property('win_include_path') + '/'
  lua_lib_path = meson.get_cross_property('win_library_path') + '/'
endif

luac_args    = ['-o', '@OUTPUT@', '@INPUT@']
lua_impl     = get_option('lua_implementation')
lua_ver      = get_option('lua_version')
# Automatically grab latest lua version from the system, even if pkg-config cannot find it.
# This provides a hassle-free interface for building with multiple versions of lua, even
# detecting mingw lua installations.
if lua_ver == 'auto'
  # Try letting meson find it
  mcheck = dependency(lua_impl, required: false)
  if mcheck.found()
    lua_ver = mcheck.version()
    message('Located packaged lua version: ' + lua_ver)
  else
    lua_ichecks = []
    if lua_impl == 'luajit'
      if host_machine.system() == 'windows'
        lua_ichecks = ['luajit-*.*.dll']
      else
        lua_ichecks = ['libluajit-*.*.so.*']
      endif
    elif lua_impl == 'lua'
      if host_machine.system() == 'windows'
        lua_ichecks = ['lua*.dll']
      else
        lua_ichecks = ['liblua.so.*', 'liblua*.*.so.*']
      endif
    else
      error('Failed to automatically find lua version for impl: "' + lua_impl + '". Please either ' +
            'install the corresponding package(s) or manually specify the version and/or implementation.')
    endif
    latest = '0.0.0'
    icheck_collected = []
    foreach i: lua_ichecks
      icheck_collected += run_command(
        'find', lua_lib_path, '-maxdepth', '1', '-type', 'f', '-name', i, '-print'
      ).stdout().strip().split('\n')
    endforeach
    foreach s: run_command('basename', '-a', icheck_collected).stdout().strip().split('\n')
      v = '?'
      if host_machine.system() == 'windows'
        v = s.split(lua_impl)[1].split('.dll')[0]
        if v.startswith('-')
          v = v.split('-')[1]
        endif
      else
        vi = s.split('.so.')
        if vi.length() > 1
          v = s.split('.so.')[1]
        else
          v = '0.0.0'
        endif
      endif
      if lua_impl != 'luajit' and s.contains('luajit')
        v = '0.0.0'
      endif
      if v.version_compare('>' + latest)
        latest = v
      endif
    endforeach
    if latest == '0.0.0'
      error('Could not automatically determine lua version. Is it installed for the host?')
    else
      message('Located lua version: ' + latest)
      lua_ver = latest
    endif
  endif
endif
lua_inc      = get_option('lua_implementation') + get_option('lua_version')
lua_sdir     = lua_impl
vs = lua_ver.split('.')
lua_ver_s    = '.'.join([vs[0], vs[1]])
luac_name    = 'luac' + lua_ver_s
lua_mod_base = lua_impl + '/' + lua_ver_s
if get_option('lua_implementation') == 'luajit'
  # LuaJIT compiler produces better bytecode; use that
  luac_name = 'luajit'
  lua_impl += '-'
  luac_args = ['-b', '@INPUT@', '@OUTPUT@']
  if get_option('buildtype').startswith('debug')
    luac_args += '-g'
  endif
  # LuaJIT head compat only breaks on `x.x` changes, trim from `x.x.x`
  v = lua_ver.split('.')
  # LuaJIT include path follows `luajit-x.x` fmt instead of `lua/x.x`
  lua_inc = lua_impl + lua_ver_s
  # LuaJIT module path follows `luajit-x.x.x` fmt instead of `lua/x.x`
  lua_mod_base = lua_impl + lua_ver
  lua_sdir = lua_mod_base
  # LuaJIT is locked to 5.1 compatibility
  lua_ver_s = '5.1'
elif not get_option('buildtype').startswith('debug')
  luac_args = ['-s'] + luac_args
endif

lua_mod_path = lua_mod_base + '/' + meson.project_name()

p_prefix = get_option('prefix')
if host_machine.system() == 'windows'
  p_prefix = '[package local]'
elif is_standalone
  p_prefix = '[build root]'
endif
summary({ 'Prefix':               '"' + p_prefix          + '"',
          'Resources':            '"' + resource_dir      + '"',
          'Lua Module Path':      '"' + resource_dir_base + '/' + lua_mod_path + '"',
          'System Configuration': '"' + sys_config_dir    + '"' },
        section: '[Directories]')

add_project_arguments(
  # Pass the application version
  '-DAPP_VERSION="' + app_version + '"',
  # Pass the system (non user local) configuration path
  '-DAPP_SYS_CFG_PATH="' + sys_config_dir + '"',
  # Pass the resource path for other portable code (shaders) and resources
  '-DAPP_RESOURCE_PATH="' + resource_dir + '"',
  # Pass the path for loading lua modules so the stub loading code can ensure
  # that it is present in `package.path` (and warning the user if it has to be
  # added at runtime). This is primarily for forcing the application to load
  # older versions of bytecode if the lua installation was updated on the system.
  '-DAPP_LUA_PATH="' + resource_dir_base + '/' + lua_mod_base + '"',
  language: ['c'])

run_command(find_program('rm'), '-rf', meson.build_root() + '/luac-out.p')
run_command(find_program('mkdir'), '-p', meson.build_root() + '/' + lua_mod_base)
run_command(find_program('ln'), '-sfT', '../luac-out.p', meson.build_root() + '/' + lua_mod_path)

# This really hacky piece of code allows Meson to recursively track all lua
# sources and their corresponding compiled objects. Because of how generators
# work, the source tree structure has to be collapsed into a single directory;
# we resolve conflicts by preceding files with a hash and building an association
# table with the old paths.
#
# This is quite useful anyway since it obfuscates the functionality of the binary
# somewhat, and allows us to generate a table of files at build time.
g_prog    = find_program(luac_name)
g_output  = '-@BASENAME@.' + luac_output_ext
g_args    = luac_args
objs      = []
lns       = []

foreach source: run_command(
  'find', 'src', '-type', 'f', '-name', '*.' + luac_input_ext, '-print'
).stdout().strip().split('\n')
  parts = source.split('/')
  i = 0
  sorted = []
  basename = '?'
  foreach part: parts
    if i != 0 and i != parts.length() - 1
      sorted += part
    endif
    if i == parts.length() - 1
      basename = part
    endif
    i += 1
  endforeach
  pre = '/'.join(sorted)
  fmt = run_command('./lua_fmt.sh', pre).stdout().strip()
  fn = basename.split('.')
  if sorted.length() > 0
    pre += '/'
  endif
  lns += '["' + pre + basename + '"]="' + fmt + '-' + fn[0] + '.' + luac_output_ext + '"'
  
  objs += generator(g_prog, output: fmt + g_output, arguments: g_args).process(source)
endforeach
lua_index = '{' + (','.join(lns)) + '}'
g_p = []
foreach arg: g_args
  if arg == '@INPUT@'
    g_p += '-'
  elif arg == '@OUTPUT@'
    g_p += meson.build_root() + '/luac-out.p/index.lua'
  else
    g_p += arg
  endif
endforeach

run_command('mkdir', '-p', meson.build_root() + '/luac-out.p')
run_command('./lua_index.sh', luac_name + ' ' + ' '.join(g_p), lua_index)

luac_target = custom_target(
  'app-luac',
  input:            objs,
  output:           'luac-out',
  command:          [find_program('touch'), 'luac-out'],
  build_by_default: true)

# This fun little hack is to deal with systems where luajit is named
# `luajit-{lua version}` or `luajit-{luajit version}`. MinGW does the
# latter, _most_ linux distributions the former. It also handles
# different naming schemes for standard lua.
lua_found = '?'
if get_option('lua_implementation') == 'luajit'
  lj_l1 = cc.find_library(lua_impl + lua_ver_s, required: false)
  lj_l2 = cc.find_library(lua_inc,            required: false)
  assert(lj_l1.found() == true or lj_l2.found() == true,
         'Could not locate library name "' + lua_impl + lua_ver_s
         + '" or "' + lua_inc + '". Is it installed?')
  app_dependencies += [lj_l1, lj_l2]
  if lj_l1.found()
    lua_found = lua_impl + lua_ver_s
  endif
  if lj_l2.found()
    lua_found = lua_inc
  endif
else
  l_1 = cc.find_library(lua_impl + lua_ver_s, required: false)
  l_2 = cc.find_library(lua_impl, required: false)
  if l_1.found() == true
    app_dependencies += l_1
    lua_found = lua_impl + lua_ver_s
  elif l_2.found() == true
    app_dependencies += l_2
    lua_found = lua_impl
  endif
endif

pre_targets = []
pre_objects = []

if host_machine.system() == 'windows'
  # Create object for executable resources (windows fmt)
  pre_targets += custom_target(
    'app-win-icon-resource',
    input: 'resources.rc',
    output: 'resources.o',
    command: [meson.source_root() + '/generate_resources.sh',
              find_program('windres').full_path(), '@INPUT@', meson.source_root(), '@OUTDIR@',
              formatted_app_name, app_version, app_manufacturer, app_author,
              meson.project_name(), app_desc],
    build_by_default: true)
  pre_objects += meson.build_root() + '/resources.o'
endif

run_command('mkdir', '-p', meson.build_root() + '/headers')

sources = run_command(
  'find', 'src', '-type', 'f', '-name', '*.c', '-print'
).stdout().strip().split('\n')

# Generate headers on every compilation. The parsing is extremely fast so the performance
# overhead isn't worth trying to minimize.
# NOTE: disabled on this project
# 
# pre_targets += run_target('iheaders',
#                           command: ['iheaders', '-d', meson.build_root() + '/headers',
#                                     '-r', meson.source_root() + '/src', '-G'] + sources)
# 
# Strip source files with `iheaders`, and collapse the source tree paths into
# filenames separated by `@` characters (meson workaround)
# NOTE: disabled on this project
# 
# stripped_sources = []
# foreach source: sources
#   parts = source.split('/')
#   i = 0
#   sorted = []
#   foreach part: parts
#     if i != 0 and i != parts.length() - 1
#       sorted += part
#     endif
#     i += 1
#   endforeach
#   pre = '@'.join(sorted)
#   stripped_sources += generator(iheaders, output: pre + '@@BASENAME@.c',
#             arguments: ['-d', '@BUILD_DIR@', '-p', '-P', pre + '@', '@INPUT@']).process(source)
# endforeach
#
# NOTE: remove following line if iheader functionality enabled
stripped_sources = sources

exec_target = executable(
  meson.project_name(),
  link_depends: pre_targets,
  link_args:    pre_objects,
  sources:      stripped_sources,
  dependencies: app_dependencies,
  c_args:    ['-I' + meson.source_root() + '/src',
              '-I' + meson.build_root()  + '/headers',
              '-I' + lua_inc_path + lua_inc],
  install:   true)

if host_machine.system() == 'windows'
  # Create MSI package for executable
github   msi_output = meson.project_name() + '-' + meson.project_version() +
               '-' + host_machine.cpu_family()
  if get_option('buildtype').startswith('debug')
    msi_output += '-debug'
  endif
  msi_output += '-installer'
  custom_target(
    'app-win-msi',
    depends: [exec_target, luac_target],
    output: msi_output + '.msi',
    command: [meson.source_root() + '/generate_package.sh', meson.source_root(),
              meson.build_root(), lua_sdir, msi_output,
              formatted_app_name, app_version, app_manufacturer, app_author,
              meson.project_name() + '.exe', app_year, meson.get_cross_property('wixl_arch')],
    build_by_default: true)
elif host_machine.system() == 'linux' and not is_standalone
  custom_target(
    'app-freedesktop-entry',
    input: 'prototype-entry.desktop',
    output: meson.project_name() + '.desktop',
    command: [meson.source_root() + '/generate_entry.sh',
              '@INPUT@', '@OUTDIR@',
              meson.project_name(), formatted_app_name, app_desc,
              get_option('prefix') + '/' + get_option('bindir') + '/' + meson.project_name(),
              resource_dir + '/icon.ico'],
    build_by_default: true,
    install: true,
    install_dir: resource_dir_base + '/applications')
  install_subdir('config',    install_dir: sys_config_dir, strip_directory: true)
  install_subdir('resources', install_dir: resource_dir,   strip_directory: true)
  install_subdir('build/luac-out.p', install_dir: resource_dir_base + '/' + lua_mod_path,
                 strip_directory: true)
  run_command('./generate_pkgbuild.sh', meson.build_root(), meson.project_name(),
              meson.project_version(), app_desc)
  run_command('./generate_deb.sh', meson.build_root(), meson.project_name(),
              meson.project_version(), app_desc, app_author, app_email, app_year)
endif

summary({ 'Standalone': is_standalone,
          'Lua Library': lua_found,
          'Lua Implementation': get_option('lua_implementation'),
          'Lua Version': lua_ver,
          'Platform': host_machine.system() + ' ' + host_machine.cpu()
                      + ' (' + host_machine.endian() + ' endian)'},
        section: '[Configuration]')
