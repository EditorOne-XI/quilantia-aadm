# Custom Neovim setup

> [!NOTE]
> **Preference** <br>
> Guide made by EditorOne XI. This is the author's preference, replicating this does not guarantee the same result.

## Table of Content

- [LazyVim to Neovim](#lazyvim-to-neovim)
- [Groovy/Gradle LSP](#groovygradle-lsp)
- [Java-Android LSP](#java-android-lsp)
- [XML LSP (LemMinX + Android)](#xml-lsp-lemminx--android)

## LazyVim to Neovim

<details>
  <summary>Set Termux a Nerd Font. (Skip if done)</summary>

Neovim uses unicode icon characters for TUI graphics.

To make Neovim look good. Find a font from [Nerd Fonts](https://www.nerdfonts.com/font-downloads). (Recommended are JetBrains or Meslo)

After selecting a font, hold its 'Download' button then click **Copy link address** option.

Then run this in Termux right after to install the font:

```bash
mkdir -p ~/.termux
wget -O ~/.termux/font.ttf $(termux-clipboard-get | cat)
termux-reload-settings
```
> If Termux is forced to close after reload, then simply reopen Termux.

</details>

Clone [LazyVim](https://www.lazyvim.org/installation) or [NvChad](https://nvchad.com/docs/quickstart/install) with their starter installation.


## Groovy/Gradle LSP

> [!NOTE]
> Path `~/.gradle/` must be done via `pdd` command.

Run this command first. This will install its gradle version to `~/.gradle/`. Remove it properly after a successful build.

```bash
git clone https://github.com/prominic/groovy-language-server.git ~/.local/share/groovy-language-server
cd ~/.local/share/groovy-language-server
./gradlew build
```
---

Next, create a path for LSP config and open it.

```bash
mkdir -p ~/.config/nvim/ftplugin/
touch ~/.config/nvim/ftplugin/groovy.lua
nvim ~/.config/nvim/ftplugin/groovy.lua
```

Paste this code inside `groovy.lua`:

```lua
local home = os.getenv("HOME")
local prefix = os.getenv("PREFIX")
local groovy_jar = home .. "/.local/share/groovy-language-server/build/libs/groovy-language-server-all.jar"

local file = io.open(groovy_jar, "r")
if file then
  file:close()

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if status_ok then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  vim.lsp.start({
    name = "groovy_language_server",
    cmd = {
      prefix .. "/bin/java",
      "-jar",
      groovy_jar,
    },
    root_dir = vim.fs.root(0, { "settings.gradle", "settings.gradle.kts", "build.gradle", "build.gradle.kts", ".git" }) or vim.fn.getcwd(),
    capabilities = capabilities,
    on_attach = function(_, bufnr)
      local map = vim.keymap.set
      map("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition", buffer = bufnr })
      map("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation", buffer = bufnr })
      map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action", buffer = bufnr })
      map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename Symbol", buffer = bufnr })

      vim.opt_local.tabstop = 4
      vim.opt_local.shiftwidth = 4
      vim.opt_local.expandtab = true

      print("Groovy/Gradle LSP connected!")
    end,
  })
else
  print("Groovy Language Server JAR not found at: " .. groovy_jar)
end
```
Save the file and you are good to go.

---

## Java-Android LSP

> [!NOTE]
> Installing Java debugging is optional but it is recommended for resolving compile time errors and organizing imports.

Install plugins and configs to Neovim:

```bash
mkdir -p ~/.local/share/nvim/site/pack/plugins/start
git clone https://github.com/mfussenegger/nvim-jdtls.git ~/.local/share/nvim/site/pack/plugins/start/nvim-jdtls
git clone https://github.com/neovim/nvim-lspconfig ~/.config/nvim/pack/nvim/start/nvim-lspconfig
```

Download the latest JDTLS snapshot from Eclipse and extract it:
- If not fetched, download manually from the link and move the file inside termux `~/jdtls`

```bash
mkdir ~/jdtls && cd ~/jdtls
wget https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz
tar -xf jdt-language-server-latest.tar.gz
```

Download and build the Debug Adapter, for debugging:

```bash
pkg install maven -y
mkdir -p ~/java-debug && cd ~/java-debug
git clone https://github.com/microsoft/java-debug.git
cd java-debug
mvn clean install
```

> [!NOTE]
> Building the Debug Adapter takes 4-5 minutes; may vary on your internet connection, because it will install its libraries first. So that updating DAP would not take that long again.<br>
> If it installed other version of openjdk-XX, uninstall it after building the JAR file with `pkg uninstall openjdk-XX -y` (other than 21)
> You can also run `rm -rf ~/.m2/` after it takes too much storage.

---

Edit the plugins of Neovim:

```bash
nvim ~/.config/nvim/lua/plugins/init.lua
```

Insert the following in `init.lua`:

```lua
-- Inside return
return {
  -- Find this code block, it is mostly preconfig.
  {
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-jdtls", -- Insert this line
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Insert this two code blocks, for debugging
  {
    "stevearc/dressing.nvim",
    lazy = false,
    opts = {},
  },
  {
    "mfussenegger/nvim-dap",
    lazy = false,
  },
  -- END
}
```

Save the file then run `:Lazy install` in Neovim command to install additional plugins.

---

Next, create a path for LSP config and open it.

```bash
mkdir -p ~/.config/nvim/ftplugin/
touch ~/.config/nvim/ftplugin/java.lua
nvim ~/.config/nvim/ftplugin/java.lua
```

Paste this code inside `java.lua`:

```lua
local home = os.getenv("HOME")
local prefix = os.getenv("PREFIX")
local jdtls_dir = home .. "/jdtls"

-- Neovim LSP
local capabilities = vim.lsp.protocol.make_client_capabilities()
local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if status_ok then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- Project Init
local root_dir = require('jdtls.setup').find_root({'.project', '.lsproot', '.git', 'pom.xml'}) or vim.fn.getcwd()
local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = home .. "/.cache/jdtls/workspace/" .. project_name
local launcher_jar = vim.fn.glob(jdtls_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar")

local jdtls_settings = {
  java = {
    autobuild = { enabled = false },
    import = {
      gradle = { enabled = false },
      maven = { enabled = false },
    },
  },
}

-- Debug Adapter
local bundles = {}
local debug_jar = vim.fn.glob(home .. "/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar", true)
if debug_jar ~= "" and vim.fn.filereadable(debug_jar) == 1 then
  table.insert(bundles, debug_jar)
end

-- LSP config
local config = {
  cmd = {
    prefix .. "/bin/java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xms512m", -- Change 512 to adjust load size
    "-Duser.home=" .. home,
    "-Dosgi.configuration.area=" .. jdtls_dir .. "/config_linux",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "-jar", launcher_jar,
    "-configuration", jdtls_dir .. "/config_linux",
    "-data", workspace_dir
  },
  root_dir = root_dir,
  capabilities = capabilities,
  init_options = {
    bundles = bundles,
    settings = jdtls_settings,
  },
  settings = jdtls_settings,

  on_attach = function(client, bufnr)
    pcall(require("nvchad.configs.lspconfig").on_attach, client, bufnr)

    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      update_in_insert = false,
      underline = true,
    })

    local file_name = vim.fn.expand("%:t")
    local map = vim.keymap.set
    map("n", "<leader>jo", "<cmd>lua require('jdtls').organize_imports()<cr>", { desc = "Organize Imports", buffer = bufnr })
    map("n", "<leader>jc", "<cmd>lua require('jdtls').extract_constant()<cr>", { desc = "Extract Constant", buffer = bufnr })
    map("n", "<leader>jv", "<cmd>lua require('jdtls').extract_variable()<cr>", { desc = "Extract Variable", buffer = bufnr })
    map("n", "<leader>jr", "<cmd>terminal java " .. file_name .. "<cr>", { desc = "Run current Java File" })
    map("n", "<leader>cr", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename Symbol", buffer = bufnr })
    map({"n", "i", "v"}, "<C-s>", "<cmd>w<cr>", { desc = "Save File" })
    map("i", "<S-Up>", "<Esc>v<Up>", { desc = "Select Up" })
    map("i", "<S-Down>", "<Esc>v<Down>", { desc = "Select Down" })
    map("i", "<S-Left>", "<Esc>v<Left>", { desc = "Select Left" })
    map("i", "<S-Right>", "<Esc>v<Right>", { desc = "Select Right" })

    -- for debugging
    -- codelens is deprecated, therefore not included
    map("n", "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", { desc = "Debug Breakpoint" })
    map("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", { desc = "Debug Continue" })
    map("n", "<leader>di", "<cmd>lua require'dap'.step_into()<cr>", { desc = "Debug Step Into" })
    map("n", "<leader>do", "<cmd>lua require'dap'.step_over()<cr>", { desc = "Debug Step Over" })
    map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action", buffer = bufnr })

    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true

    print("Java LSP connected!")
  end,
}

require('jdtls').start_or_attach(config)
```
Save the file and you are good to go.

## XML LSP (LemMinX + Android)

Download the LemMinX JAR file with proper destination:

Get the latest version of LemMinX if available [here](https://download.eclipse.org/lemminx/releases/).

```bash
mkdir -p ~/.local/share/xml/schemas
wget --quiet --show-progress -O ~/.local/share/xml/lemminx-uber.jar https://ftp.jaist.ac.jp/pub/eclipse/lemminx/releases/0.31.2/org.eclipse.lemminx-uber.jar
wget --quiet --show-progress -O ~/.local/share/xml/schemas/android-attributes.xsd https://raw.githubusercontent.com/atsushieno/xamarin-android-shema-generator/refs/heads/master/generated/android-attributes.xsd
wget --quiet --show-progress -O ~/.local/share/xml/schemas/android-layout.xsd https://raw.githubusercontent.com/atsushieno/xamarin-android-shema-generator/refs/heads/master/generated/android-layout.xsd
```
---

Next, create a path for the LSP config, and Luasnip. Then open those files.

```bash
mkdir -p ~/.config/nvim/ftplugin/
mkdir -p ~/.config/nvim/lua/
touch ~/.config/nvim/ftplugin/xml.lua
touch ~/.config/nvim/lua/android_xml_snip.lua
nvim ~/.config/nvim/ftplugin/xml.lua ~/.config/nvim/lua/android_xml_snip.lua
```

Paste this code inside `android_xml_snip.lua`:

```lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node

local M = {}

local function read_file(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  return content
end

function M.generate_snippets(xsd_paths)
  local android_types = {}
  local attributes = {}
  local elements = {}

  for _, path in ipairs(xsd_paths) do
    local content = read_file(path)
    if content then
      -- simpleType enumeration
      for type_name, body in content:gmatch('<xs:simpleType%s+name="([^"]+)">(.-)</xs:simpleType>') do
        local enums = {}
        for enum_val in body:gmatch('<xs:enumeration%s+value="([^"]+)"') do
          table.insert(enums, enum_val)
        end
        if #enums > 0 then
          android_types[type_name] = enums
          android_types["android:" .. type_name] = enums
        end
      end
      -- Explicit itemType attribute links
      for name, item_type in content:gmatch('<xs:attribute%s+name="([^"]+)".-itemType="([^"]+)".-</xs:attribute>') do
        attributes[name] = item_type
      end
      -- Attribute declarations
      for attr_tag in content:gmatch('<xs:attribute%s+[^>]+>') do
        local name = attr_tag:match('name="([^"]+)"')
        local type_attr = attr_tag:match('type="([^"]+)"')
        if name and not attributes[name] then
          attributes[name] = type_attr or "xs:string"
        end
      end
      -- Android XML element tag names
      for elem_name in content:gmatch('<xs:element%s+name="([^"]+)"') do
        if not elem_name:find("%.") then
          table.insert(elements, elem_name)
        end
      end
    end
  end

  local snippets = {}
  -- Build attribute snippets
  for name, type_ref in pairs(attributes) do
    local enum_list = android_types[type_ref]
    local value_node

    if enum_list and #enum_list > 0 then
      local choices = {}
      for _, val in ipairs(enum_list) do
        table.insert(choices, t(val))
      end
      value_node = c(1, choices)
    elseif type_ref == "xs:boolean" then
      value_node = c(1, { t("true"), t("false") })
    else
      value_node = i(1, "value")
    end

    local nodes = { t('android:' .. name .. '="'), value_node, t('"') }
    table.insert(snippets, s({ trig = "android:" .. name, dscr = "Android attribute: " .. name }, vim.deepcopy(nodes)))
    table.insert(snippets, s({ trig = name, dscr = "Android attr: " .. name }, vim.deepcopy(nodes)))
  end
  -- Build XML element block snippets
  for _, elem in ipairs(elements) do
    local block_nodes = {
      t({ "<" .. elem, '    android:layout_width="' }),
      c(1, { t("match_parent"), t("wrap_content") }),
      t({ '"', '    android:layout_height="' }),
      c(2, { t("wrap_content"), t("match_parent") }),
      t({ '">', '    ' }),
      i(0),
      t({ "", "</" .. elem .. ">" }),
    }

    table.insert(snippets, s({ trig = elem, dscr = "Android Element: <" .. elem .. ">" }, block_nodes))
  end
  return snippets
end

function M.setup(xsd_paths)
  local snippets = M.generate_snippets(xsd_paths)
  ls.add_snippets("xml", snippets)
end

return M
```

Then paste this code inside `xml.lua`:

```lua
local home = os.getenv("HOME")
local base_dir = home .. "/.local/share/xml"
local lemminx_jar = base_dir .. "/lemminx-uber.jar"
local android_attrs_path = base_dir .. "/schemas/android-attributes.xsd"
local android_layout_path = base_dir .. "/schemas/android-layout.xsd"

-- Exits if JAR does not exists
if vim.fn.filereadable(lemminx_jar) == 0 then return end

local root_markers = { ".lsproot", "settings.gradle", "settings.gradle.kts", ".git", "build.gradle", "build.gradle.kts" }
local root_dir = vim.fs.dirname(vim.fs.find(root_markers, { upward = true, path = vim.api.nvim_buf_get_name(0) })[1]) or vim.fn.getcwd()

local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_lsp_ok then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

vim.lsp.start({
  name = "lemminx",
  cmd = { "java", "-jar", lemminx_jar },
  root_dir = root_dir,
  capabilities = capabilities,
  settings = {
    xml = {
      schemas = {
        {
          fileMatch = { "res/layout/*.xml", "res/layout-*/*.xml" },
          url = "file://" .. android_layout_path,
        },
        {
          fileMatch = { "res/values/*.xml", "res/drawable/*.xml", "res/**/*.xml" },
          url = "file://" .. android_attrs_path,
        },
      },
      completion = {
        autoCloseTags = true,
      },
    },
  },
  on_attach = function(_, _)
    -- Luasnip generator, in case schemas did not load properly
    local snippet_ok, snippet_android = pcall(require, "android_xml_snip")
    if snippet_ok then
      snippet_android.setup({
        android_attrs_path,
        android_layout_path,
      })
    end
    print("LemMinX (XML) LSP connected!")
  end,
})
```
Save the files and you are good to go.

