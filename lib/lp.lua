-- LUNCHPAID
-- RG Launchpad client on 10 x 8 grid 
-- Top button row is column 10 
-- Partial compatibility with Grids API
local version = include('lunchpaid/lib/version')

local lp = { 
    version = version,
    midi_id = nil
}

local og_dev_add, og_dev_remove

-- TODO: support multiple devices

function lp.find_midi_device_id()
    local found_id = nil
    for i, dev in pairs(midi.devices) do
        local name = string.lower(dev.name)
        if lp.name_matches(name) then
            found_id = dev.id
        end
    end
    return found_id
end

function lp.connect(dummy_id)
    lp.set_midi_handler()
    return lp
end

function lp.set_key_handler(key_handler)
    lp.set_midi_handler()
    lp.key = key_handler
end

function lp.setup_connect_handling()
    og_dev_add = midi.add
    og_dev_remove = midi.remove

    midi.add = lp.handle_dev_add
    midi.remove = lp.handle_dev_remove
end

function lp.name_matches(name)
    return (name == 'launchpad mini' or name == 'launchpad')
end

function lp.handle_dev_add(id, name, dev)
    og_dev_add(id, name, dev)

    lp.update_devices()

    if (lp.name_matches(name)) and (id ~= lp.midi_id) then
        lp.midi_id = id
        lp.set_midi_handler()
    end
end

function lp.handle_dev_remove(id)
    og_dev_remove(id)
    lp.update_devices()
end

function lp.set_midi_handler()
    if lp.midi_id == nil then
        return
    end

    if midi.devices[lp.midi_id] ~= nil then
        midi.devices[lp.midi_id].event = lp.handle_key_midi
    else
        lp.midi_id = nil
    end
end

-- Accept MIDI event and trigger key event, 
-- i.e. "convert" / pass-through
function lp.handle_key_midi(event)
    local x, y, z

    if event[1] == 0x90 then
        x = (event[2] & 15) + 1
        y = (event[2] >> 4) + 1
    elseif event[1] == 0xB0 then
        x = 10
        y = (event[2] & 7) + 1
    end
    z = event[3] & 1

    if lp.key ~= nil then 
        lp.key(lp.midi_id, x, y, z)
    end
end

-- x = {1...10}; y = {1...8}
-- z = {0...15} (bits: G1 G0 R1 R0)
function lp:led(x, y, z)
    if lp.midi_id == nil then 
        return 
    end

    local event = {}

    if x == 10 then
        event[1] = 0xB0
        event[2] = 0x68 | (y-1)
    else
        event[1] = 0x90
        event[2] = ((y-1) << 4) | (x-1)
    end

    event[3] = ((z << 2) & 0x30) | (z & 0x03) 

    midi.devices[lp.midi_id]:send(event)
end

function lp.cleanup() 
    lp.key = nil
end

-- just for Grid compatibility...for now
function lp:refresh()
end

-- set state of all LEDs on this device.
function lp:all (val) 
    -- TODO: Use LP's special "update all LEDs" method
    -- By itself performance issues aren't noticeable 
    -- but could interfere with other precesses
    for y=1, 8 do
        for x=1, 10 do
            lp:led(x, y, val)
        end
    end 
end

function lp.add(dev) 
    print('lp.add not implemented') 
end

function lp.remove(dev) 
    print('lp.remove not implemented') 
end

function lp.update_devices() 
    midi.update_devices()

    local new_id = lp.find_midi_device_id()

    -- Only set id/handler when helpful
    if (lp.midi_id ~= new_id) and (new_id ~= nil) then
        lp.midi_id = new_id
        return lp.set_midi_handler()
    end

    return (lp.midi_id ~= nil)
end

lp.setup_connect_handling()
lp.update_devices()

return lp