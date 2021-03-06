vim.g.mapleader = " "

local mapkey = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local format = string.format
local fn = vim.fn
local exec = vim.cmd

-------------------- Global Function ---------------------------------------
function _G.mytabline()
  local pagenum = fn.tabpagenr('$')
  local s = ''
  local i = 1
  while i <= pagenum  do
    if i == fn.tabpagenr() then
      s = s..'%#TabLineSel#'
    else
      s = s..'%#TabLine#'
    end
    s = s .. ' ' .. tostring(i) .. '.'
    local bufnr = fn.tabpagebuflist(i)[vim.fn.tabpagewinnr(i)]
    local path = fn.bufname(bufnr)
    s = s .. fn.fnamemodify(path, ":t")
    if fn.getbufvar(bufnr, '&modified') == 1 then
      s = s .. '+'
    else
      s = s .. ' '
    end
    s = s .. '%#TabLineFill#%T'
    i = i + 1
  end
  return s
end

function _G.MyWinZoomToggle()
  local zoom = vim.t.zoom
  if zoom ~= nil and zoom == 1 then
    exec(vim.t.zoom_winrestcmd)
    vim.t.zoom = 0
  else
    vim.t.zoom_winrestcmd = fn.winrestcmd()
    exec('resize | vertical resize')
    vim.t.zoom = 1
  end
end

function _G.GetFileDir()
  return fn.fnamemodify(fn.expand('%:p:h'), ':.')
end

function _G.DiffViewFile()
  exec('DiffviewOpen -uno -- ' .. fn.expand('%'))
  exec('DiffviewToggleFiles')
end

