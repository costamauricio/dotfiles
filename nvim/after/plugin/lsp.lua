local util = require('lspconfig/util')
local lspconfig = require('lspconfig')
local coq = require('coq')

-- Check for an existant prettierrc* to enable formatting with prettier or tsserver
local function prettier_config_exists()
    local eslintrc = vim.fn.glob(".prettier*", true, true)

    if not vim.tbl_isempty(eslintrc) then
        return true
    end

    return false
end

local function phpcs_config_exists()
    local phpcs = vim.fn.glob(".phpcs*", true, true)

    if not vim.tbl_isempty(phpcs) then
        return true
    end

    return false
end

local function format_diagnostics(params, client_id, client_name, filter_out)
    for i, diagnostic in ipairs(params.diagnostics) do
        if filter_out ~= nil and filter_out(diagnostic) then
            table.remove(params.diagnostics, i)
        else
            local code = diagnostic.code or ''
            if code ~= '' then
                code = '['..code..']'
            end
            diagnostic.message = '['.. client_name ..'] '..diagnostic.message..' '..code
        end
    end

    return require('vim.lsp.diagnostic').on_publish_diagnostics(nil, params, client_id)
end

local function filter_commonjs_diagnostics(diagnostic)
    if diagnostic.severity == 4 and diagnostic.code ~= 6133 then
        return true
    end

    return false
end


-- npm install -g typescript typescript-language-server
lspconfig.tsserver.setup(coq.lsp_ensure_capabilities({
    on_attach=function(client)
        if prettier_config_exists() then
            client.server_capabilities.document_formatting = false
        end
    end,
    handlers = {
        [ "textDocument/publishDiagnostics" ] = function(_, params, client_id)
            return format_diagnostics(params, client_id, "LSP", filter_commonjs_diagnostics)
        end
    },
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "json"
    },
    flags = {
        allow_incremental_sync = true
    }
}))

local eslint = {
    lintCommand = "npx --no-install eslint -f unix --stdin --stdin-filename ${INPUT}",
    lintStdin = true,
    lintFormats = {"%f:%l:%c: %m"},
    lintIgnoreExitCode = true,
    formatCommand = "npx --no-install prettier --stdin-filepath ${INPUT}",
    formatStdin = true
}

-- install efm-langserver
-- ESLint, Prettier
lspconfig.efm.setup{
    on_attach=function(client)
        if not prettier_config_exists() then
            client.server_capabilities.document_formatting = false
        end

        client.server_capabilities.goto_definition = false
    end,
    init_options = {
        documentFormatting = true,
    },
    root_dir = util.root_pattern('.eslintrc*', '.prettierr*'),
    autostart = false,
    handlers = {
        [ "textDocument/publishDiagnostics" ] = function(_, params, client_id)
            return format_diagnostics(params, client_id, "Lint")
        end
    },
    settings = {
        languages = {
            javascript = {eslint},
            javascriptreact = {eslint},
            ["javascript.jsx"] = {eslint},
            typescript = {eslint},
            ["typescript.tsx"] = {eslint},
            typescriptreact = {eslint}
        }
    },
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescript.tsx",
        "typescriptreact"
    },
}

-- install phpactor
lspconfig.phpactor.setup(coq.lsp_ensure_capabilities({
    on_attach=function(client)
        if phpcs_config_exists() then
            client.server_capabilities.document_formatting = false
        end
    end,
    handlers = {
        [ "textDocument/publishDiagnostics" ] = function(_, params, client_id)
            return format_diagnostics(params, client_id, "LSP")
        end
    },
    init_options = {
        ["worse_reflection.stub_dir"] = "~/.composer/vendor/php-stubs"
    }
}))


local phpcs = {
    lintCommand = "php vendor/bin/phpcs --no-cache - ${INPUT}",
    lintStdin = true,
    lintFormats = {"%p%l%p|%p%tRROR%p| %m", "%p%l%p|%p%tARNING%p| %m"},
    lintIgnoreExitCode = true,
    formatCommand = "php vendor/bin/phpcbf - ${INPUT} || true",
    formatStdin = true,
}

-- PHPCS, PHPCBS
lspconfig.efm.setup{
    on_attach=function(client)
        if not phpcs_config_exists() then
            client.server_capabilities.document_formatting = false
        end

        client.server_capabilities.goto_definition = false
    end,
    init_options = {
        documentFormatting = true,
    },
    root_dir = util.root_pattern('.phpcs*'),
    autostart = true,
    handlers = {
        [ "textDocument/publishDiagnostics" ] = function(_, params, client_id)
            return format_diagnostics(params, client_id, "Lint")
        end
    },
    settings = {
        languages = {
            php = {phpcs}
        }
    },
    filetypes = {
        "php"
    },
}

-- install gopls
lspconfig.gopls.setup(coq.lsp_ensure_capabilities({
    cmd = {"gopls", "serve"},
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
        },
    },
}))
