require('codecompanion').setup({
  strategies = {
    chat = { adapter = "copilot" },
    inline = { adapter = "copilot" },
    agent = { adapter = "copilot" },
  },

  -- Configuration for the Gemini Adapter
  adapters = {
    copilot = function ()
      return require('codecompanion.adapters').extend("copilot", {
        -- will find the main plugin automatically
      })
    end,
    gemini = function()
      return require("codecompanion.adapters").extend("gemini", {
        env = {
          api_key = "cmd:echo $GEMINI_API_KEY",
        },
        schema = {
          model = {
            -- Flash is faster for autocomplete/refactor;
            -- switch to "gemini-1.5-pro" if you need deeper reasoning.
            default = "gemini-3-flash",
          },
        },
      })
    end,
  },
})
