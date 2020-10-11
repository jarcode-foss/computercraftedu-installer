
#ifndef APP_NAME
#define APP_NAME "?"
#error "`APP_NAME` is not defined!"
#endif
#ifndef APP_FNAME
#define APP_FNAME "?"
#error "`APP_FNAME` is not defined!"
#endif
#ifndef APP_VERSION
#define APP_VERSION "0.0"
#error "`APP_VERSION` is not defined!"
#endif
#ifndef APP_SYS_CFG_PATH
#define APP_SYS_CFG_PATH "."
#error "`APP_SYS_CFG_PATH` is not defined!"
#endif
#ifndef APP_RESOURCE_PATH
#define APP_RESOURCE_PATH "."
#error "`APP_RESOURCE_PATH` is not defined!"
#endif
#ifndef APP_LUA_PATH
#define APP_LUA_PATH "."
#error "`APP_LUA_PATH` is not defined!"
#endif

#define APP_LUA_MOD APP_LUA_PATH "/" APP_NAME

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>

#include <lua5.1/lua.h>
#include <lua5.1/lauxlib.h>
#include <lua5.1/lualib.h>

#include <curl/curl.h>

static lua_State* L;
static int app_state = EXIT_SUCCESS;

static bool luaA_loadfile(lua_State* L, const char* path) {
    switch (luaL_loadfile(L, path)) {
        case 0: break;
        case LUA_ERRSYNTAX:
        case LUA_ERRMEM:
        case LUA_ERRFILE:
        default: {
            const char* ret = lua_tostring(L, -1);
            fprintf(stderr, "unexpected error loading '%s': %s\n", path, ret);
            app_state = EXIT_FAILURE;
            return false;
        }
    }
    return true;
}

static bool luaA_calltop(lua_State* L) {
    switch (lua_pcall(L, 0, 0, 0)) {
        case 0: break;
        case LUA_ERRRUN:
        case LUA_ERRMEM:
        default: {
            const char* ret = lua_tostring(L, -1);
            fprintf(stderr, "unexpected error running chunk: %s\n", ret);
            app_state = EXIT_FAILURE;
            return false;
        }
        case LUA_ERRERR: {
            fprintf(stderr, "error running non-existent error handler function (?)\n");
            app_state = EXIT_FAILURE;
            return false;
        }
    }
    return true;
}

int main(int argc, char** argv) {
    L = luaL_newstate();
    luaL_openlibs(L);
    lua_pushstring(L, APP_LUA_PATH);
    lua_setfield(L, LUA_GLOBALSINDEX, "__LUA_PATH");
    if (!luaA_loadfile(L, APP_LUA_MOD "/index.lua"))
        goto close;
    if (!luaA_calltop(L))
        goto close;
    lua_getfield(L, LUA_GLOBALSINDEX, "__BUILTIN_INDEX");
    lua_getfield(L, -1, "init.lua");
    {
        const char* ret = lua_tostring(L, -1);
        size_t blen = strlen(APP_LUA_MOD) + strlen(ret) + 2;
        char buf[blen];
        snprintf(buf, blen, "%s/%s", APP_LUA_MOD, ret);
        printf("executing: '%s'\n", buf);
        if (!luaA_loadfile(L, buf))
            goto close;
        if (!luaA_calltop(L))
            goto close;
    }
    lua_pop(L, 2); /* _G.__BUILTIN_INDEX, _G.__BUILTIN_INDEX["init.lua"] */
    
close:
    lua_close(L);
    fflush(stdout);
    if (app_state == EXIT_FAILURE)
        fprintf(stderr, "exiting due to fatal error\n");
    return app_state;
}
