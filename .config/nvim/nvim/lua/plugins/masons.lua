return {
  {
    "mason-org/mason.nvim",
    -- enabled=false,
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },
}
