-- package (plugins)
require('packer').startup(function()
    use 'wbthomason/packer.nvim'

    -- colorscheme
    use 'tomasr/molokai'
    use 'dracula/vim'
    use 'arcticicestudio/nord-vim'
    use 'sainnhe/sonokai'

    -- quality of life --
    ---------------------
    -- vimwiki
    use {
        'vimwiki/vimwiki',
        config = function() require("plugin-configs/vimwiki") end
    }

    -- alpha (start screen)
    use {
        'goolord/alpha-nvim',
        requires = { 'nvim-tree/nvim-web-devicons' },
        config = function () require("plugin-configs/alpha-nvim") end
    }

    -- floaterm
    use {
        'voldikss/vim-floaterm',
        config = function() require("plugin-configs/vim-floaterm") end
    }

    -- folder treeview
    --[[ use {                      -- nvim-tree requires nvim >= 0.8.0 --
        'nvim-tree/nvim-tree.lua',
        requires = { 'nvim-tree/nvim-web-devicons' },
        config = function() require("plugin-configs/nvim-tree") end
    } --]]

    use {                           -- alternative to nvim-tree --
        'preservim/nerdtree',
        requires = { 'ryanoasis/vim-devicons' },
        config = function() require("plugin-configs/nerdtree") end
    }

    -- telescope
    use {
        'nvim-telescope/telescope.nvim',
        requires = { 'nvim-lua/plenary.nvim' },
        config = function() require("plugin-configs/telescope_nvim") end
    }
    ---------------------

    -- IDE --
    ---------
    -- parser
    use {
        'nvim-treesitter/nvim-treesitter',
        -- config = function() require("plugin-configs/nvim-treesitter") end
    }

    -- LSP
    use 'neovim/nvim-lspconfig'
    use {
        'williamboman/nvim-lsp-installer',
        requires = { 'neovim/nvim-lspconfig' },
        -- config = function() require("plugin-configs/nvim-lsp-installer") end
    }

    -- cmake
    use {
        'cdelledonne/vim-cmake',
        config = function() require("plugin-configs/vim-cmake") end
    }

    -- nvim-cmp (completion)
    --[[ use {
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'SirVer/ultisnips',                     -- required by nvim-cmp
            'quangnguyen30192/cmp-nvim-ultisnips'   -- required by ultisnips
        },
        config = function() require("plugin-configs/nvim-cmp") end
    } --]]

    -- coq (completion)
    use {
        'ms-jpq/coq_nvim',
        branch = 'coq'
    }
    ---------

end)


