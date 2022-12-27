local telescope = require('telescope')

telescope.setup {
    defaults = {
        file_ignore_patterns = {'.git/'}
    },
    extensions = {
        fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
        }
    }
}

telescope.load_extension('fzy_native')
