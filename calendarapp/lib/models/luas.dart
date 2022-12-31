
class Lua {
  LuaT lua;
  DateTime data;

  Lua({required this.lua, required this.data});
}

enum LuaT {
  nova,
  crescente,
  minguante,
  cheia
}

extension symbol on LuaT {
  String toStymbol() {
    switch (this) {
      case LuaT.nova: return '🌑';
      case LuaT.minguante: return '🌘';
      case LuaT.cheia: return '🌕';
      case LuaT.crescente: return '🌒';
    }
  }
  // ···
}