function _G.MyOpenLastplace()
  local l = fn.line("'\"")
  if l >= 1 and l <= fn.line('$') and vim.bo.filetype ~= 'commit' then
    vim.cmd([[normal! g`"]])
  end
end

function _G.MyQuit()
  local bufnrs = fn.win_findbuf(fn.bufnr())
  if #bufnrs > 1 or fn.expand('%') == '' or fn.tabpagenr('$') == 1 then
    exec('q')
  else
    exec('bd')
  end
end

function _G.MyshowDocument()
  local filetype  = vim.bo.filetype
  local word = fn.expand('<cword>')

  if filetype == 'vim' or filetype == 'lua' or filetype == 'help' then
    exec('vertical h '..word)
  else
    exec('vertical Man '..word)
  end
end

-- keymaps
local function cmd_gen(lhs, rhs)
  local gen_opts = { noremap = true }
  mapkey('n', lhs, format(':%s', rhs), gen_opts)
end

local function cmd(lhs, rhs) mapkey('n', lhs, format('<cmd>%s<cr>', rhs), opts) end
local function ino(lhs, rhs) mapkey('i', lhs, rhs, opts) end
local function nn(lhs, rhs) mapkey('n', lhs, rhs, opts) end
local function vn(lhs, rhs) mapkey('v', lhs, rhs, opts) end
local function tn(lhs, rhs) mapkey('t', lhs, rhs, opts) end
local function xcmd(lhs, rhs) mapkey('x', lhs, format(':%s<cr>', rhs), {}) end

local function init_nvim_keys()
  nn('<M-a>', '<C-w>w')
  nn('H', '^')
  nn('L', '$')
  nn('<C-j>', '5j')
  nn('<C-k>', '5k')
  nn('<M-e>', '5e')
  nn('<M-b>', '5b')
  nn('<M-w>', '5w')
  nn('<M-y>', '<C-r>')
  nn('<leader>p', '"+p')
  for i = 1, 9, 1 do
    nn(format('<M-%d>', i), format('%dgt', i))
  end

  vn('H', '^')
  vn('L', 'g_')
  vn('<C-j>', '5j')
  vn('<C-k>', '5k')
  vn('<M-e>', '5e')
  vn('<M-b>', '5b')
  vn('<leader>y', '"+y')

  cmd('<leader>s', 'w')
  cmd('<M-l>', 'tabn')
  cmd('<M-h>', 'tabp')
  cmd('<leader><leader>q', 'qa')
  cmd('<leader>q', 'call v:lua.MyQuit()')
  cmd('K', 'call v:lua.MyshowDocument()')
  cmd('<leader>rt', '%retab!')
  cmd('<leader>z', 'call v:lua.MyWinZoomToggle()')
  cmd('<M-q>', [[exe('tabn '.g:last_active_tab)]])
  cmd('<M-s>', [[let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>]]) -- remove trailing whitespace

  ino('<C-j>', '<Down>')
  ino('<C-k>', '<Up>')
  -- insert mode like bash
  ino('<C-b>', '<Left>')
  ino('<C-f>', '<Right>')
  ino('<C-a>', '<Home>')
  ino('<C-e>', '<End>')
  ino('<C-d>', '<Delete>')
  ino('<C-h>', '<Backspace>')
  ino('<M-b>', '<C-Left>')
  ino('<M-f>', '<C-Right>')
  ino('<M-d>', '<C-o>diw')

  tn('<M-e>', '<C-\\><C-n>')
end

local function init_plugins_keymaps()
  -- terminal
  cmd('<leader>tt', 'FTermToggle')

  -- inline edit
  cmd('<leader>e', 'InlineEdit')

  -- easy align
  xcmd('ga', 'EasyAlign')

  -- nvim tree
  cmd('<leader>tj', 'Fern . -reveal=% -drawer')
  cmd('<leader>tr', 'Fern . -drawer')

  -- highlight group
  cmd('<leader>k', 'Interestingwords --toggle')
  cmd('<leader>K', 'Interestingwords --remove_all')
  cmd('<leader>n', 'Interestingwords --navigate')
  cmd('<leader>N', 'Interestingwords --navigate b')

  -- fzf_utils
  cmd('<C-p>', 'FzfCommand --files')
  cmd('<C-f>', 'FzfCommand --lines')
  cmd('<C-r>', 'FzfCommand --ctags')
  cmd('<leader>b', 'FzfCommand --buffers')
  cmd('<leader><leader>m', 'FzfCommand --man')
  cmd('<leader><leader>h', 'FzfCommand --vim help')
  cmd('<leader>h', 'FzfCommand --vim cmdHists')
  cmd('<leader>ft', 'FzfCommand --vim filetypes')
  cmd('<leader>fd', [[exe('FzfCommand --gtags -d '.expand('<cword>'))]])
  cmd('<leader>fr', [[exe("FzfCommand --gtags -r ".expand("<cword>"))]])
  cmd('<leader>fu', 'FzfCommand --gtags --update')
  cmd('<leader>fb', 'FzfCommand --gtags --update-buffer')
  cmd('<M-f>', [[exe('FzfCommand --rg --all-buffers '.expand('<cword>'))]])
  cmd('<leader>ff', [[exe('FzfCommand --rg '.expand('<cword>')." ".expand('%'))]])
  cmd('<M-j>', 'FzfCommand --lsp jump_def edit')
  cmd('<M-t>', 'FzfCommand --lsp jump_def tab drop')
  cmd('<M-v>', 'FzfCommand --lsp jump_def vsplit')
  cmd('<leader>rr', 'FzfCommand --lsp ref tab drop')
  cmd('<leader>m', 'FzfCommand --mru')

  cmd_gen('<leader>d', [[<C-U><C-R>=printf('FzfCommand --rg %s %s', expand('<cword>'), v:lua.GetFileDir())<CR>]])
  cmd_gen('<leader>fa', [[<C-U><C-R>='FzfCommand --rg '.expand('<cword>')<CR>]])

  -- diffview.nvim
  cmd('<leader><leader>d', [[exe('DiffviewOpen -uno -- '.v:lua.GetFileDir())]])
  cmd('<leader><leader>c', 'call v:lua.DiffViewFile()')

  -- compe
  local expr_opts = { expr = true }
  mapkey('i', '<Tab>', 'v:lua.tab_complete()', expr_opts)
  mapkey('i', '<S-Tab>', 'v:lua.s_tab_complete()', expr_opts)
  mapkey('i', '<CR>', 'v:lua.completion_confirm()', { expr = true, noremap = true })

  -- lspsaga
  cmd('<M-r>', 'Lspsaga lsp_finder')
  cmd('<M-k>', 'Lspsaga hover_doc')
  cmd('<leader>rn', 'Lspsaga rename')
  cmd('<leader>j', "lua require('lspsaga.action').smart_scroll_with_saga(1)")
  cmd('<leader>ca', 'Lspsaga code_action')
  cmd('<leader><leader>p', 'Lspsaga preview_definition')
  cmd('<M-o>', 'Lspsaga show_line_diagnostics')
  ino('<M-k>', '<cmd>Lspsaga signature_help<CR>')
  cmd('<leader>a', 'Lspsaga diagnostic_jump_next')

  -- lsp
  cmd('<space>wa', 'lua vim.lsp.buf.add_workspace_folder()')
  cmd('<space>wr', 'lua vim.lsp.buf.remove_workspace_folder()')
  cmd('<space>wl', 'lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))')
  cmd('<leader><space>f', 'lua vim.lsp.buf.formatting()')
  vn('<leader><space>f', '<cmd>lua vim.lsp.buf.range_formatting()<cr>')

  cmd('<leader>v', 'SymbolsOutline')
end

init_nvim_keys()
init_plugins_keymaps()

-- options
local global_cfg = {
  hidden = true;
  backup = false;
  writebackup = false;
  autoread = true;
  autowrite = true;
  smarttab = true;
  smartindent = true;
  scrolloff = 10;
  undofile = true;
  incsearch = true;
  ignorecase = true;
  smartcase = true;
  termguicolors = true;
  laststatus = 2;
  showtabline = 2;
  updatetime = 500;
  shortmess = 'aoOTIcF';
  completeopt = 'menuone,noselect';
  tabline = '%!v:lua.mytabline()'
}
local win_cfg = {
  signcolumn = "yes";
  number = true;
  cul = true;
}
local buf_cfg = {
  tabstop = 4;
  shiftwidth = 4;
  softtabstop = 4;
  swapfile = false;
  undofile = true;
};
for k, v in pairs(global_cfg) do
  vim.o[k] = v
end
for k, v in pairs(win_cfg) do
  vim.wo[k] = v
end
for k, v in pairs(buf_cfg) do
  vim.opt[k] = v
end

require('plugins')

exec([[
  set list lcs=tab:→\ ,trail:·
  augroup user_plugin
    autocmd!
    au TabLeave * let g:last_active_tab = tabpagenr() " tab switch
    au BufWinEnter * call v:lua.MyOpenLastplace()
    au FocusGained * :checkt
    au WinEnter * if ! &cursorline | setlocal cul | endif
    au TextYankPost * silent! lua vim.highlight.on_yank{ higroup = "IncSearch", timeout = 700 }
  augroup END
]])
