local source = require 'otter.completion.source'

local M = {}

---Registered client and source mapping.
M.cmp_client_source_map = {}

---Setup cmp-nvim-lsp source.
M.setup_source = function(main_nr, otter_nr)
  local callback = function()
    M.cmp_on_insert_enter(main_nr, otter_nr)
  end
  vim.api.nvim_create_autocmd('InsertEnter', {
    buffer = main_nr,
    group = vim.api.nvim_create_augroup('cmp_quarto' .. otter_nr, { clear = true }),
    callback = callback
  })
end

---Refresh sources on InsertEnter.
-- adds a source for the hidden language buffer
M.cmp_on_insert_enter = function(main_nr, otter_nr)
  local cmp = require('cmp')
  local allowed_clients = {}

  -- register all active clients.
  for _, client in ipairs(vim.lsp.get_active_clients({ bufnr = otter_nr })) do
    allowed_clients[client.id] = client
    if not M.cmp_client_source_map[client.id] then
      local s = source.new(client, main_nr, otter_nr, require 'otter.keeper'.sync_this_raft)
      if s:is_available() then
        P('register source for ' .. s.client.name)
        M.cmp_client_source_map[client.id] = cmp.register_source('quarto', s)
      end
    end
  end

  -- register all buffer clients (early register before activation)
  for _, client in ipairs(vim.lsp.get_active_clients({bufnr = otter_nr})) do
    allowed_clients[client.id] = client
    if not M.cmp_client_source_map[client.id] then
      local s = source.new(client, main_nr, otter_nr, require 'otter.keeper'.sync_this_raft)
      if s:is_available() then
        M.cmp_client_source_map[client.id] = cmp.register_source('quarto', s)
      end
    end
  end

  -- unregister stopped/detached clients.
  for client_id, source_id in pairs(M.cmp_client_source_map) do
    if not allowed_clients[client_id] or allowed_clients[client_id]:is_stopped() then
      cmp.unregister_source(source_id)
      M.cmp_client_source_map[client_id] = nil
    end
  end
end


return M