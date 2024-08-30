local wezterm = require('wezterm')
local util = require('tabline.util')
local config = require('tabline.config')

local M = {}

local function setup_extension(extension)
  local sections = util.deep_extend(util.deep_copy(config.opts.sections), extension.sections)
  local events = extension.events
  if sections and events then
    wezterm.on(events.show, function()
      config.sections = sections
      wezterm.log_info('Showing extension')
      if not events.hide then
        wezterm.time.call_after(events.delay or 5, function()
          wezterm.log_info('closing after time')
          config.sections = config.opts.sections
        end)
      end
    end)
    if events.hide then
      wezterm.log_info('setup hiding')
      wezterm.on(events.hide, function()
        wezterm.log_info('Hiding extension')
        if events.delay then
          wezterm.time.call_after(events.delay, function()
            config.sections = config.opts.sections
          end)
        else
          config.sections = config.opts.sections
        end
      end)
    end
  end
end

function M.load()
  for _, extension in ipairs(config.opts.extensions) do
    if type(extension) == 'string' then
      local internal_extension = require('tabline.extensions.' .. extension)
      for _, ext in ipairs(internal_extension) do
        setup_extension(ext)
      end
    elseif type(extension) == 'table' then
      setup_extension(extension)
    end
  end
end

return M
