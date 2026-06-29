-- C++ snippets
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("cpp", {
  s("main", {
    t({ "#include <iostream>", "", "int main() {", "  " }), i(1, "// code"),
    t({ "", "  return 0;", "}" }),
  }),
  s("cout", {
    t('std::cout << "'), i(1, "text"), t('" << std::endl;'),
  }),
})
