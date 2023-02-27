-- slotter
-- v0.1
--
-- Slot sounds together

Sample = include 'lib/Sample'

sample371 = Sample:new {
    filename = '/home/we/dust/audio/tape/carnage1.wav',
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
    playing = 0,
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

--- Get the name of the current page.
--
function page_name()
    return PAGES[app.page]
end

function key(n, z)
    if n == 1 then
        -- Capture K1 shift

        app.k1_down = (z == 1)

    elseif page_name() == 'PLAY' then
        key_play(n, z)
    end
end

-- Key capture on the play page.
--
function key_play(n, z)
    if n == 2 and z == 1 then
        -- Capture play/stop

        app.playing = 1 - app.playing
        softcut.play(1, app.playing)
        redraw()
    end
end

function enc(n, d)
    -- Global encoder rules

    if n == 1 and app.k1_down then
        app.page = util.clamp(app.page + d, 1, #PAGES)
        redraw()
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

--- Redraw the capture (load/record) page.
--
function redraw_capture()
    screen.level(4)
    screen.move(0,8)
    screen.text('Capture page')
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

