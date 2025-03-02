---@alias justify "start"| "center"| "end"| "space-between"| "space-around"
---@alias align "start"| "center"| "end"
---@alias direction "col" | "row"
---@alias config { direction?:direction, justify?:justify, align?:align }
---@alias size { width:number, height:number }



--- Redondea un número al entero más cercano
---@type fun(value:number):number
local function round(value)
    return math.floor(value + 0.5)
end

--- Convierte un tamaño en porcentaje a número absoluto
---@type fun(size:string|number|nil, parentSize:number):number
local function parseSize(size, parentSize)
    if type(size) == "string" and size:match("%%") then
        return round(parentSize * (tonumber(size:match("%d+")) / 100))
    elseif type(size) == "number" then
        return round(size)
    end
    return 0  -- Si el tamaño es `nil`, devolver 0 temporalmente
end

--- Calcula la posición de los hijos en un contenedor tipo "flexbox"
---@type fun(parent:size, children:Div[],config?:config)
function CalculateFlexPositions(parent, children, config)

    -- Si `config` es nulo, asignar valores por defecto
    config = config or {}
    local direction = config.direction or "row"
    local justify = config.justify or "start"
    local align = config.align or "start"

    local totalFixedSize, flexibleChildren = 0, {}

    -- Convertir tamaños y encontrar hijos sin tamaño definido
    for _, child in ipairs(children) do
        child.attrs.width = parseSize(child.attrs.width, parent.width)
        child.attrs.height = parseSize(child.attrs.height, parent.height)

        if (direction == "row" and child.attrs.width == 0) or (direction == "col" and child.attrs.height == 0) then
            table.insert(flexibleChildren, child)  -- Guardar hijos sin tamaño definido
        else
            totalFixedSize = totalFixedSize + (direction == "row" and child.attrs.width or child.attrs.height)
        end
    end

    -- Distribuir espacio restante entre hijos sin tamaño definido
    local availableSpace = (direction == "row" and parent.width or parent.height) - totalFixedSize
    local flexibleSize = #flexibleChildren > 0 and round(availableSpace / #flexibleChildren) or 0

    for _, child in ipairs(flexibleChildren) do
        if direction == "row" then
            child.attrs.width = flexibleSize
        else
            child.attrs.height = flexibleSize
        end
    end

    -- Calcular espacio total después de la asignación
    local totalSize = 0
    for _, child in ipairs(children) do
        totalSize = totalSize + (direction == "row" and child.attrs.width or child.attrs.height)
    end

    -- Espacio restante después de asignar los tamaños
    availableSpace = (direction == "row" and parent.width or parent.height) - totalSize
    local spacing, offset = 0, 0

    -- Justificación (espaciado horizontal o vertical)
    if justify == "start" then
        offset = 0
    elseif justify == "center" then
        offset = round(availableSpace / 2)
    elseif justify == "end" then
        offset = availableSpace
    elseif justify == "space-between" and #children > 1 then
        spacing = round(availableSpace / (#children - 1))
    elseif justify == "space-around" then
        spacing = round(availableSpace / (#children * 2))
        offset = spacing
    end

    -- Posicionar los hijos
    local currentPos = offset
    for _, child in ipairs(children) do
        local x, y = 0, 0

        if direction == "row" then
            -- Alineación vertical en fila
            if align == "start" then
                y = 0
            elseif align == "center" then
                y = round((parent.height - child.attrs.height) / 2)
            elseif align == "end" then
                y = parent.height - child.attrs.height
            end

            x = currentPos
            currentPos = currentPos + child.attrs.width + spacing
        else
            -- Alineación horizontal en columna
            if align == "start" then
                x = 0
            elseif align == "center" then
                x = round((parent.width - child.attrs.width) / 2)
            elseif align == "end" then
                x = parent.width - child.attrs.width
            end

            y = currentPos
            currentPos = currentPos + child.attrs.height + spacing
        end

        child.attrs.col = x
        child.attrs.row = y
        print("child:", x,y)
    end
end

