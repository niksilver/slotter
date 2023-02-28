-- slotter
-- v0.1
--
-- Slot sounds together

fileselect = require 'fileselect'

Sample = include 'lib/Sample'
Banks = include 'lib/Banks'

banks = Banks:new()

-- Start of our data structures

sample371 = Sample:new {
    filename = '/home/we/dust/audio/tape/carnage1.wav',
    bank = banks[1],
    slot = 1,
    level = 1,
    rate = 1,
    start = 0,
    duration = 10,
}

-- The pages we have

PAGES = {
    'CAPTURE',
    'SPLIT',
    'PLAY',    -- Temporary
}

-- State of the app; this isn't saved

app = {
    page = 1,    -- What page (screen) we're on
    k1_down = false,    -- If K1 (shift) is down
    playing = 0,    -- Are we playing? 0 or 1
    capture = {    -- Status of the capture page
        file_path = nil,
        file_name = nil,
        bank = banks[1],
        slot = 1,
        selected = 1,     -- 1 = bank, 2 = slot, 3 = load
    },
}

function init()
    load_sample(1, sample371)
end

function load_sample(voice, sample)
    softcut.buffer_read_mono(
        sample.filename,
        sample.start,    -- File start
        0,    -- Buffer start
        sample.duration,    -- Sample duration
        1,    -- File channel to read
        1,    -- Buffer to write to
        0.0,    -- Preserve level
        1.0)    -- Write level

    softcut.enable(voice, 1)
    softcut.buffer(voice, 1)
    softcut.level(voice, sample.level)
    softcut.loop(voice, 1)
    softcut.loop_start(voice, sample.start)
    softcut.loop_end(voice, sample.start + sample.duration)
    softcut.position(voice, sample.start)
    softcut.rate(voice, sample.rate)

    softcut.play(voice, app.playing)

    redraw()
end

------------------ Top level actions -------------------------

--- Get the name of the current page.
--
function page_name()
    return PAGES[app.page]
end

function key(n, z)
    if n == 1 then
        -- Capture K1 shift

        app.k1_down = (z == 1)

    elseif page_name() == 'CAPTURE' then
        key_capture(n, z)
    elseif page_name() == 'PLAY' then
        key_play(n, z)
    end
end

function enc(n, d)
    -- Global encoder rules

    if n == 1 and app.k1_down then
        app.page = util.clamp(app.page + d, 1, #PAGES)
        redraw()
    end

    if page_name() == 'CAPTURE' then
        enc_capture(n, d)
    end
end

function redraw()
    screen.clear()

    if page_name() == 'CAPTURE' then
        redraw_capture()
    elseif page_name() == 'SPLIT' then
        redraw_split()
    elseif page_name() == 'PLAY' then
        redraw_play()
    else
        screen.level(4)
        screen.move(0,8)
        screen.text('Unknown page :-(')
    end

    draw_page_indicator()

    screen.update()
end

--- Draw the thing which shows what page we're on.
--
function draw_page_indicator()
    local margin = 16
    local padding = 4

    local total_padding = (#PAGES - 1) * padding
    local length = (64 - total_padding - 2 * margin) / #PAGES

    screen.line_width(1)

    for page = 1, #PAGES do
        screen.level(page == app.page and 8 or 2)
        screen.move(128, margin + (page-1)*padding + (page-1)*length)
        screen.line_rel(0, length)
        screen.stroke()
    end
end

------------------ Actions on the capture page -------------------------

--- Key response on the capture page.
--
function key_capture(n, z)
    if n == 3 and z == 1 and app.capture.selected == 3 then
        -- Capture file selection

        fileselect.enter(_path.audio, capture_file)
    end
end

-- Encoder response on the capture page.
--
function enc_capture(n, d)
    if n == 2 then
        -- E2 selects a different element of the page

        app.capture.selected =
            util.clamp(app.capture.selected + d, 1, 3)
        redraw()

    elseif n == 3 and app.capture.selected == 1 then
        -- E3 changes the bank

        app.capture.bank = banks:inc(app.capture.bank, d)
        redraw()

    elseif n == 3 and app.capture.selected == 2 then
        -- E3 changes the slot

        app.capture.slot = util.clamp(app.capture.slot + d, 1, 16)
        redraw()
    end
end

--- Capture a file for a bank. Finishes with a return to our script with
-- a redraw().
-- This is the callback described at
-- https://monome.org/docs/norns/reference/lib/fileselect
--
function capture_file(file_path)
    if file_path == 'cancel' then
        return nil, nil
    end

    local split_at = string.match(file_path, "^.*()/")

    app.capture.sub(file_path, 1, split_at)
    app.capture.sub(file_path, split_at + 1)

    redraw()
end

--- Redraw the capture (load/record) page.
--
function redraw_capture()
    screen.level(4)
    screen.move(1,8)
    screen.text('Capture to ')
    screen.level(app.capture.selected == 1 and 15 or 4)
    screen.text(app.capture.bank:name())
    screen.level(app.capture.selected == 2 and 15 or 4)
    screen.text(app.capture.slot)

    screen.level(4)
    screen.move(1, 24)
    screen.text('Path: ' .. tostring(app.capture.file_path))
    screen.move(1, 32)
    screen.text('Name: ' .. tostring(app.capture.file_name))

    screen.move(1, 48)
    screen.level(app.capture.selected == 3 and 15 or 4)
    screen.text('Load >')
end

--- Redraw the split page.
--
function redraw_split()
    screen.level(4)
    screen.move(0,8)
    screen.text('Split page')
end

--- Redraw the play page.
--
function redraw_play()
    screen.level(4)
    screen.move(0,8)
    screen.text(app.playing == 1 and 'Playing' or 'Stopped')
end

------------------ Actions on the play page -------------------------

--- Key response on the play page.
--
function key_play(n, z)
    if n == 2 and z == 1 then
        -- Capture play/stop

        app.playing = 1 - app.playing
        softcut.play(1, app.playing)
        redraw()
    end
end

