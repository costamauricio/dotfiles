-- vim.g.coq_settings = {
--   keymap = { jump_to_mark = '' },
--   auto_start = 'shut-up',
--   clients = {
--     tmux = { enabled = false },
--   },
-- }

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
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
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  --nmap('<leader>is', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

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
      diagnostics = {
        globals = { 'vim' },
      },
    },
  },
  clangd = {},
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = servers[server_name],
    }
  end,
  ["gopls"] = function()
    require('lspconfig').gopls.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      handlers = {
        ["textDocument/implementation"] = function(err, result, params)
          if err ~= nil then
            print(err.message)
            return
          end

          local new_result = vim.tbl_filter(function(v)
            return not string.find(v.uri, "mock")
          end, result)

          if #new_result > 0 then
            result = new_result
          end

          vim.lsp.handlers["textDocument/implementation"](err, result, params)
        end
      },
      settings = servers[server_name],
    }
  end,
  ["clangd"] = function()
      require('lspconfig').clangd.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = servers[server_name],
        on_new_config = function(new_config, new_root_dir)
          local cmd_file = require('lspconfig.util').path.join(new_root_dir, ".clangd-executable")

          local f = io.open(cmd_file, "r")
          if f ~= nil then
            local content = f:read("*l")
            f:close()
            new_config.cmd = { content }
            vim.notify("clangd path: " .. content, vim.log.levels.INFO)
          end
        end
      }
  end
}

-- vim.lsp.buf_request(0, "textDocument/implementation", vim.lsp.util.make_position_params(), function(err, method, result, client_id, bufnr, config)
--   local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
--
--   -- In go code, I do not like to see any mocks
--   if ft == "go" then
--     local new_result = vim.tbl_filter(function(v)
--       return not string.find(v.uri, "mocks")
--     end, result)
--
--     if #new_result > 0 then
--       result = new_result
--     end
--   end
--
--   vim.lsp.handlers["textDocument/implementation"](err, method, result, client_id, bufnr, config)
--   vim.cmd("normal! zz")
-- end)

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
-- -- arduino-language-server
-- require'lspconfig'.arduino_language_server.setup(coq.lsp_ensure_capabilities({
--     cmd = {
--         "arduino-language-server",
--         "-clangd",  "/usr/bin/clangd",
--         "-cli", "/opt/homebrew/bin/arduino-cli",
--         "-cli-config", "$HOME/Library/Arduino15/arduino-cli.yaml",
--     }
-- }))
