local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local PROJECT_DIAGNOSTICS = methods.internal.PROJECT_DIAGNOSTICS

local severities = {
    error = vim.lsp.protocol.DiagnosticSeverity.Error,
    warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
    ignored = vim.lsp.protocol.DiagnosticSeverity.Information,
}

return h.make_builtin({
    method = PROJECT_DIAGNOSTICS,
    filetypes = { "go" },
    generator_opts = {
        command = "staticcheck",
        to_stdin = false,
        from_stderr = false,
        ignore_stderr = false,
        args = {
            "-f",
            "json",
            "./...",
        },
        format = "line",
        check_exit_code = function(code)
            return code <= 1
        end,
        on_output = function(line, params)
            local decoded = vim.fn.json_decode(line)
            return {
                row = decoded.location.line,
                col = decoded.location.column,
                end_row = decoded["end"]["line"],
                end_col = decoded["end"]["culumn"],
                source = "staticcheck",
                code = decoded.code,
                message = decoded.message,
                severity = severities[decoded.severity],
                filename = decoded.location.file,
            }
        end,
    },
    factory = h.generator_factory,
})
