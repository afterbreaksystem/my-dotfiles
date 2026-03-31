vim.g.mapleader = " "
vim.opt.termguicolors = true
vim.opt.hidden = true
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.shortmess:append("I")
vim.opt.clipboard = "unnamedplus"

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end
local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use { 'akinsho/bufferline.nvim', requires = 'nvim-tree/nvim-web-devicons' }
  use 'kdheepak/monochrome.nvim'
  use { 'nvim-tree/nvim-tree.lua', requires = 'nvim-tree/nvim-web-devicons' }
  use 'nvim-lualine/lualine.nvim'
  use 'xiyaowong/transparent.nvim'
  use { 'nvim-telescope/telescope.nvim', requires = { {'nvim-lua/plenary.nvim'} } }
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
  use {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
        require("nvim-autopairs").setup {}
    end
}
  if packer_bootstrap then require('packer').sync() end
end)

local status_bl, bufferline = pcall(require, "bufferline")
if status_bl then
  bufferline.setup({
    options = {
      mode = "buffers",
      style_preset = bufferline.style_preset.default,
      separator_style = "thin",
      always_show_bufferline = true,
      show_buffer_close_icons = false,
      show_close_icon = false,
      color_icons = false,
      diagnostics = "nvim_lsp",
      offsets = {{ filetype = "NvimTree", text = "EXPLORER", text_align = "center", separator = true }},
      indicator = { style = 'underline' },
    }
  })
end

vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>', { silent = true })
vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', { silent = true })
vim.keymap.set('n', '<leader>x', ':bd!<CR>', { silent = true })

local status_ll, lualine = pcall(require, "lualine")
if status_ll then
  local custom_mono = {
    normal = {
      a = { fg = '#ffffff', bg = '#262626', gui = 'bold' },
      b = { fg = '#ffffff', bg = '#3a3a3a' },
      c = { fg = '#ffffff', bg = '#121212' },
    },
    insert = {
      a = { fg = '#000000', bg = '#ffffff', gui = 'bold' },
      b = { fg = '#ffffff', bg = '#3a3a3a' },
    },
    visual = {
      a = { fg = '#000000', bg = '#767676', gui = 'bold' },
      b = { fg = '#ffffff', bg = '#3a3a3a' },
    },
    inactive = {
      a = { fg = '#767676', bg = '#121212' },
      b = { fg = '#767676', bg = '#121212' },
    },
  }
  lualine.setup({
    options = {
      theme = custom_mono,
      icons_enabled = true,
      section_separators = { left = '', right = '' },
      component_separators = { left = '', right = '' },
      globalstatus = true,
    },
    sections = {
      lualine_a = { { 'mode', fmt = function(str) return ' ' .. str end } },
      lualine_b = { 'branch', 'diff', 'diagnostics' },
      lualine_c = { { 'filename', path = 1 } },
      lualine_x = { 'filetype' },
      lualine_y = { 'progress' },
      lualine_z = { 'location' }
    }
  })
end

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = { "pyright" },
  handlers = {
    function(server_name)
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      vim.lsp.config(server_name, { capabilities = capabilities })
      vim.lsp.enable(server_name)
    end,
  }
})


local cmp = require('cmp')
local luasnip = require('luasnip')
cmp.setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
      else fallback() end
    end, { 'i', 's' }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({{ name = 'nvim_lsp' }, { name = 'luasnip' }}, {{ name = 'buffer' }})
})

local status_nt, nvimtree = pcall(require, "nvim-tree")
if status_nt then
  nvimtree.setup({ view = { width = 30 }, renderer = { icons = { show = { file = true, folder = true } } } })
end
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { silent = true })
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, {})

pcall(vim.cmd, 'colorscheme monochrome')

