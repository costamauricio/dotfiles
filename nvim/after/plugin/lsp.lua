vim.g.coq_settings = {
  keymap = { jump_to_mark = '' },
  auto_start = 'shut-up',
  clients = {
    tmux = { enabled = false },
  },
}

local coq = require'coq'

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>re', vim.lsp.buf.rename, '[R][e]name')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  --nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  --nmap('<leader>is', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  --nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  --nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  --nmap('<leader>wl', function()
  --print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  --end, '[W]orkspace [L]ist Folders')

  nmap('<leader>ff', function()
    vim.lsp.buf.format({ async = true })
  end, '[F]ormat current [f]ile')

  vim.api.nvim_create_autocmd({ 'CursorHold' }, {
    buffer = bufnr,
    callback = function()
      vim.diagnostic.open_float()
    end
  })
end

local servers = {
  gopls = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
  rust_analyzer = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup(coq.lsp_ensure_capabilities({
      on_attach = on_attach,
      settings = servers[server_name],
    }))
  end,
}

-- local util = require('lspconfig/util')
-- local lspconfig = require('lspconfig')
-- local coq = require('coq')
--
-- -- Check for an existant prettierrc* to enable formatting with prettier or tsserver
-- local function prettier_config_exists()
--     local eslintrc = vim.fn.glob(".prettier*", true, true)
--
--     if not vim.tbl_isempty(eslintrc) then
--         return true
--     end
--
--     return false
-- end
--
-- local function phpcs_config_exists()
--     local phpcs = vim.fn.glob(".phpcs*", true, true)
--
--     if not vim.tbl_isempty(phpcs) then
--         return true
--     end
--
--     return false
-- end
--
-- local function format_diagnostics(params, client_id, client_name, filter_out)
--     for i, diagnostic in ipairs(params.diagnostics) do
--         if filter_out ~= nil and filter_out(diagnostic) then
--             table.remove(params.diagnostics, i)
--         else
--             local code = diagnostic.code or ''
--             if code ~= '' then
--                 code = '['..code..']'
--             end
--             diagnostic.message = '['.. client_name ..'] '..diagnostic.message..' '..code
--         end
--     end
--
--     return require('vim.lsp.diagnostic').on_publish_diagnostics(nil, params, client_id)
-- end
--
-- local function filter_commonjs_diagnostics(diagnostic)
--     if diagnostic.severity == 4 and diagnostic.code ~= 6133 then
--         return true
--     end
--
--     return false
-- end
--
--
-- -- npm install -g typescript typescript-language-server
-- lspconfig.tsserver.setup(coq.lsp_ensure_capabilities({
--     on_attach=function(client)
--         if prettier_config_exists() then
--             client.server_capabilities.document_formatting = false
--         end
--     end,
--     handlers = {
--         [ "textDocument/publishDiagnostics" ] = function(_, params, client_id)
--             return format_diagnostics(params, client_id, "LSP", filter_commonjs_diagnostics)
--         end
--     },
--     filetypes = {
--         "javascript",
--         "javascriptreact",
--         "javascript.jsx",
--         "typescript",
--         "typescriptreact",
--         "typescript.tsx",
--         "json"
--     },
--     flags = {
--         allow_incremental_sync = true
--     }
-- }))
--
-- local eslint = {
--     lintCommand = "npx --no-install eslint -f unix --stdin --stdin-filename ${INPUT}",
--     lintStdin = true,
--     lintFormats = {"%f:%l:%c: %m"},
--     lintIgnoreExitCode = true,
--     formatCommand = "npx --no-install prettier --stdin-filepath ${INPUT}",
--     formatStdin = true
-- }
--
-- -- install efm-langserver
-- -- ESLint, Prettier
-- lspconfig.efm.setup{
--     on_attach=function(client)
--         if not prettier_config_exists() then
--             client.server_capabilities.document_formatting = false
--         end
--
--         client.server_capabilities.goto_definition = false
--     end,
--     init_options = {
--         documentFormatting = true,
--     },
--     root_dir = util.root_pattern('.eslintrc*', '.prettierr*'),
--     autostart = false,
--     handlers = {
--         [ "textDocument/publishDiagnostics" ] = function(_, params, client_id)
--             return format_diagnostics(params, client_id, "Lint")
--         end
--     },
--     settings = {
--         languages = {
--             javascript = {eslint},
--             javascriptreact = {eslint},
--             ["javascript.jsx"] = {eslint},
--             typescript = {eslint},
--             ["typescript.tsx"] = {eslint},
--             typescriptreact = {eslint}
--         }
--     },
--     filetypes = {
--         "javascript",
--         "javascriptreact",
--         "javascript.jsx",
--         "typescript",
--         "typescript.tsx",
--         "typescriptreact"
--     },
-- }
--
-- -- install phpactor
-- lspconfig.phpactor.setup(coq.lsp_ensure_capabilities({
--     on_attach=function(client)
--         if phpcs_config_exists() then
--             client.server_capabilities.document_formatting = false
--         end
--     end,
--     handlers = {
--         [ "textDocument/publishDiagnostics" ] = function(_, params, client_id)
--             return format_diagnostics(params, client_id, "LSP")
--         end
--     },
--     init_options = {
--         ["worse_reflection.stub_dir"] = "~/.composer/vendor/php-stubs"
--     }
-- }))
--
--
-- local phpcs = {
--     lintCommand = "php vendor/bin/phpcs --no-cache - ${INPUT}",
--     lintStdin = true,
--     lintFormats = {"%p%l%p|%p%tRROR%p| %m", "%p%l%p|%p%tARNING%p| %m"},
--     lintIgnoreExitCode = true,
--     formatCommand = "php vendor/bin/phpcbf - ${INPUT} || true",
--     formatStdin = true,
-- }
--
-- -- PHPCS, PHPCBS
-- lspconfig.efm.setup{
--     on_attach=function(client)
--         if not phpcs_config_exists() then
--             client.server_capabilities.document_formatting = false
--         end
--
--         client.server_capabilities.goto_definition = false
--     end,
--     init_options = {
--         documentFormatting = true,
--     },
--     root_dir = util.root_pattern('.phpcs*'),
--     autostart = true,
--     handlers = {
--         [ "textDocument/publishDiagnostics" ] = function(_, params, client_id)
--             return format_diagnostics(params, client_id, "Lint")
--         end
--     },
--     settings = {
--         languages = {
--             php = {phpcs}
--         }
--     },
--     filetypes = {
--         "php"
--     },
-- }
--
-- -- install gopls
-- lspconfig.gopls.setup(coq.lsp_ensure_capabilities({
--     cmd = {"gopls", "serve"},
--     settings = {
--         gopls = {
--             analyses = {
--                 unusedparams = true,
--             },
--             staticcheck = true,
--         },
--     },
-- }))
--
-- -- rust_analyzer
-- require'lspconfig'.rust_analyzer.setup(coq.lsp_ensure_capabilities({}))
--
-- -- arduino-language-server
-- require'lspconfig'.arduino_language_server.setup(coq.lsp_ensure_capabilities({
--     cmd = {
--         "arduino-language-server",
--         "-clangd",  "/usr/bin/clangd",
--         "-cli", "/opt/homebrew/bin/arduino-cli",
--         "-cli-config", "$HOME/Library/Arduino15/arduino-cli.yaml",
--     }
-- }))
