local telescope     = require'telescope'
local finders       = require'telescope.finders'
local pickers       = require'telescope.pickers'
local entry_display = require'telescope.pickers.entry_display'
local actions       = require'telescope.actions'
local action_state  = require'telescope.actions.state'
local conf          = require'telescope.config'.values
local api,fn = vim.api,vim.fn

local displayer = entry_display.create{
    separator = ' ',
    items = {
        {width = 2},
        {width = 10},
        {remaining = true}
    }
}
return telescope.register_extension{
    exports = {
        ['emoji-finder'] = function(opts)
            pickers.new(opts,{
                prompt_title = 'Emoji',
                sorter = conf.generic_sorter(opts),
                finder = finders.new_table{
                    results = require'telescope-emoji-finder.get_emojis',
                    entry_maker = function(entry)
                        return {
                            ordinal = entry.description .. ' ' .. entry.name,
                            name    = entry.name,
                            value   = entry.value,
                            category = entry.category,
                            display = function()
                                return displayer{
                                    entry.value,
                                    entry.name,
                                    {entry.description,'Comment'}
                                }
                            end
                        }
                    end
                },
                attach_mappings = function(prompt_bufnr,map)
                    actions.select_default:replace(function()
                        local emoji = action_state.get_selected_entry().value
                        actions.close(prompt_bufnr)
                        api.nvim_put({emoji},'c',true,true)
                    end)
                    map('i','<C-y>',function()
                        local emoji = action_state.get_selected_entry().value
                        actions.close(prompt_bufnr)
                        if vim.o.clipboard == 'unnamedplus' then
                            fn.setreg('+',emoji)
                        else
                            fn.setreg('*',emoji)
                        end
                    end)
                    return true
                end
            }):find()
        end
    }
}
