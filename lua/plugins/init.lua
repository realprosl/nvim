return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
  },
  {
    "rcarriga/nvim-notify",
    config = function()
      -- Configurar nvim-notify como el sistema de mensajes predeterminado de Neovim
      vim.notify = require("notify")

      require("notify").setup({
        stages = "fade", -- Animación de las notificaciones ("fade", "slide", "fade_in_slide_out", "static")
        timeout = 3000,  -- Duración de la notificación en milisegundos
        background_colour = "#000000", -- Color de fondo
        fps = 60,         -- FPS para animaciones
        render = "default", -- Opciones: "default", "minimal", "compact"
        top_down = true   -- Si las notificaciones aparecen desde arriba o abajo
      })
    end
  },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
