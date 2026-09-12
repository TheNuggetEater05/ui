if getgenv().unload then
    getgenv().unload()
end

-- services
local input = game:GetService("UserInputService")

local library = {
    open = true,
    current_z = 0,
    drawings = {},
    connections = {},
    binds = {},

    themes = {
        default = {
            accent = Color3.new(1.0, 0.0, 1.0),
            text = Color3.new(1, 1, 1),

            outline = Color3.new(0, 0, 0),
            inline = Color3.new(0.2, 0.2, 0.2),
            background = Color3.new(0.1, 0.1, 0.1),
        },

        tokyo = {
            accent = Color3.new(0.47, 0.48, 0.94),
            text = Color3.new(0.79, 0.82, 0.95),

            outline = Color3.new(0.04, 0.05, 0.08),
            inline = Color3.new(0.13, 0.15, 0.22),
            background = Color3.new(0.06, 0.07, 0.11),
        },

        midnight = {
            accent = Color3.new(0.35, 0.55, 1.0),
            text = Color3.new(0.9, 0.92, 0.98),

            outline = Color3.new(0.04, 0.05, 0.08),
            inline = Color3.new(0.14, 0.17, 0.24),
            background = Color3.new(0.07, 0.08, 0.12),
        },

        dracula = {
            accent = Color3.new(0.74, 0.58, 0.98),
            text = Color3.new(0.95, 0.95, 0.95),

            outline = Color3.new(0.10, 0.08, 0.13),
            inline = Color3.new(0.20, 0.18, 0.25),
            background = Color3.new(0.11, 0.09, 0.15),
        },

        gruvbox = {
            accent = Color3.new(0.98, 0.60, 0.25),
            text = Color3.new(0.92, 0.88, 0.76),

            outline = Color3.new(0.10, 0.08, 0.06),
            inline = Color3.new(0.25, 0.22, 0.17),
            background = Color3.new(0.12, 0.10, 0.08),
        },

        onedark = {
            accent = Color3.new(0.38, 0.67, 0.96),
            text = Color3.new(0.84, 0.86, 0.89),

            outline = Color3.new(0.07, 0.08, 0.10),
            inline = Color3.new(0.18, 0.20, 0.23),
            background = Color3.new(0.12, 0.13, 0.15),
        },

        rose = {
            accent = Color3.new(1.0, 0.35, 0.55),
            text = Color3.new(0.95, 0.88, 0.91),

            outline = Color3.new(0.10, 0.05, 0.07),
            inline = Color3.new(0.23, 0.12, 0.16),
            background = Color3.new(0.13, 0.07, 0.09),
        },
    }
}

-- utils
local function draw(
    shape: string,
    tag: string,
    props: {[any]: any?},
    parent: DrawingObject?
) : DrawingObject
    local drawing = Drawing.new(shape)
    
    local default = {
        Visible = true,
        ZIndex = library.current_z + 1,
        Transparency = 1,
        Color = Color3.new(0, 0, 0)
    }

    -- if no custom z-index is set, then increment the libraries highest z
    if not props.ZIndex then
        library.current_z += 1
    end

    for prop, value in pairs(default) do
        setrenderproperty(drawing, prop, value)
    end

    for prop, value in pairs(props) do
        if prop == "Position" and typeof(value) == "UDim2" then
            if parent then
                local parent_pos = getrenderproperty(parent, "Position")
                local parent_size = getrenderproperty(parent, "Size")

                value = parent_pos + Vector2.new(
                    parent_size.X * value.X.Scale + value.X.Offset,
                    parent_size.Y * value.Y.Scale + value.Y.Offset
                )
            end
        elseif prop == "Size" and typeof(value) == "UDim2" then
            if parent then
                local parent_size = getrenderproperty(parent, "Size")

                value = Vector2.new(
                    parent_size.X * value.X.Scale + value.X.Offset,
                    parent_size.Y * value.Y.Scale + value.Y.Offset
                )
            end
        end

        setrenderproperty(drawing, prop, value)
    end

    library.drawings[tag] = drawing

    return drawing
end

local function get_all_drawings()
    return library.drawings
end

-- create our window
function library.new(self, 
    props: {
        Name: string?,
        BackName: string?,
        Position: Vector2?,
        Width: number?,
        Bind: EnumKeyCode?
    }
) : ()
    props = {
        Name = props.Name or "MinUI",
        BackName = props.BackName or "",
        Position = props.Position or Vector2.new(25, 75),
        Width = props.Width or 280,
        Bind = props.Bind or Enum.KeyCode.RightControl,
    }
    -- topbar
    do
        draw("Square", "tb_ol", {
                Filled = true,
                Position = props.Position,
                Size = Vector2.new(props.Width or 75, 25),
                Color = self.themes.default.outline
            }
        )

        draw("Square", "tb_il", {
                Filled = true,
                Position = UDim2.fromOffset(1, 1),
                Size = UDim2.new(1, -2, 1, -2),
                Color = self.themes.default.inline
            }, self.drawings.tb_ol
        )

        draw("Square", "tb_bg", {
                Filled = true,
                Position = UDim2.fromOffset(1, 1),
                Size = UDim2.new(1, -2, 1, -2),
                Color = self.themes.default.background
            }, self.drawings.tb_il
        )

        draw("Text", "tb_text_prefix", {
                Text = props.Name,
                Center = false,
                Position = UDim2.fromScale(0.5, 0.5),
                Color = self.themes.default.text,
                Outline = true,
                Font = 1,
                Size = 13
            }, self.drawings.tb_bg
        )
        draw("Text", "tb_text_accent", {
                Text = props.BackName,
                Center = false,
                Position = UDim2.fromScale(0.5, 0.5),
                Color = self.themes.default.accent,
                Outline = true,
                Font = 1,
                Size = 13
            }, self.drawings.tb_bg
        )
        self.drawings.tb_text_prefix.Position += Vector2.new((-self.drawings.tb_text_prefix.TextBounds.X - self.drawings.tb_text_accent.TextBounds.X) / 2, -self.drawings.tb_text_prefix.TextBounds.Y / 2)
        self.drawings.tb_text_accent.Position += Vector2.new((self.drawings.tb_text_prefix.TextBounds.X - self.drawings.tb_text_accent.TextBounds.X) / 2, -self.drawings.tb_text_accent.TextBounds.Y / 2)
    end
    -- end topbar

    -- setup window bind
    self.connections["menu_bind"] = input.InputBegan:Connect(function(input, processed)
        if processed then return end

        if input.KeyCode == props.Bind then
            self.open = not self.open
            for _, drawing in get_all_drawings() do
                drawing.Visible = self.open
            end
        end
    end)
end

function library.unload(callback: () -> ()?) : ()
    callback = callback or function () end
    for _, drawing in get_all_drawings() do
        drawing:Destroy()
    end

    for _, connection in library.connections do
        connection:Disconnect()
    end

    callback()
end

function library.load_theme(self, name: string) : ()
    if self.themes[name] then
        local theme = self.themes[name]
        for tag, drawing in self.drawings do
            if tag:find("accent") then
                drawing.Color = theme.accent
            elseif tag:find("ol") then
                drawing.Color = theme.outline
            elseif tag:find("il") then
                drawing.Color = theme.inline
            elseif tag:find("bg") then
                drawing.Color = theme.background
            end
        end
    end
end

getgenv().unload = library.unload

return library
